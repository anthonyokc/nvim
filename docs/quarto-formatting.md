# Quarto R Formatting

Quarto and `qmd` formatting is configured in `lua/plugins/languages/quarto.lua`.

## Current Behavior

- `qmd`, `quarto`, and `rmd` buffers use `conform.nvim` with a custom formatter named `injected_r`.
- `injected_r` uses Conform's injected-language support to format embedded code blocks instead of the whole markdown document.
- Embedded R code is formatted with `styler::style_text(...)` through a custom formatter named `styler_text`.
- In `qmd` and `quarto` buffers, `<leader>F` is remapped buffer-locally to `require('conform').format(...)`.

## Why It Is Configured This Way

This ended up being the least brittle option that still matches normal R formatting behavior.

### Why not `otter.nvim`

`otter.nvim` does not implement formatting forwarding. Its README explicitly calls out formatting as a limitation and points users to `conform.nvim`'s `injected` formatter for embedded languages.

### Why not plain LSP formatting

The attached R client in this config is `r_ls`, and it does not advertise `textDocument/formatting` or `textDocument/rangeFormatting`.

That means `vim.lsp.buf.format()` is not what formats plain `.R` buffers here.

### Why not call `R.nvim` directly from Quarto

That was tried first and turned out to be too coupled to `R.nvim` internals.

Problems with that approach:

- ranged `:RFormat` calls hit `R.nvim`'s text-formatting path, which produced escape-string errors in Quarto chunks
- the implementation depended on how `R.nvim` currently distinguishes whole-buffer vs range formatting
- a config-side shim around plugin internals is more likely to break on upstream changes

### Why not use Conform's built-in `styler`

Conform's built-in `styler` formatter uses `styler::style_file(...)` on a temp file.

That failed for injected chunk formatting after we changed the temp extension to avoid `R.nvim` side effects:

- `styler` rejected the temp file because it was not an `.R`, `.Rmd`, `.Rnw`, or `.qmd` file

### Why `styler_text`

`styler_text` uses:

```r
writeLines(styler::style_text(readLines(file("stdin"))))
```

Benefits:

- does not depend on a temp filename or extension
- formats just the injected R text
- stays close to the formatting behavior used by `R.nvim`
- avoids direct coupling to `R.nvim` commands or private behavior

### Why the fake `rconform` extension still exists

Conform's injected formatter creates temporary per-language buffers/files.

When those temporary R buffers looked like normal R files, `R.nvim` would attach to them and start sending messages to `r_ls`, which caused repeated warnings like:

```text
Failed to send message to r_ls: { code = "N20" }
```

Using a non-R temp extension prevents `R.nvim` from treating Conform's temporary injected buffers as normal R editing buffers.

## What Would Need To Change To Remove This Workaround

Any one of these would allow a simpler setup:

1. `otter.nvim` adds built-in formatting support for embedded languages.
2. Your R LSP client starts supporting `textDocument/formatting` for the actual buffers you edit.
3. `R.nvim` exposes a stable public API specifically for formatting embedded Quarto/Rmd chunks without relying on command-range behavior.
4. `conform.nvim` injected formatting gains a clean way to run R formatters without temp files being treated as real R buffers.
5. `R.nvim` stops reacting to Conform's temporary injected buffers, making it safe to use file-based `styler` directly.

If one of those becomes true, the config could likely be reduced to one of these simpler models:

- plain `vim.lsp.buf.format()` on `<leader>F`
- `conform.nvim` with stock `injected` + stock `styler`
- direct formatting through a future Quarto-aware formatter API

## Useful Checks

In a `qmd` buffer:

```vim
:ConformInfo
:lua print(vim.inspect(require("conform").list_formatters_to_run(0)))
:verbose nmap <leader>F
```

In an `R` buffer:

```vim
:lua for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do print(c.name, c:supports_method("textDocument/formatting"), c:supports_method("textDocument/rangeFormatting")) end
```
