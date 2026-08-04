from __future__ import annotations

import asyncio

from blueprints.executor import BlueprintExecutor
from blueprints.models import Blueprint
from blueprints.planner import ExecutionPlanner
from blueprints.template_resolver import TemplateResolutionError, resolve_templates
from fastapi import APIRouter, Depends, HTTPException
from orchestrator.scheduler import Scheduler
from pydantic import BaseModel

from core.auth import verify_api_key
from core.database import get_session
from core.models_api import TaskResult
from core.repository import save_run

router = APIRouter(dependencies=[Depends(verify_api_key)])


class PlanResponse(BaseModel):
    name: str
    version: str
    steps: list[dict]


class RunResponse(BaseModel):
    name: str
    version: str
    run_id: str
    tasks: list[TaskResult]


@router.post("/blueprints/plan", response_model=PlanResponse)
async def plan_blueprint(blueprint: Blueprint):
    try:
        blueprint = await resolve_templates(blueprint)
    except TemplateResolutionError as exc:
        raise HTTPException(status_code=422, detail=str(exc)) from exc
    plan = ExecutionPlanner().create_plan(blueprint)
    return PlanResponse(name=blueprint.name, version=blueprint.version, steps=plan)


@router.post("/blueprints/run", response_model=RunResponse)
async def run_blueprint(blueprint: Blueprint, parallel: bool = False):
    try:
        blueprint = await resolve_templates(blueprint)
    except TemplateResolutionError as exc:
        raise HTTPException(status_code=422, detail=str(exc)) from exc
    if parallel:
        graph = ExecutionPlanner().create_graph(blueprint)
        tasks = await Scheduler().execute(graph)
    else:
        tasks = await BlueprintExecutor().execute(blueprint)

    def _persist() -> str:
        session = get_session()
        try:
            record = save_run(session, blueprint.name, blueprint.version, parallel, tasks)
            return record.id
        finally:
            session.close()

    run_id = await asyncio.to_thread(_persist)

    return RunResponse(
        name=blueprint.name,
        version=blueprint.version,
        run_id=run_id,
        tasks=[
            TaskResult(
                id=task.id,
                provider=task.provider,
                resource=task.resource,
                status=task.status.value,
                result=task.result,
            )
            for task in tasks
        ],
    )
