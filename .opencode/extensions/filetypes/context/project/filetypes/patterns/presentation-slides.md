# Presentation Extraction and Slide Generation Patterns

## PPTX Extraction with python-pptx

```python
from pptx import Presentation

prs = Presentation("source.pptx")

for slide in prs.slides:
    for shape in slide.shapes:
        if shape.has_text_frame:
            print(shape.text_frame.text)
```

## Speaker Notes Extraction

```python
def extract_speaker_notes(slide):
    if slide.has_notes_slide:
        return slide.notes_slide.notes_text_frame.text.strip()
    return ""
```

## Beamer Generation (LaTeX)

```latex
\documentclass{beamer}
\usetheme{metropolis}

\begin{document}

\begin{frame}{Slide Title}
  \begin{itemize}
    \item First point
    \item Second point
  \end{itemize}
\end{frame}

\end{document}
```

## Polylux Generation (Typst)

```typst
#import "@preview/polylux:0.3.1": *

#polylux-slide[
  = Slide Title

  - First point
  - Second point
]
```

## Touying Generation (Typst)

```typst
#import "@preview/touying:0.4.0": *

#let s = themes.simple.register()
#show: utils.methods(s).init

== Slide Title

- First point
- Second point
```
