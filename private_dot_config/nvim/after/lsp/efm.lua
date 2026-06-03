-- efm-langserver: wraps CLI linters as LSP diagnostics for markdown (textlint)
return {
  filetypes = { "markdown" },
  root_markers = { ".textlintrc", ".textlintrc.json", "package.json", ".git" },
  init_options = {
    documentFormatting = false,
    documentRangeFormatting = false,
    codeAction = false,
    hover = false,
    completion = false,
  },
  settings = {
    languages = {
      markdown = {
        {
          lintCommand = "textlint --no-color --format compact --stdin --stdin-filename ${INPUT}",
          lintStdin = true,
          lintFormats = { "%f:line %l:column %c: %m" },
          rootMarkers = { ".textlintrc", ".textlintrc.json", "package.json" },
        },
      },
    },
  },
}
