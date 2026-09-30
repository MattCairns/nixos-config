---
name: pdf
description: Convert PDF files to markdown for reading and extraction. Use when the user asks to read, analyze, or extract content from PDF files.
---

# PDF Processing

## Quick start

Use markitdown to convert a PDF to markdown:

```bash
nix run nixpkgs#python313Packages.markitdown -- "path/to/file.pdf" > output.md
```

Remember to quote file paths that contain spaces.
