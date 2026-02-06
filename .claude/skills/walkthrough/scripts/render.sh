#!/usr/bin/env bash
# Opens the walkthrough diagram in the default browser.
# Works on macOS, Linux, and WSL.

FILE="/tmp/walkthrough_diagram.html"

if [ ! -f "$FILE" ]; then
  echo "Error: $FILE not found. Generate the diagram first."
  exit 1
fi

case "$(uname -s)" in
  Darwin*)  open "$FILE" ;;
  Linux*)
    if grep -qi microsoft /proc/version 2>/dev/null; then
      # WSL
      cmd.exe /c start "$(wslpath -w "$FILE")" 2>/dev/null
    elif command -v xdg-open &>/dev/null; then
      xdg-open "$FILE"
    else
      echo "Opened: file://$FILE (open manually if browser didn't launch)"
    fi
    ;;
  *)
    echo "Opened: file://$FILE (open manually if browser didn't launch)"
    ;;
esac
