local dynamic_methods = {
  "codeAction",
  "codeLens",
  "completion",
  "definition",
  "diagnostic",
  "documentHighlight",
  "formatting",
  "hover",
  "inlayHint",
  "rangeFormatting",
  "references",
  "rename",
  "signatureHelp",
}

local text_document = {}
for _, method in ipairs(dynamic_methods) do
  text_document[method] = {
    dynamicRegistration = true,
  }
end

return {
  capabilities = {
    textDocument = text_document,
  },
}
