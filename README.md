# i18n Translation Files

This repository hosts the translation files (JSON format) used by the [gge-tracker.com](https://gge-tracker.com).

The goal is to provide an easy and open way for contributors to help improve or add translations.

## How to Contribute

1. **Fork** this repository.
2. **Edit** the language file you want to improve (`fr.json`, `en.json`, etc.) or **add a new one** (e.g., `es.json` for Spanish).
3. **Validate** your JSON file to ensure it is correctly formatted (using tools/check.sh)
4. **Submit a Pull Request** with your changes.

We will review and merge valid contributions regularly. The updated translations will be automatically published via GitHub Pages. All changes will be reflected on [gge-tracker.com](https://gge-tracker.com) in the next deployment cycle.

## Guidelines

- Keep the JSON syntax valid — use a JSON linter or formatter if needed.
- Try to follow the tone and style used in other translations.
- Do not rename existing keys unless absolutely necessary.

## How to test

- Open [gge-tracker.com](https://gge-tracker.com)
- Open your browser's Developer Tools (usually F12 or Ctrl+Shift+I)
- Go to the 'Console tab' and paste the following code:
  ```js
  const lang = { /* your translation content */ };
  localStorage.setItem('lang_dev', JSON.stringify(lang));
  ```
- Reload the page
The application will now load your custom translations from localStorage instead of the default files.
---

Thank you for contributing!
