local function fail(message)
  error(message, 0)
end

local function assert_equal(actual, expected, label)
  if actual ~= expected then
    fail(string.format("%s: expected %q, got %q", label, tostring(expected), tostring(actual)))
  end
end

local function assert_true(value, label)
  if not value then
    fail(label .. ": expected true")
  end
end

local function assert_nil(value, label)
  if value ~= nil then
    fail(string.format("%s: expected nil, got %q", label, tostring(value)))
  end
end

local function choice_key(choice)
  return choice.kind .. "\0" .. tostring(choice.path or choice.name or "<system>")
end

local root = vim.fn.tempname()
local project = root .. "/project"
local declared_project = root .. "/declared-project"
local git_project = root .. "/git-project"
local standalone = root .. "/standalone.py"
local standalone_other = root .. "/standalone-other.py"
local nearest_project = root .. "/nearest-project"
local broken_project = root .. "/broken-project"
local dangling_project = root .. "/dangling-project"
local dangling_bin_project = root .. "/dangling-bin-project"
local nested_scope_parent = root .. "/scope-parent"
local nested_scope_child = nested_scope_parent .. "/child"
local invalid_project = root .. "/invalid-project"
local nonexec_project = root .. "/nonexec-project"
local venv_root = root .. "/managed"
local shared_root = venv_root

local function mkdir(path)
  vim.fn.mkdir(path, "p")
end

local function python_fixture(path)
  mkdir(path .. "/bin")
  local python_path = path .. "/bin/python"
  vim.fn.writefile({ "#!/bin/sh" }, python_path)
  vim.fn.setfperm(python_path, "rwxr-xr-x")
end

mkdir(project .. "/nested/package")
vim.fn.writefile({ "[project]", "name = 'local-project'" }, project .. "/pyproject.toml")
python_fixture(project .. "/.venv")
vim.fn.writefile({ "shared" }, project .. "/.pyvenv")

mkdir(declared_project .. "/src")
vim.fn.writefile({ "shared" }, declared_project .. "/.pyvenv")
python_fixture(shared_root .. "/shared")
python_fixture(venv_root .. "/manual")
python_fixture(venv_root .. "/nested/hidden")

mkdir(git_project .. "/src")
mkdir(git_project .. "/.git")
python_fixture(venv_root .. "/git-project")
python_fixture(git_project .. "/.venv")

mkdir(root .. "/other")
python_fixture(root .. "/other/.venv")
vim.fn.writefile({ "standalone" }, standalone)
vim.fn.writefile({ "standalone-other" }, standalone_other)

mkdir(nearest_project .. "/src/deep")
vim.fn.writefile({ "[project]" }, nearest_project .. "/pyproject.toml")
python_fixture(nearest_project .. "/.venv")
python_fixture(nearest_project .. "/src/.venv")

mkdir(broken_project .. "/src")
vim.fn.writefile({ "[project]" }, broken_project .. "/pyproject.toml")
mkdir(venv_root .. "/broken/bin")
vim.fn.writefile({ "", " missing-target " }, broken_project .. "/.pyvenv")

mkdir(dangling_project .. "/src")
vim.fn.writefile({ "[project]" }, dangling_project .. "/pyproject.toml")
vim.fn.writefile({ "dangling" }, dangling_project .. "/.pyvenv")
vim.uv.fs_symlink(root .. "/does-not-exist", venv_root .. "/dangling")

mkdir(dangling_bin_project .. "/broken-bin/bin")
vim.uv.fs_symlink(root .. "/does-not-exist", dangling_bin_project .. "/broken-bin/bin/python")
vim.fn.writefile({ "broken-bin" }, dangling_bin_project .. "/.pyvenv")

mkdir(nested_scope_parent .. "/src")
vim.fn.writefile({ "[project]" }, nested_scope_parent .. "/pyproject.toml")
mkdir(nested_scope_child .. "/src")
vim.fn.writefile({ "[project]" }, nested_scope_child .. "/pyproject.toml")

mkdir(invalid_project .. "/src")
vim.fn.writefile({ "[project]" }, invalid_project .. "/pyproject.toml")
vim.fn.writefile({ "../manual" }, invalid_project .. "/.pyvenv")

mkdir(nonexec_project .. "/src")
vim.fn.writefile({ "[project]" }, nonexec_project .. "/pyproject.toml")
mkdir(venv_root .. "/nonexec/bin")
local nonexec_python = venv_root .. "/nonexec/bin/python"
vim.fn.writefile({ "#!/bin/sh" }, nonexec_python)
vim.fn.setfperm(nonexec_python, "rw-r--r--")

vim.env.CHENHUN_PYTHON_VENV_ROOT = venv_root
vim.opt.rtp:prepend(vim.fn.getcwd() .. "/home/base/tui/nvim/config")
package.loaded["chenhun.core.python_venv"] = nil

