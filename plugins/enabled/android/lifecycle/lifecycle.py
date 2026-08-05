#!/usr/bin/env python3


import json
from pathlib import Path
from datetime import datetime


ROOT=Path.home()/ "STARCORE"


state={

"timestamp":
datetime.now().isoformat(),

"component":
"STARCORE Lifecycle",

"version":
"6B.X.13",

"state":
"running",

"auto_restart":
True

}


OUT=ROOT/"runtime/android/fabric"


with open(
OUT/"lifecycle.json",
"w"
) as f:

    json.dump(
    state,
    f,
    indent=4
    )


print(
"LIFECYCLE READY"
)

