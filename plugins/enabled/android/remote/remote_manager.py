#!/usr/bin/env python3

import json
from pathlib import Path
from datetime import datetime

ROOT=Path.home()/ "STARCORE"

OUT=ROOT/"runtime/android/remote"
OUT.mkdir(parents=True,exist_ok=True)


data={
"timestamp":datetime.now().isoformat(),
"component":"STARCORE Remote Operations",
"protocol":"SSH",
"port":8022,
"status":"ready"
}


json.dump(
data,
open(OUT/"remote_state.json","w"),
indent=4
)

print("REMOTE READY")

