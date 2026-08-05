#!/usr/bin/env python3

import json
from pathlib import Path
from datetime import datetime


ROOT = Path.home() / "STARCORE"

EVENT_DIR = ROOT / "runtime/android/events"

QUEUE = EVENT_DIR / "queue.json"
HISTORY = EVENT_DIR / "history.json"


EVENT_DIR.mkdir(
    parents=True,
    exist_ok=True
)



def load(path):

    if path.exists():

        with open(path) as f:
            return json.load(f)

    return []



def save(path,data):

    with open(path,"w") as f:

        json.dump(
            data,
            f,
            indent=4
        )



def emit(
    name,
    source,
    severity,
    payload
):

    event={

        "timestamp":
            datetime.now().isoformat(),

        "event":
            name,

        "source":
            source,

        "severity":
            severity,

        "payload":
            payload

    }


    queue=load(QUEUE)

    history=load(HISTORY)


    queue.append(event)

    history.append(event)


    save(
        QUEUE,
        queue
    )

    save(
        HISTORY,
        history
    )


    return event



if __name__=="__main__":


    e=emit(

        "core.start",

        "control_plane",

        "info",

        {
            "version":
            "6B.X.3.B"
        }

    )


    print(
        json.dumps(
            e,
            indent=4
        )
    )

