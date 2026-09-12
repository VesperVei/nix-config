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
local venv_root = root .. "/managed"
local shared_root = venv_root

local function mkdir(path)
  vim.fn.mkdir(path, "p")
end

local function python_fixture(path)
  mkdir(path .. "/bin")
  vim.fn.writefile({ "#!/bin/sh" }, path .. "/bin/python")
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

vim.env.CHENHUN_PYTHON_VENV_ROOT = venv_root
vim.opt.rtp:prepend(vim.fn.getcwd() .. "/home/base/tui/nvim/config")
package.loaded["chenhun.core.python_venv"] = nil

local python_venv = require("chenhun.core.python_venv")
local test_api = python_venv._test
assert_true(test_api, "test-facing API")
assert_true(test_api.resolve_project_root, "resolve_project_root helper")
assert_true(test_api.resolve_state, "resolve_state helper")
assert_true(test_api.list_choices, "list_choices helper")

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
}
local expected_choice_keys = {
  ["local\0" .. project .. "/.venv"] = true,
  ["shared\0" .. venv_root .. "/shared"] = true,
  ["shared\0" .. venv_root .. "/manual"] = true,
  ["shared\0" .. venv_root .. "/git-project"] = true,
  ["system\0<system>"] = true,
}
assert_equal(#choices, vim.tbl_count(expected_choice_keys), "chooser choice count")
local seen_choices = {}
for _, choice in ipairs(choices) do
  local is_current_local = choice.kind == "local" and choice.path == project .. "/.venv"
  local is_direct_shared = choice.kind == "shared" and allowed_shared_paths[choice.path] == true
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

print("python_venv_test: assertions passed")
