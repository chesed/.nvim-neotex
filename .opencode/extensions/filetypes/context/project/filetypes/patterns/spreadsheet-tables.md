# Spreadsheet to Table Conversion Patterns

Patterns for converting spreadsheet data (XLSX, CSV, ODS) to LaTeX and Typst table formats.

## LaTeX Table Generation

### pandas DataFrame.to_latex()

```python
import pandas as pd

df = pd.read_excel("data.xlsx")
latex = df.to_latex(
    index=False,
    escape=True,
    header=True,
    column_format='l' + 'r' * (len(df.columns) - 1)
)
```

### booktabs Package Integration

```latex
\usepackage{booktabs}
```

## Typst Table Generation

### Using csv() Function

```typst
#let data = csv("data.csv")

#table(
  columns: data.first().len(),
  ..data.flatten()
)
```

### Using tabut Package

```typst
#import "@preview/tabut:0.3.0": *

#let data = csv("data.csv")

#tabut(
  data,
  columns: (auto,) * data.first().len(),
  fill: (_, row) => if calc.odd(row) { luma(240) } else { white },
  stroke: none,
)
```

## Multi-Sheet Workbook Handling

```python
import pandas as pd

xl = pd.ExcelFile("workbook.xlsx")
print(xl.sheet_names)

df = pd.read_excel("workbook.xlsx", sheet_name="Data")
```

## Tool Fallback Patterns

### Primary: pandas + openpyxl
- Full Excel feature support

### Fallback: xlsx2csv + pandas
```bash
xlsx2csv data.xlsx data.csv
```

### Basic: markitdown
- Extracts tables as markdown
