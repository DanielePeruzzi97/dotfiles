#!/bin/bash
export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"
TERMINAL=$(which ghostty 2>/dev/null || which alacritty 2>/dev/null || echo "x-terminal-emulator")

if ! command -v topgrade >/dev/null 2>&1; then
    notify-send "System Update" "topgrade not installed. Run: cargo install topgrade" -i dialog-error
    exit 1
fi

notify-send -t 2000 "System Update" "Starting topgrade..." -i system-software-update

tmpscript=$(mktemp /tmp/topgrade-update-XXXXXX.sh)
cat > "$tmpscript" << EOF
#!/bin/bash
export PATH="$HOME/.cargo/bin:$HOME/.local/bin:\$PATH"
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "                    System Update (topgrade)"
echo "═══════════════════════════════════════════════════════════════"
echo ""

topgrade --yes

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "                      Update complete!"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Press Enter to close..."
read

pkill -RTMIN+8 waybar 2>/dev/null
EOF

echo "rm -f \"$tmpscript\"" >> "$tmpscript"
chmod +x "$tmpscript"
"$TERMINAL" -e "$tmpscript" &
