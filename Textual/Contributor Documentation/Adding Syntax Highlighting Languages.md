# Adding Syntax Highlighting Languages

Textual uses [Prism.js](https://prismjs.com/) for syntax highlighting. The library bundles
Prism core and language definitions into a single JavaScript file that's embedded in the
framework.

The bundle includes 40+ languages covering web development, systems programming, scripting,
functional programming, data formats, and more. See the LANGUAGES array in
[bundle-prism.sh](../Scripts/bundle-prism.sh) for the complete list.

Prism highlights code by looking up a grammar in `Prism.languages[language]`. Textual passes the
code fence language hint through to Prism as-is, so the identifier you add must match Prism's
language key. If a commonly used fence name is an alias (for example `c++` instead of `cpp`),
it won't highlight unless the input uses Prism's identifier or Textual adds a mapping.

Some Prism components depend on other components, and load order can matter. The bundling
script concatenates the minified component files, so make sure any prerequisites are listed
earlier in `LANGUAGES`.

Adding a language can introduce new token type strings. These will still render, but they may
fall back to the base code style unless the highlighter theme maps them.

## Adding a Language

To add support for a new language:

1. Check if Prism.js supports it at https://prismjs.com/#supported-languages

2. Add the language identifier to the LANGUAGES array in Scripts/bundle-prism.sh. The array is
organized by category (web fundamentals, systems programming, scripting languages, etc.) for
readability.

3. Run the bundle script:
```bash
./Scripts/bundle-prism.sh
```

The script downloads Prism core and all listed language definitions from the Prism CDN, bundles
them into a single JavaScript file, and places it in `Sources/Textual/Internal/Highlighter/Prism/`.

This step requires network access. Runtime highlighting also depends on `JavaScriptCore`; when
it's not available, code blocks fall back to plain text.

4. Verify the change by rendering a fenced code block using the new language hint, and confirm
the output looks reasonable under the default theme.

5. Commit the updated `prism-bundle.js` file with your changes.
