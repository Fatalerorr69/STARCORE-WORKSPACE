#!/data/data/com.termux/files/usr/bin/bash


BASE="$HOME/STARCORE"

REPORT="$BASE/intelligence/reports"


mkdir -p "$REPORT"


echo "Generating STARCORE analysis..."



find "$BASE" \
-type f \
-not -path "*/.git/*" \
> "$REPORT/files.txt"



find "$BASE" \
-name "*.py" \
> "$REPORT/python_projects.txt"



find "$BASE" \
-name "*.js" \
-o -name "*.ts" \
> "$REPORT/node_projects.txt"



find "$BASE" \
-name "docker-compose*" \
-o -name "Dockerfile*" \
> "$REPORT/docker_inventory.txt"



grep -R \
-E "TODO|FIXME|BUG|HACK" \
"$BASE" \
--exclude-dir=.git \
> "$REPORT/issues.txt" \
|| true



cat > "$REPORT/architecture_report.md" <<EOF2
# STARCORE Architecture Report


Generated:
$(date)


## Statistics


Files:
$(wc -l < "$REPORT/files.txt")


Python:
$(wc -l < "$REPORT/python_projects.txt")


Node:
$(wc -l < "$REPORT/node_projects.txt")


Docker:
$(wc -l < "$REPORT/docker_inventory.txt")


Issues:
$(wc -l < "$REPORT/issues.txt")


EOF2


echo "REPORT READY"

