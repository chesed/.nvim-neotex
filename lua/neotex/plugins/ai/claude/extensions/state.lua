-- neotex.plugins.ai.claude.extensions.state
-- Claude extension state tracking (delegates to shared)

local shared_state = require("neotex.plugins.ai.shared.extensions.state")
local config = require("neotex.plugins.ai.claude.extensions.config")

local M = {}

local claude_config = config.get()

--- Read extensions.json from target project
--- @param project_dir string|nil Project directory (defaults to cwd)
--- @return table state Extension state (empty if file doesn't exist)
function M.read(project_dir)
  return shared_state.read(project_dir, claude_config)
end

--- Write extensions.json to target project
--- @param project_dir string|nil Project directory (defaults to cwd)
--- @param state table Extension state to write
--- @return boolean success True if write succeeded
function M.write(project_dir, state)
  return shared_state.write(project_dir, state, claude_config)
end

--- Mark an extension as loaded in state
--- @param state table Current state
--- @param extension_name string Extension name
--- @param manifest table Extension manifest
--- @param installed_files table Array of installed file paths
--- @param installed_dirs table Array of created directories
--- @param merged_sections table|nil Map of merge operations performed
--- @return table state Updated state
function M.mark_loaded(state, extension_name, manifest, installed_files, installed_dirs, merged_sections)
  return shared_state.mark_loaded(state, extension_name, manifest, installed_files, installed_dirs, merged_sections)
end

--- Mark an extension as unloaded in state
--- @param state table Current state
--- @param extension_name string Extension name
--- @return table state Updated state
function M.mark_unloaded(state, extension_name)
  return shared_state.mark_unloaded(state, extension_name)
end

--- Check if an extension is loaded
--- @param state table Current state
--- @param extension_name string Extension name
--- @return boolean loaded True if extension is loaded
function M.is_loaded(state, extension_name)
  return shared_state.is_loaded(state, extension_name)
end

--- Get loaded extension info
--- @param state table Current state
--- @param extension_name string Extension name
--- @return table|nil info Extension info or nil if not loaded
function M.get_extension_info(state, extension_name)
  return shared_state.get_extension_info(state, extension_name)
end

--- Get installed files for an extension
--- @param state table Current state
--- @param extension_name string Extension name
--- @return table files Array of installed file paths
function M.get_installed_files(state, extension_name)
  return shared_state.get_installed_files(state, extension_name)
end

--- Get installed directories for an extension
--- @param state table Current state
--- @param extension_name string Extension name
--- @return table dirs Array of installed directory paths
function M.get_installed_dirs(state, extension_name)
  return shared_state.get_installed_dirs(state, extension_name)
end

--- Get merged sections for an extension
--- @param state table Current state
--- @param extension_name string Extension name
--- @return table sections Map of merged sections
function M.get_merged_sections(state, extension_name)
  return shared_state.get_merged_sections(state, extension_name)
end

--- Check if extension needs update (version comparison)
--- @param state table Current state
--- @param extension_name string Extension name
--- @param current_version string Current manifest version
--- @return boolean needs_update True if extension needs update
function M.needs_update(state, extension_name, current_version)
  return shared_state.needs_update(state, extension_name, current_version)
end

--- List all loaded extensions
--- @param state table Current state
--- @return table extensions Array of extension names
function M.list_loaded(state)
  return shared_state.list_loaded(state)
end

return M
