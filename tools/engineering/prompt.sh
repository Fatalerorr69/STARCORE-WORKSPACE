#!/data/data/com.termux/files/usr/bin/bash


BASE="$HOME/STARCORE"

TYPE=$1


OUT="$BASE/prompts/generated"


mkdir -p "$OUT"



case "$TYPE" in


audit)

cat > "$OUT/audit_prompt.md" <<EOF

# STARCORE FULL AUDIT PROMPT


Analyze the STARCORE repository.


Context:

$(cat $BASE/config/ai_context.yaml)


Tasks:

1. Analyze architecture
2. Identify duplicate systems
3. Find unfinished modules
4. Create completion roadmap
5. Suggest refactoring


Do not modify files.