local python_venv = require("chenhun.core.python_venv")
local test_api = python_venv._test
assert_true(test_api, "test-facing API")
assert_true(test_api.resolve_project_root, "resolve_project_root helper")
assert_true(test_api.resolve_state, "resolve_state helper")
assert_true(test_api.list_choices, "list_choices helper")
for _, name in ipairs({
  "resolve_project_root", "get_current_venv", "get_current_python_path",
  "get_pyright_client_name", "is_managed_pyright_client", "register_managed_pyright",
  "cleanup_ghost_pyright", "get_pyright_python_settings_for_path", "get_pyright_python_settings",
  "sync_for_path", "set_venv", "choose_venv", "on_pyright_attach", "autoset_venv",
  "show_session_status", "lualine_component",
}) do
  assert_true(type(python_venv[name]) == "function", "public API " .. name)
end

assert_equal(test_api.resolve_project_root(project .. "/nested/package/main.py"), project, "pyproject root")
assert_equal(test_api.resolve_project_root(declared_project .. "/src/main.py"), declared_project, "pyvenv root")
assert_equal(test_api.resolve_project_root(git_project .. "/src/main.py"), git_project, "git root")
assert_nil(test_api.resolve_project_root(standalone), "standalone root")

local local_state = test_api.resolve_state(project .. "/nested/package/main.py")
assert_equal(local_state.kind, "local", "local environment kind")
assert_equal(local_state.name, ".venv", "local environment name")
assert_equal(local_state.path, project .. "/.venv", "local environment path")
assert_equal(local_state.python_path, project .. "/.venv/bin/python", "local interpreter path")

local declared_with_local_state = test_api.resolve_state(project .. "/nested/package/main.py")
assert_equal(declared_with_local_state.kind, "local", "local priority over declared shared")
assert_equal(declared_with_local_state.name, ".venv", "local name over declared shared")

local declared_state = test_api.resolve_state(declared_project .. "/src/main.py")
assert_equal(declared_state.kind, "shared", "declared environment kind")
assert_equal(declared_state.name, "shared", "declared environment name")
assert_equal(declared_state.path, shared_root .. "/shared", "declared environment path")
assert_equal(declared_state.python_path, shared_root .. "/shared/bin/python", "declared interpreter path")

assert_equal(test_api.resolve_state(nearest_project .. "/src/deep/main.py").path, nearest_project .. "/src/.venv", "nearest local environment")
assert_equal(test_api.resolve_state(declared_project .. "/src/main.py", { manual = " shared " }).name, " shared ", "manual name remains explicit")

local broken_state = test_api.resolve_state(broken_project .. "/src/main.py")
assert_equal(broken_state.kind, "broken", "missing declared environment")
assert_equal(broken_state.name, "missing-target", "broken declared name")
assert_equal(broken_state.python_path, vim.g.python3_host_prog, "broken state uses system interpreter")

local dangling_state = test_api.resolve_state(dangling_project .. "/src/main.py")
assert_equal(dangling_state.kind, "broken", "dangling shared environment")
assert_equal(dangling_state.path, venv_root .. "/dangling", "dangling environment path")
local dangling_bin_state = test_api.resolve_state(dangling_bin_project .. "/src/main.py")
assert_equal(dangling_bin_state.kind, "broken", "dangling bin/python")

assert_equal(test_api.resolve_state(invalid_project .. "/src/main.py").kind, "system", "invalid declared traversal")
for _, invalid_name in ipairs({ "", "/tmp/outside", "../manual", "nested/name" }) do
  assert_equal(test_api.resolve_state(project .. "/nested/package/main.py", { manual = invalid_name }).kind, "system", "invalid shared name " .. invalid_name)
end
local nonexec_state = test_api.resolve_state(nonexec_project .. "/src/main.py", { manual = "nonexec" })
assert_equal(nonexec_state.kind, "broken", "non-executable interpreter")

local manual_state = test_api.resolve_state(project .. "/nested/package/main.py", { manual = "manual" })
assert_equal(manual_state.kind, "shared", "manual environment kind")
assert_equal(manual_state.name, "manual", "manual override priority")

local system_state = test_api.resolve_state(project .. "/nested/package/main.py", { manual = "system" })
assert_equal(system_state.kind, "system", "system environment kind")
assert_nil(system_state.name, "system environment name")
assert_nil(system_state.path, "system environment path")
assert_true(type(system_state.python_path) == "string" and system_state.python_path ~= "", "system interpreter fallback")

