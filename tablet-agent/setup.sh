#!/data/data/com.termux/files/usr/bin/bash
# =====================================================================
#  Tablet Agent - one-time setup for Termux (Android)
#  Installs Claude Code + ADB and lets Claude control this tablet.
#
#  Before running:
#    1. Install Termux and Termux:API from F-Droid.
#    2. Settings > About tablet > tap "Build number" 7 times.
#    3. Settings > Developer options > turn ON "Wireless debugging".
#    4. Put Settings and Termux side by side (split screen).
#
#  Run:  bash setup.sh
#  Safe to run again at any time.
# =====================================================================
set -e

AGENT_DIR="$HOME/agent"
BIN="$PREFIX/bin"

green() { printf '\033[1;32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[1;33m%s\033[0m\n' "$*"; }
red() { printf '\033[1;31m%s\033[0m\n' "$*"; }

if [ -z "$PREFIX" ] || [ ! -d /data/data/com.termux ]; then
  red "This script must be run inside Termux on Android."
  exit 1
fi

# ---------------------------------------------------------------------
green "[1/6] Installing packages (this takes a few minutes)..."
yes | pkg update -y
yes | pkg upgrade -y -o Dpkg::Options::="--force-confnew"
pkg install -y nodejs-lts android-tools termux-api python git

# ---------------------------------------------------------------------
green "[2/6] Installing Claude Code..."
npm install -g @anthropic-ai/claude-code
if ! command -v claude >/dev/null 2>&1; then
  red "Claude Code did not install. Check the npm output above."
  exit 1
fi

# ---------------------------------------------------------------------
green "[3/6] Creating helper commands..."

# --- adb-reconnect: (re)connect ADB to this tablet --------------------
cat > "$BIN/adb-reconnect" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# Connects adb to this tablet over Wireless debugging.
if adb devices | grep -qE '^(localhost|127\.0\.0\.1)[^ ]*\s+device$'; then
  echo "ADB already connected."; exit 0
fi
adb start-server >/dev/null 2>&1
# Try automatic discovery first
PORT=$(adb mdns services 2>/dev/null | grep '_adb-tls-connect' | grep -oE ':[0-9]+' | head -1 | tr -d ':')
if [ -n "$PORT" ]; then
  adb connect "localhost:$PORT" >/dev/null 2>&1
fi
if ! adb devices | grep -qE '^(localhost|127\.0\.0\.1)[^ ]*\s+device$'; then
  echo "Open Settings > Developer options > Wireless debugging."
  read -rp "Enter the PORT shown under 'IP address & Port' (e.g. 41234): " PORT
  adb connect "localhost:$PORT"
fi
if adb devices | grep -qE '^(localhost|127\.0\.0\.1)[^ ]*\s+device$'; then
  echo "ADB connected."
else
  echo "Could not connect. Is Wireless debugging ON? Did you pair (adb-pair)?"; exit 1
fi
EOF

# --- adb-pair: one-time pairing --------------------------------------
cat > "$BIN/adb-pair" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
echo "In Settings > Wireless debugging, tap 'Pair device with pairing code'."
echo "Keep that dialog OPEN (use split screen)."
read -rp "Pairing PORT (the number after the colon): " PPORT
read -rp "6-digit pairing CODE: " PCODE
adb pair "localhost:$PPORT" "$PCODE"
EOF

# --- tshot: take a screenshot ------------------------------------------
cat > "$BIN/tshot" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# Usage: tshot [output.png]   -> saves screenshot (default ~/agent/screen.png)
OUT="${1:-$HOME/agent/screen.png}"
adb exec-out screencap -p > "$OUT" && echo "$OUT"
EOF

# --- tui: list on-screen elements with tap coordinates ----------------
cat > "$BIN/tui" << 'EOF'
#!/data/data/com.termux/files/usr/bin/python
"""Dump the current screen's UI and print elements with center coordinates.
Usage: tui            -> elements that have text/description or are clickable
       tui <word>     -> only elements matching <word> (case-insensitive)"""
import re, subprocess, sys, xml.etree.ElementTree as ET

