local templates = require "obsidian.templates"
local log = require "obsidian.log"
local util = require "obsidian.util"

---@param client obsidian.Client
---@param data CommandArgs
return function(client, data)
  local templates_dir = client:templates_dir()
  if not templates_dir then
    log.err "Templates folder is not defined or does not exist"
    return
  end

  -- We need to get this upfront before the picker hijacks the current window.
  local insert_location = util.get_active_window_cursor_location()

  local function insert_template(name)
    templates.insert_template {
      type = "insert_template",
      template_name = name,
      template_opts = client.opts.templates,
      templates_dir = templates_dir,
      location = insert_location,
    }
  end

  if string.len(data.args) > 0 then
    local template_name = util.strip_whitespace(data.args)
    insert_template(template_name)
    return
  end

  local picker = client:picker()
  if not picker then
    log.err "No picker configured"
    return
  end

  picker:find_templates {
    callback = function(path)
      insert_template(path)
    end,
  }
end
