# Quarto WebR Syntax Highlighting Patcher

This tool patches the Quarto VS Code/Positron extension to add R syntax highlighting for `{webr}` code blocks in `.qmd` files.

## Why is this needed?

The Quarto extension doesn't natively support syntax highlighting for WebR code blocks. This patcher modifies the Quarto extension to treat `{webr}` blocks the same as `{r}` blocks, enabling proper syntax highlighting in the editor.

## Installation

```bash
git clone https://github.com/jacques-shebehe/quarto-webr-syntax-patcher.git
cd quarto-webr-syntax-patcher
./patch-quarto.sh
```

Then restart VS Code or Positron.

## What it does

The script makes three modifications to the Quarto extension:

1. **Adds a webr code block definition** to `quarto.tmLanguage` that matches `{webr}` blocks
2. **Registers webr in embeddedLanguages** in `package.json` to use R syntax
3. **Includes webr in the patterns array** so the grammar recognizes it

## Usage

After patching, your `{webr}` code blocks will automatically have R syntax highlighting:

````markdown
```{webr}
library(tidyverse)
mtcars |> 
  filter(mpg > 20) |>
  ggplot(aes(x = wt, y = mpg)) +
  geom_point()
```
````

## After Quarto Extension Updates

When the Quarto extension is updated, you'll need to re-run the patcher:

```bash
./patch-quarto.sh
```

The script automatically:
- Detects your IDE (VS Code or Positron)
- Finds the Quarto extension
- Checks if already patched
- Creates backups before modifying

## Uninstalling

To restore the original Quarto extension:

```bash
# For Positron
cp ~/.positron/extensions/quarto.quarto-*/syntaxes/quarto.tmLanguage.backup \
   ~/.positron/extensions/quarto.quarto-*/syntaxes/quarto.tmLanguage
cp ~/.positron/extensions/quarto.quarto-*/package.json.backup \
   ~/.positron/extensions/quarto.quarto-*/package.json

# For VS Code
cp ~/.vscode/extensions/quarto.quarto-*/syntaxes/quarto.tmLanguage.backup \
   ~/.vscode/extensions/quarto.quarto-*/syntaxes/quarto.tmLanguage
cp ~/.vscode/extensions/quarto.quarto-*/package.json.backup \
   ~/.vscode/extensions/quarto.quarto-*/package.json
```

Then restart your IDE.

## Requirements

- macOS or Linux
- VS Code or Positron with the Quarto extension installed
- Bash shell

## License

MIT