local choices = test_api.list_choices(project .. "/nested/package/main.py")
local allowed_shared_paths = {
  [venv_root .. "/shared"] = true,
  [venv_root .. "/manual"] = true,
  [venv_root .. "/git-project"] = true,
  [venv_root .. "/nested"] = true,
  [venv_root .. "/broken"] = true,
  [venv_root .. "/nonexec"] = true,
}
local expected_choice_keys = {
  ["local\0" .. project .. "/.venv"] = true,
  ["shared\0" .. venv_root .. "/shared"] = true,
  ["shared\0" .. venv_root .. "/manual"] = true,
  ["shared\0" .. venv_root .. "/git-project"] = true,
  ["broken\0" .. venv_root .. "/nested"] = true,
  ["broken\0" .. venv_root .. "/broken"] = true,
  ["broken\0" .. venv_root .. "/nonexec"] = true,
  ["system\0<system>"] = true,
}
assert_equal(#choices, vim.tbl_count(expected_choice_keys), "chooser choice count")
local seen_choices = {}
for _, choice in ipairs(choices) do
  local is_current_local = choice.kind == "local" and choice.path == project .. "/.venv"
   local is_direct_shared = (choice.kind == "shared" or choice.kind == "broken") and allowed_shared_paths[choice.path] == true
  local is_system = choice.kind == "system" and choice.name == nil
  if not (is_current_local or is_direct_shared or is_system) then
    fail("chooser unexpected choice: " .. tostring(choice.kind) .. " " .. tostring(choice.path or choice.name))
  end

  local key = choice_key(choice)
  if seen_choices[key] then
    fail("chooser duplicate choice: " .. key)
  end
  seen_choices[key] = true
end
for key in pairs(expected_choice_keys) do
  assert_true(seen_choices[key], "chooser expected choice " .. key)
end

local broken_choices = test_api.list_choices(broken_project .. "/src/main.py")
local saw_broken = false
for _, choice in ipairs(broken_choices) do
  if choice.name == "broken" then saw_broken = true end
end
assert_true(saw_broken, "chooser keeps broken direct shared entry")

local shared_settings = python_venv.get_pyright_python_settings_for_path(declared_project .. "/src/main.py")
assert_equal(shared_settings.pythonPath, shared_root .. "/shared/bin/python", "shared Pyright pythonPath")
assert_equal(shared_settings.venvPath, venv_root, "shared Pyright venvPath")
assert_equal(shared_settings.venv, "shared", "shared Pyright venv")
local local_settings = python_venv.get_pyright_python_settings_for_path(project .. "/nested/package/main.py")
assert_equal(local_settings.venvPath, project, "local Pyright venvPath")
assert_equal(local_settings.venv, ".venv", "local Pyright venv")

local original_select = vim.ui.select
local selected_label
vim.api.nvim_buf_set_name(0, project .. "/nested/package/main.py")
vim.ui.select = function(items, _, callback)
  for _, item in ipairs(items) do
    if item:find("local:", 1, true) then selected_label = item; callback(item); return end
  end
  fail("chooser local entry missing")
end
python_venv.choose_venv()
vim.ui.select = original_select
assert_equal(test_api.resolve_state(project .. "/nested/package/main.py").kind, "local", "chooser selects local")

vim.api.nvim_buf_set_name(0, nearest_project .. "/src/deep/main.py")
vim.ui.select = function(items, _, callback)
  for _, item in ipairs(items) do
    if item:find("local:", 1, true) then callback(item); return end
  end
  fail("nested local chooser entry missing")
end
python_venv.choose_venv()
vim.ui.select = original_select
assert_equal(test_api.resolve_state(nearest_project .. "/src/deep/main.py").path, nearest_project .. "/src/.venv", "nested chooser selects local")

local parent_client = { name = "pyright", config = { root_dir = nested_scope_parent, settings = { python = { pythonPath = "parent" } } }, settings = {} }
local child_client = { name = "pyright", config = { root_dir = nested_scope_child, settings = { python = { pythonPath = "child" } } }, settings = {} }
parent_client.notify, child_client.notify = function() end, function() end
local original_get_clients = vim.lsp.get_clients
vim.lsp.get_clients = function() return { parent_client, child_client } end
assert_true(python_venv.set_venv("manual", { path = nested_scope_child .. "/src/main.py" }), "set child environment")
vim.lsp.get_clients = original_get_clients
assert_equal(parent_client.config.settings.python.pythonPath, "parent", "parent Pyright scope unchanged")
assert_equal(child_client.config.settings.python.pythonPath, venv_root .. "/manual/bin/python", "child Pyright scope updated")

local original_path = vim.env.PATH or ""
assert_true(python_venv.set_venv("manual", { path = project .. "/nested/package/main.py" }), "set shared environment")
assert_equal(vim.env.VIRTUAL_ENV, venv_root .. "/manual", "shared VIRTUAL_ENV")
assert_true(vim.env.PATH:match(vim.pesc(venv_root .. "/manual/bin")), "shared PATH entry")
assert_equal(vim.g.python3_host_prog, venv_root .. "/manual/bin/python", "shared host interpreter")
assert_true(python_venv.set_venv("system", { path = project .. "/nested/package/main.py" }), "suppress project environment")
assert_nil(vim.env.VIRTUAL_ENV, "system VIRTUAL_ENV")
assert_nil(vim.env.PATH:match(vim.pesc(venv_root .. "/manual/bin")), "system removes old PATH entry")
assert_equal(vim.g.python3_host_prog, vim.fn.exepath("python3"), "system host interpreter")
vim.env.PATH = original_path

assert_true(python_venv.set_venv("manual", { path = standalone }), "set standalone fallback")
assert_equal(test_api.resolve_state(standalone).name, "manual", "standalone fallback applies")
assert_equal(test_api.resolve_state(standalone_other).kind, "system", "standalone fallback does not leak")
assert_true(python_venv.set_venv("system", { path = standalone }), "clear standalone fallback")

print("python_venv_test: assertions passed")
