local curl_ok, curl = pcall(require, 'plenary.curl')
if not curl_ok then
  vim.notify_once('Install nvim-lua/plenary.nvim to use darksinge/find-tab.nvim')
  return
end

local base_url = 'https://3051j7te1j.execute-api.us-east-1.amazonaws.com'

local M = {}

---@param query string
---@return {description: string, name: string, score: number, stars: number, tags: string[], url: string}[] | nil
M.search = function(query)
  query = string.gsub(query, ' ', '%%20')
  local res = curl.get({
    url = base_url .. '/search?q=' .. query,
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

return M
