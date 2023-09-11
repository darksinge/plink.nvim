local M = {}

function M.raise(msg, level)
  level = level or vim.log.levels.ERROR
  error('ERROR(plink.nvim) ' .. msg, level)
end

function M.raise_not_implemented(msg)
  M.raise(msg or 'not implemented')
end

return M
