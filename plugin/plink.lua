vim.api.nvim_create_user_command('PlinkSearch', function(query)
  require('plink').search()
end, { nargs = 1 })
