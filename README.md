# Atlantis Ecosystem Model Wiki

This repository contains the Atlantis Ecosystem Model documentation, converted from Confluence Wiki to a [Quarto](https://quarto.org/) website.

**Live site:** https://jacobkasper.github.io/atlantis-wiki/

## About

The Atlantis Ecosystem Model is a deterministic biogeochemical whole-of-ecosystem model designed to support ecosystem-based management and marine spatial planning.

## Conversion Process

This Quarto site was generated from a Confluence Wiki export using a custom Python conversion script (`convert_to_quarto.py`). The conversion process involved:

### 1. HTML to Markdown Conversion

- Parsed Confluence HTML export files using BeautifulSoup
- Converted HTML content to Markdown using the `markdownify` library
- Preserved page titles, authors, and hierarchical structure

### 2. Asset Handling

- **Attachments**: Flattened nested attachment directories (`attachments/12345/file.pdf` → `attachments/file.pdf`)
- **Equation images**: Copied LaTeX equation PNGs from `download/export/` to `equations/`
- **Images**: Preserved icons and other images

### 3. Link Fixing

- Converted internal `.html` links to `.qmd` links
- Fixed attachment paths to use flattened structure
- Fixed equation image paths (`download/export/*.png` → `equations/*.png`)
- Removed problematic Confluence plugin paths (e.g., `com.atlassian.confluence.plugins...`)

### 4. Confluence-Specific Element Handling

- Converted Confluence info/warning/tip panels to Quarto callouts
- Extracted LaTeX equations from `latexmath-mathblock` tables
- Removed emoticon images (replaced with alt text)
- Cleaned up code blocks

## Changelog Consolidation

A major enhancement was consolidating version history from multiple scattered sources into a single **Changelog** page.

### Sources Consolidated

The changelog pulls information from these sources:

| Source | Content Type |
|--------|--------------|
| `Atlantis-Updates` page | Table with Revision, Date, and Content columns (2016-2020) |
| `Atlantis-Bug-Fixes-and-Versions` page | Table with Date, Revision, Author, JIRA Issue, and Notes |
| `downloaded_pages/YYYY/Mon/*.html` | Individual blog posts organized by year/month (2008-2023) |
| `Redev` page | Embedded blog post listings |
| `Changes-made-to-the-input-files` page | Embedded blog post listings with `inputchanges` label |

### Changelog Features

- **Sorted by date** (newest first)
- **Grouped by year** for easy navigation
- **Version numbers** extracted from content (e.g., "v 6678")
- **Deduplicated** entries with same version and similar titles
- **Full text** displayed for entries without dedicated pages
- **Linked titles** for entries that have dedicated blog post pages (in `posts/` folder)

### Pages Removed (Consolidated into Changelog)

The following pages were **not converted** as standalone pages because their content was consolidated into the Changelog:

| Original Page | Reason |
|---------------|--------|
| `Atlantis-Updates` | Table entries moved to Changelog |
| `Atlantis-Bug-Fixes-and-Versions` | Table entries moved to Changelog |
| `Redev` | Embedded blog listings moved to Changelog |
| `Changes-made-to-the-input-files` | Embedded blog listings moved to Changelog |

### Blog Posts Converted to Individual Pages

Blog posts from `downloaded_pages/` were converted to individual `.qmd` files in the `posts/` folder, with:
- Full content preserved
- Date extracted from metadata or folder structure
- Version number extracted from content
- Author information preserved
- Back-link to Changelog

## Data Fixes Applied

During conversion, the following data issues were automatically corrected:

| Issue | Fix |
|-------|-----|
| Date typo "19/July/12016" | Corrected to "19/July/2016" via regex |
| Truncated descriptions | Full text preserved for entries without linked pages |

## Repository Structure

```
atlantis-wiki/
├── _quarto.yml          # Quarto configuration
├── index.qmd            # Home page
├── changelog.qmd        # Consolidated version history
├── *.qmd                # Converted wiki pages
├── posts/               # Individual blog post pages
│   └── *.qmd
├── attachments/         # PDF, DOCX, PPTX, and other attachments
├── equations/           # LaTeX equation PNG images
├── images/              # Icons and other images
├── styles.css           # Custom CSS
└── .github/
    └── workflows/
        └── publish.yml  # GitHub Actions deployment
```

## Building Locally

### Prerequisites

- [Quarto](https://quarto.org/docs/get-started/) (v1.3 or later)
- Python 3.x (only needed if re-running conversion)

### Preview

```bash
quarto preview
```

### Render

```bash
quarto render
```

The rendered site will be in the `_site/` folder.

## Re-running the Conversion

If you need to re-convert from the original Confluence export:

### Prerequisites

```bash
pip install beautifulsoup4 markdownify lxml
```

### Run Conversion

Place `convert_to_quarto.py` in the Confluence export directory (with the `.html` files) and run:

```bash
python convert_to_quarto.py
```

This will create/overwrite the `quarto_site/` folder.

## Deployment

This site is automatically deployed to GitHub Pages via GitHub Actions when changes are pushed to the `main` branch.

## License

The Atlantis Ecosystem Model documentation is maintained by CSIRO. See the original [Confluence Wiki](https://confluence.csiro.au/display/Atlantis) for licensing information.

## Credits

- **Original Wiki**: CSIRO Atlantis Team (Beth Fulton, Bec Gorton, and contributors)
- **Conversion**: Automated conversion script developed with assistance from Claude (Anthropic)
