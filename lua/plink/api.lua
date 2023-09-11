local _ = require('neodash')
local curl_ok, curl = pcall(require, 'plenary.curl')
local job_ok, Job = pcall(require, 'plenary.job')
if not curl_ok or not job_ok then
  vim.notify_once('Missing required dependency: nvim-lua/plenary.nvim')
  return
end

---@alias PluginResult {description: string, name: string, score: number, stars: number, tags: string[], url: string}

local base_url = 'https://3051j7te1j.execute-api.us-east-1.amazonaws.com'

local M = {}

local function parse_querystring(qs)
  return string.gsub(qs, ' ', '%%20')
end

local function build_url(route, querystring_params)
  local url = base_url .. route

  if querystring_params then
    local params = {}
    for key, value in pairs(querystring_params) do
      table.insert(params, key .. '=' .. parse_querystring(value))
    end
    url = url .. '?' .. table.concat(params, '&')
  end

  return url
end

---@param query string
---@return PluginResult[] | nil
M.search = function(query)
  local res = curl.get({
    url = build_url('/search', {
      q = query,
      -- testDelay = 1000,
    }),
  })

  if res.status == 200 then
    local json = vim.fn.json_decode(res.body)
    if not json then
      error 'error decoding json'
    end

    return json.results
  end

  error('api returned non 200 status: ' .. res.status)
end

M.search_job = function(query, handler)
  local url = build_url('/search', {
    q = query,
    testDelay = 1000,
  })

  Job:new({
    command = 'curl',
    args = { url },
    on_exit = function(response, exit_code)
      local data = response:result()
      -- local res = vim.fn.json_decode(data)
      vim.schedule(function()
        local json = vim.fn.json_decode(data[1])
        json = json or { results = {} }
        handler(json.results)
      end)
    end
  }):start()
end

return M
