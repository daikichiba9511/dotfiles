-- basedpyright LSP configuration
--
-- Default: openFiles + basic (performance-first)
-- With pyrightconfig.json or pyproject.toml [tool.pyright/basedpyright]:
--   diagnosticMode upgrades to "workspace" (project config controls scope)

--- Check if project has pyright configuration
---@param root string
---@return boolean
local function has_pyright_config(root)
  if vim.uv.fs_stat(root .. "/pyrightconfig.json") then
    return true
  end
  local pyproject_path = root .. "/pyproject.toml"
  if not vim.uv.fs_stat(pyproject_path) then
    return false
  end
  for _, line in ipairs(vim.fn.readfile(pyproject_path)) do
    if line:match("^%[tool%.pyright") or line:match("^%[tool%.basedpyright") then
      return true
    end
  end
  return false
end

return {
  settings = {
    basedpyright = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "openFiles",
        typeCheckingMode = "basic",
      },
    },
    python = {
      analysis = {
        inlayHints = {
          variableTypes = true,
          functionReturnTypes = true,
          callArgumentNames = true,
          pytestParameters = true,
        },
      },
    },
  },
  on_init = function(client)
    local root = client.root_dir
    if not root or not has_pyright_config(root) then
      return
    end
    client.settings.basedpyright.analysis.diagnosticMode = "workspace"
    client:notify("workspace/didChangeConfiguration", {
      settings = client.settings,
    })
  end,
}
