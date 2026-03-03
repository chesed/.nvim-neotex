# Filetypes Extension Dependency Guide

Platform-specific installation instructions for all conversion tools.

## Quick Install Summary

| Tool | NixOS | Ubuntu/Debian | macOS |
|------|-------|---------------|-------|
| markitdown | `python3Packages.markitdown` | `pip install markitdown` | `pip install markitdown` |
| pandoc | `pandoc` | `apt install pandoc` | `brew install pandoc` |
| typst | `typst` | (manual/cargo) | `brew install typst` |
| pandas | `python3Packages.pandas` | `pip install pandas` | `pip install pandas` |
| openpyxl | `python3Packages.openpyxl` | `pip install openpyxl` | `pip install openpyxl` |
| python-pptx | `python3Packages.python-pptx` | `pip install python-pptx` | `pip install python-pptx` |
| xlsx2csv | `python3Packages.xlsx2csv` | `pip install xlsx2csv` | `pip install xlsx2csv` |

## NixOS Installation

### Ephemeral (nix-shell)

```bash
nix-shell -p python3Packages.markitdown python3Packages.openpyxl python3Packages.pandas python3Packages.python-pptx pandoc typst
```

### Persistent (home-manager)

```nix
home.packages = with pkgs; [
  pandoc typst
  (python3.withPackages (ps: with ps; [
    markitdown openpyxl pandas python-pptx xlsx2csv
  ]))
];
```

## Ubuntu/Debian Installation

```bash
sudo apt install pandoc texlive-base
pip install markitdown pandas openpyxl python-pptx xlsx2csv
```

## macOS Installation

```bash
brew install pandoc typst
pip3 install markitdown pandas openpyxl python-pptx xlsx2csv
```

## Verification Commands

```bash
command -v markitdown pandoc typst pdflatex
python3 -c "import pandas, openpyxl, pptx"
```
