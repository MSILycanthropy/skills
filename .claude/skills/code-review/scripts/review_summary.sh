#!/usr/bin/env bash
# Renders a colored code review summary in the terminal.
#
# Usage:
#   bash review_summary.sh \
#     --critical 1 --high 2 --medium 0 --low 3 \
#     --checks "Bugs & Logic:pass,Security:pass,Concurrency:skip:no concurrent code"

set -euo pipefail

# ── Colors ──────────────────────────────────────────────
RED='\033[1;31m'
YLW='\033[1;33m'
ORG='\033[0;33m'
BLU='\033[1;34m'
GRN='\033[1;32m'
DIM='\033[2m'
BOLD='\033[1m'
RST='\033[0m'

# ── Parse args ──────────────────────────────────────────
CRITICAL=0; HIGH=0; MEDIUM=0; LOW=0; CHECKS=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --critical) CRITICAL="$2"; shift 2 ;;
    --high)     HIGH="$2";     shift 2 ;;
    --medium)   MEDIUM="$2";   shift 2 ;;
    --low)      LOW="$2";      shift 2 ;;
    --checks)   CHECKS="$2";   shift 2 ;;
    *) shift ;;
  esac
done

TOTAL=$((CRITICAL + HIGH + MEDIUM + LOW))

# ── Severity summary ───────────────────────────────────
echo ""
echo -e "${BOLD}── Review Summary ──────────────────────────────${RST}"
echo ""

if [[ $TOTAL -eq 0 ]]; then
  echo -e "  ${GRN}No issues found.${RST}"
else
  [[ $CRITICAL -gt 0 ]] && echo -e "  ${RED}CRITICAL  ${CRITICAL}${RST}"
  [[ $HIGH -gt 0 ]]     && echo -e "  ${ORG}HIGH      ${HIGH}${RST}"
  [[ $MEDIUM -gt 0 ]]   && echo -e "  ${YLW}MEDIUM    ${MEDIUM}${RST}"
  [[ $LOW -gt 0 ]]      && echo -e "  ${BLU}LOW       ${LOW}${RST}"
  echo ""
  echo -e "  ${BOLD}${TOTAL} issue(s) total${RST}"
fi

# ── Checks performed ──────────────────────────────────
if [[ -n "$CHECKS" ]]; then
  echo ""
  echo -e "${BOLD}── Checks Performed ────────────────────────────${RST}"
  echo ""

  IFS=',' read -ra CHECK_LIST <<< "$CHECKS"
  for entry in "${CHECK_LIST[@]}"; do
    # Format: "Name:pass" or "Name:skip:reason"
    IFS=':' read -ra PARTS <<< "$entry"
    name="${PARTS[0]}"
    status="${PARTS[1]:-pass}"
    reason="${PARTS[2]:-}"

    if [[ "$status" == "pass" ]]; then
      echo -e "  ${GRN}PASS${RST}  ${name}"
    elif [[ "$status" == "skip" ]]; then
      echo -e "  ${DIM}SKIP${RST}  ${DIM}${name} — ${reason}${RST}"
    fi
  done
fi

echo ""
echo -e "${BOLD}────────────────────────────────────────────────${RST}"
echo ""
