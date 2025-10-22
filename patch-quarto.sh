#!/bin/bash

# Quarto WebR Syntax Highlighting Patcher
# This script patches the Quarto VS Code/Positron extension to add WebR syntax highlighting

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Find Quarto extension directory
find_quarto_extension() {
    local base_dir="$1"
    if [ -d "$base_dir" ]; then
        find "$base_dir" -maxdepth 1 -type d -name "quarto.quarto-*" | head -1
    fi
}

# Detect the IDE and extension path
if [ -d "$HOME/.positron/extensions" ]; then
    QUARTO_EXT=$(find_quarto_extension "$HOME/.positron/extensions")
    IDE="Positron"
elif [ -d "$HOME/.vscode/extensions" ]; then
    QUARTO_EXT=$(find_quarto_extension "$HOME/.vscode/extensions")
    IDE="VS Code"
else
    echo -e "${RED}Error: Could not find VS Code or Positron extensions directory${NC}"
    exit 1
fi

if [ -z "$QUARTO_EXT" ]; then
    echo -e "${RED}Error: Quarto extension not found${NC}"
    exit 1
fi

echo -e "${GREEN}Found Quarto extension in $IDE:${NC}"
echo "$QUARTO_EXT"
echo

GRAMMAR_FILE="$QUARTO_EXT/syntaxes/quarto.tmLanguage"
PACKAGE_FILE="$QUARTO_EXT/package.json"

# Check if files exist
if [ ! -f "$GRAMMAR_FILE" ]; then
    echo -e "${RED}Error: Grammar file not found at $GRAMMAR_FILE${NC}"
    exit 1
fi

if [ ! -f "$PACKAGE_FILE" ]; then
    echo -e "${RED}Error: package.json not found at $PACKAGE_FILE${NC}"
    exit 1
fi

# Check if already patched
if grep -q "fenced_code_block_webr" "$GRAMMAR_FILE"; then
    echo -e "${YELLOW}WebR syntax highlighting already installed!${NC}"
    exit 0
fi

# Backup original files
echo "Creating backups..."
cp "$GRAMMAR_FILE" "$GRAMMAR_FILE.backup"
cp "$PACKAGE_FILE" "$PACKAGE_FILE.backup"

echo "Patching grammar file..."

# Find the line number for fenced_code_block_r definition
R_BLOCK_END=$(grep -n "</dict>" "$GRAMMAR_FILE" | grep -A1 "$(grep -n 'fenced_code_block_r' "$GRAMMAR_FILE" | grep 'key>' | head -1 | cut -d: -f1)" | tail -1 | cut -d: -f1)

if [ -z "$R_BLOCK_END" ]; then
    echo -e "${RED}Error: Could not find R block definition${NC}"
    exit 1
fi

# Insert webr block definition after R block
sed -i '' "${R_BLOCK_END}a\\
      <key>fenced_code_block_webr</key>\\
      <dict>\\
        <key>begin</key>\\
        <string>(^|\\\\G)(\\\\s*)(\`{3,}|~{3,})\\\\s*(?:\\\\{(?:#[\\\\w-]+\\\\s+)?[\\\\{\\\\.=]?)?(?i:(webr|\\\\{\\\\.webr.+?\\\\}|.+\\\\-webr)(?:\\\\}{1,2})?((\\\\s+|:|,|\\\\{|\\\\?)[^\`~]*)?$)</string>\\
        <key>name</key>\\
        <string>markup.fenced_code.block.markdown</string>\\
        <key>end</key>\\
        <string>(^|\\\\G)(\\\\2|\\\\s{0,3})(\\\\3)\\\\s*$</string>\\
        <key>beginCaptures</key>\\
        <dict>\\
          <key>3</key>\\
          <dict>\\
            <key>name</key>\\
            <string>punctuation.definition.markdown</string>\\
          </dict>\\
          <key>4</key>\\
          <dict>\\
            <key>name</key>\\
            <string>fenced_code.block.language.markdown</string>\\
          </dict>\\
          <key>5</key>\\
          <dict>\\
            <key>name</key>\\
            <string>fenced_code.block.language.attributes.markdown</string>\\
          </dict>\\
        </dict>\\
        <key>endCaptures</key>\\
        <dict>\\
          <key>3</key>\\
          <dict>\\
            <key>name</key>\\
            <string>punctuation.definition.markdown</string>\\
          </dict>\\
        </dict>\\
        <key>patterns</key>\\
        <array>\\
          <dict>\\
            <key>begin</key>\\
            <string>(^|\\\\G)(\\\\s*)(.*)</string>\\
            <key>while</key>\\
            <string>(^|\\\\G)(?!\\\\s*([\`~]{3,})\\\\s*$)</string>\\
            <key>contentName</key>\\
            <string>meta.embedded.block.webr</string>\\
            <key>patterns</key>\\
            <array>\\
              <dict>\\
                <key>include</key>\\
                <string>source.r</string>\\
              </dict>\\
            </array>\\
          </dict>\\
        </array>\\
      </dict>
" "$GRAMMAR_FILE"

# Add webr to fenced_code_block patterns array
PATTERN_LINE=$(grep -n "#fenced_code_block_r" "$GRAMMAR_FILE" | grep "string>" | head -1 | cut -d: -f1)
sed -i '' "${PATTERN_LINE}a\\
          <dict>\\
            <key>include</key>\\
            <string>#fenced_code_block_webr</string>\\
          </dict>
" "$GRAMMAR_FILE"

echo "Patching package.json..."

# Add webr to embeddedLanguages
sed -i '' 's/"meta.embedded.block.r": "r",/"meta.embedded.block.r": "r",\
\t\t\t\t\t"meta.embedded.block.webr": "r",/' "$PACKAGE_FILE"

echo -e "${GREEN}✓ Patching complete!${NC}"
echo
echo -e "${YELLOW}Please restart $IDE for changes to take effect.${NC}"
echo
echo "Backups created:"
echo "  $GRAMMAR_FILE.backup"
echo "  $PACKAGE_FILE.backup"
