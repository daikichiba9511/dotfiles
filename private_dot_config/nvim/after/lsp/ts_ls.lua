local javascript_root_markers = {
  { "bun.lock", "bun.lockb", "package-lock.json", "pnpm-lock.yaml", "yarn.lock" },
  { "bunfig.toml", "package.json" },
  { ".git" },
}

local function is_deno_project(bufnr, project_root)
  local deno_root = vim.fs.root(bufnr, { "deno.json", "deno.jsonc" })
  local deno_lock_root = vim.fs.root(bufnr, { "deno.lock" })

  return (deno_lock_root and (not project_root or #deno_lock_root > #project_root))
    or (deno_root and (not project_root or #deno_root >= #project_root))
end

local function uses_bun(root)
  if
    vim.uv.fs_stat(vim.fs.joinpath(root, "bun.lock"))
    or vim.uv.fs_stat(vim.fs.joinpath(root, "bun.lockb"))
    or vim.uv.fs_stat(vim.fs.joinpath(root, "bunfig.toml"))
  then
    return true
  end

  local package_json = vim.fs.joinpath(root, "package.json")
  if not vim.uv.fs_stat(package_json) then
    return false
  end

  local package = vim.json.decode(table.concat(vim.fn.readfile(package_json), "\n"))
  return type(package.packageManager) == "string" and vim.startswith(package.packageManager, "bun@")
end

local function language_server_cli()
  local executable = vim.fn.exepath("typescript-language-server")
  assert(executable ~= "", "typescript-language-server is not installed")
  return assert(vim.uv.fs_realpath(executable), "cannot resolve typescript-language-server")
end

return {
  init_options = {
    disableAutomaticTypingAcquisition = true,
    tsserver = {
      useSyntaxServer = "never",
    },
  },
  root_dir = function(bufnr, on_dir)
    local project_root = vim.fs.root(bufnr, javascript_root_markers)
    if not is_deno_project(bufnr, project_root) then
      on_dir(project_root or vim.fn.getcwd())
    end
  end,
  cmd = function(dispatchers, config)
    local root = assert(config.root_dir, "ts_ls requires a project root")
    local runtime = uses_bun(root) and "bun" or "node"
    local command = runtime == "bun" and { runtime, "--smol" } or { runtime }
    vim.list_extend(command, { language_server_cli(), "--stdio" })
    return vim.lsp.rpc.start(command, dispatchers)
  end,
}