subprocess.run(["adb", "shell", "uiautomator", "dump", "/sdcard/ui.xml"],
               stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
xml = subprocess.run(["adb", "exec-out", "cat", "/sdcard/ui.xml"],
                     capture_output=True, text=True).stdout
if "<hierarchy" not in xml:
    sys.exit("Could not read UI (screen may be secure or animating). Try again or use tshot.")
xml = xml[xml.index("<?xml") if "<?xml" in xml else xml.index("<hierarchy"):]
xml = xml[: xml.rindex("</hierarchy>") + len("</hierarchy>")]
flt = sys.argv[1].lower() if len(sys.argv) > 1 else None
for n in ET.fromstring(xml).iter("node"):
    text = n.get("text", "").strip()
    desc = n.get("content-desc", "").strip()
    rid = n.get("resource-id", "").split("/")[-1]
    clickable = n.get("clickable") == "true"
    if not (text or desc or clickable):
        continue
    m = re.findall(r"\d+", n.get("bounds", ""))
    if len(m) != 4:
        continue
    x1, y1, x2, y2 = map(int, m)
    cx, cy = (x1 + x2) // 2, (y1 + y2) // 2
    label = " | ".join(p for p in (text, desc, rid) if p) or n.get("class", "").split(".")[-1]
    if flt and flt not in label.lower():
        continue
    print(f"({cx},{cy}){' [tap]' if clickable else ''}  {label}")
EOF

# --- ttype: type text (handles spaces/special chars) ------------------
cat > "$BIN/ttype" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# Usage: ttype "some text to type"
TXT="$*"
TXT=$(printf '%s' "$TXT" | sed -e 's/[\\"'"'"'`$&|;<>()*?~!#]/\\&/g' -e 's/ /%s/g')
adb shell input text "$TXT"
EOF

# --- agent: start the agent -------------------------------------------
cat > "$BIN/agent" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# Starts the tablet agent. Extra args are passed to claude.
termux-wake-lock 2>/dev/null
adb-reconnect || echo "(continuing without ADB - tablet control won't work)"
cd "$HOME/agent" && exec claude "$@"
EOF

chmod +x "$BIN/adb-reconnect" "$BIN/adb-pair" "$BIN/tshot" "$BIN/tui" "$BIN/ttype" "$BIN/agent"

# ---------------------------------------------------------------------
green "[4/6] Creating the agent's instructions (~/agent/CLAUDE.md)..."
mkdir -p "$AGENT_DIR/.claude"

if [ ! -f "$AGENT_DIR/CLAUDE.md" ]; then
cat > "$AGENT_DIR/CLAUDE.md" << 'EOF'
# Tablet Agent

You are my personal agent running in Termux ON my Android tablet.
You control this same tablet through `adb` (connected to localhost).

## Tools (shell commands)
- `tui`            list on-screen elements with tap coordinates  <- USE THIS FIRST
- `tui <word>`     find a specific element, e.g. `tui search`
- `tshot`          screenshot to ~/agent/screen.png (then read the image) - use when tui isn't enough
- `adb shell input tap X Y`
- `adb shell input swipe X1 Y1 X2 Y2 300`     (scroll down: swipe from lower Y to upper Y)
- `ttype "text"`   type text into the focused field
- `adb shell input keyevent KEYCODE_HOME | KEYCODE_BACK | KEYCODE_ENTER | KEYCODE_APP_SWITCH`
- Open app: `adb shell monkey -p <package> -c android.intent.category.LAUNCHER 1`
- Find app package: `adb shell pm list packages | grep -i <name>`
- Open URL: `adb shell am start -a android.intent.action.VIEW -d "https://..."`
- Termux:API: termux-notification, termux-clipboard-get/set, termux-battery-status,
  termux-tts-speak, termux-volume, termux-brightness, termux-wifi-connectioninfo, termux-toast
- If adb says "no devices": run `adb-reconnect`.

## How to work
1. Look (`tui`, or `tshot` if needed) -> act -> look again to confirm it worked.
2. Wait briefly (`sleep 1`) after opening apps or tapping before looking again.
3. Termux itself is on screen too - don't tap inside it by accident.
4. Keep replies short.

## Safety - ALWAYS ask me first before:
- sending any message, email, or post
- paying, buying, or entering passwords/card details
- deleting files, apps, or data
- changing security settings
EOF
else
  yellow "CLAUDE.md already exists - keeping your version."
fi

cat > "$AGENT_DIR/.claude/settings.json" << 'EOF'
{
  "permissions": {
    "allow": [
      "Bash(tui:*)",
      "Bash(tshot:*)",
      "Bash(ttype:*)",
      "Bash(adb-reconnect:*)",
      "Bash(adb shell input:*)",
      "Bash(adb shell uiautomator:*)",
      "Bash(adb exec-out screencap:*)",
      "Bash(adb shell pm list packages:*)",
      "Bash(adb shell monkey:*)",
      "Bash(adb shell am start:*)",
      "Bash(adb devices:*)",
      "Bash(sleep:*)",
      "Bash(termux-battery-status:*)",
      "Bash(termux-toast:*)",
      "Bash(termux-clipboard-get:*)",
      "Read(~/agent/**)"
    ]
  }
}
EOF

# ---------------------------------------------------------------------
green "[5/6] Connecting ADB to this tablet..."
if adb devices | grep -qE '^(localhost|127\.0\.0\.1)[^ ]*\s+device$'; then
  echo "Already connected."
else
  read -rp "Have you already paired this tablet with Termux before? (y/N): " PAIRED
  if [ "$PAIRED" != "y" ] && [ "$PAIRED" != "Y" ]; then
    adb-pair || yellow "Pairing failed - you can retry later with: adb-pair"
  fi
  adb-reconnect || yellow "Not connected yet - retry later with: adb-reconnect"
fi

# ---------------------------------------------------------------------
green "[6/6] Done!"
cat << 'EOF'

  Start your agent:        agent
  Reconnect ADB:           adb-reconnect      (needed after a reboot)
  Pair again:              adb-pair
  Edit agent's memory:     nano ~/agent/CLAUDE.md

  First run of `agent` will ask you to log in to Claude.

  Tips:
   - Inside the agent, type /remote-control to chat with it from the Claude app.
   - Settings > Apps > Termux > Battery > Unrestricted  (stops Android killing it)
EOF
