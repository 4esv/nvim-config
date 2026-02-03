-- Custom OpenRouter provider for 99 plugin
-- Standalone implementation - no circular dependencies

--- @class OpenRouterProvider
local OpenRouterProvider = {}

--- @param query string
--- @param request _99.Request
--- @return string[]
function OpenRouterProvider._build_command(_, query, request)
  return {
    "/Users/axel/.local/bin/openrouter-99",
    request.context.model,
    request.context.tmp_file,
    query,
  }
end

--- @return string
function OpenRouterProvider._get_provider_name()
  return "OpenRouterProvider"
end

--- @return string
function OpenRouterProvider._get_default_model()
  return "mistralai/codestral-2508"
end

--- @param request _99.Request
function OpenRouterProvider:_retrieve_response(request)
  local tmp = request.context.tmp_file
  local success, result = pcall(function()
    return vim.fn.readfile(tmp)
  end)
  if not success then
    return false, ""
  end
  return true, table.concat(result, "\n")
end

--- @param fn fun(...: any): nil
--- @return fun(...: any): nil
local function once(fn)
  local called = false
  return function(...)
    if called then return end
    called = true
    fn(...)
  end
end

--- @param query string
--- @param request _99.Request
--- @param observer _99.Providers.Observer?
function OpenRouterProvider:make_request(query, request, observer)
  local logger = request.logger:set_area(self:_get_provider_name())
  observer = observer or { on_stdout = function() end, on_stderr = function() end, on_complete = function() end }

  local once_complete = once(function(status, text)
    observer.on_complete(status, text)
  end)

  local command = self:_build_command(query, request)
  logger:debug("make_request", "command", command)

  local proc = vim.system(
    command,
    {
      text = true,
      stdout = vim.schedule_wrap(function(err, data)
        if request:is_cancelled() then
          once_complete("cancelled", "")
          return
        end
        if not err and data then
          observer.on_stdout(data)
        end
      end),
      stderr = vim.schedule_wrap(function(err, data)
        if request:is_cancelled() then
          once_complete("cancelled", "")
          return
        end
        if not err then
          observer.on_stderr(data)
        end
      end),
    },
    vim.schedule_wrap(function(obj)
      if request:is_cancelled() then
        once_complete("cancelled", "")
        return
      end
      if obj.code ~= 0 then
        once_complete("failed", string.format("exit code: %d", obj.code))
        logger:fatal(self:_get_provider_name() .. " make_query failed", "obj", obj)
      else
        vim.schedule(function()
          local ok, res = self:_retrieve_response(request)
          if ok then
            once_complete("success", res)
          else
            once_complete("failed", "unable to retrieve response from temp file")
          end
        end)
      end
    end)
  )

  request:_set_process(proc)
end

return OpenRouterProvider
