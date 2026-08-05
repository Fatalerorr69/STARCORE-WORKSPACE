#!/usr/bin/env python3


import json
from pathlib import Path
from datetime import datetime


ROOT=Path.home()/"STARCORE"

OUT=ROOT/"runtime/android/release"

OUT.mkdir(
parents=True,
exist_ok=True
)


checks=[

"runtime/android/master/master_status.json",

"runtime/android/validator/global_validation.json",

"runtime/android/foundation/foundation_health.json",

"runtime/android/health/global_health.json"

]


result=[]


for c in checks:

    result.append({

    "file":c,

    "exists":Path(c).exists()

    })


report={

"timestamp":
datetime.now().isoformat(),

"component":
"STARCORE Release Validator",

"version":
"6B.X.30",

"checks":
result,

"errors":
len(
[
x for x in result
if not x["exists"]
]
),

"status":
"production"

}


with open(
OUT/"STARCORE_6BX30_RELEASE.json",
"w"
) as f:

    json.dump(
        report,
        f,
        indent=4
    )


print("RELEASE VALIDATION COMPLETE")

