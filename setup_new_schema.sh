#!/bin/bash
set -euo pipefail

echo "🔐 Bot Army Schema Template Setup"
echo ""

read -p "Schema name (snake_case, e.g. my_bot_schemas): " SCHEMA_APP_NAME
read -p "Description (e.g. Schemas for MyBot): " SCHEMA_DESCRIPTION

# Convert to camel case
SCHEMA_APP_NAME_CAMEL=$(echo "$SCHEMA_APP_NAME" | sed 's/_\([a-z]\)/\U\1/g' | sed 's/^\([a-z]\)/\U\1/')

echo ""
echo "Creating schemas: $SCHEMA_APP_NAME"
echo "  App name: $SCHEMA_APP_NAME"
echo "  Module: $SCHEMA_APP_NAME_CAMEL"
echo ""

# Replace in all files
find . -type f \( -name "*.ex" -o -name "mix.exs" -o -name "*.json" \) ! -path "./.git/*" | while read -r file; do
  sed -i.bak \
    -e "s|{{SCHEMA_APP_NAME}}|${SCHEMA_APP_NAME}|g" \
    -e "s|{{SCHEMA_APP_NAME_CAMEL}}|${SCHEMA_APP_NAME_CAMEL}|g" \
    -e "s|{{SCHEMA_DESCRIPTION}}|${SCHEMA_DESCRIPTION}|g" \
    "$file"
  rm "${file}.bak"
done

# Initialize git if not already
if [ ! -d .git ]; then
  git init
  git add .
  git commit -m "initial: create schema repo from template"
fi

echo "✅ Setup complete!"
echo ""
echo "📋 Next steps:"
echo "  1. Edit lib/schemas/*.schema.json to define your message types"
echo "  2. Run: mix deps.get && mix test"
echo "  3. Document subjects in README.md or SUBJECTS.md"
echo "  4. Publish to GitHub"
echo ""
