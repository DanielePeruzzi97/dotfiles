-- Enhanced quickfix workflow for project-wide operations
local M = {}

-- Project-wide search and populate quickfix
function M.search_project()
  local search = vim.fn.input("Search pattern: ")
  if search == "" then
    return
  end

  -- Use ripgrep for fast searching
  vim.cmd("silent! grep! " .. vim.fn.shellescape(search))
  
  local qf_size = vim.fn.getqflist({ size = 1 }).size
  if qf_size == 0 then
    vim.notify("No matches found for: " .. search, vim.log.levels.WARN)
    return
  end
  
  vim.cmd("copen")
  vim.notify(string.format("Found %d matches", qf_size), vim.log.levels.INFO)
end

-- Project-wide substitute using quickfix
function M.substitute_project()
  local search = vim.fn.input("Search: ")
  if search == "" then
    return
  end

  local replace = vim.fn.input("Replace with: ")

  -- Populate quickfix with matches
  vim.cmd("silent! grep! " .. vim.fn.shellescape(search))

  local qf_size = vim.fn.getqflist({ size = 1 }).size
  if qf_size == 0 then
    vim.notify("No matches found for: " .. search, vim.log.levels.WARN)
    return
  end

  -- Show quickfix
  vim.cmd("copen")

  -- Confirm before replacing
  local confirm = vim.fn.input(
    string.format("Replace %d matches? (y/n): ", qf_size)
  )
  
  if confirm:lower() == "y" then
    -- Use cfdo to apply substitution to each file in quickfix
    vim.cmd(string.format("cfdo %%s/%s/%s/g | update", 
      vim.fn.escape(search, "/"),
      vim.fn.escape(replace, "/")
    ))
    vim.notify(string.format("Replaced in %d files", qf_size), vim.log.levels.INFO)
  end
end

-- Search word under cursor project-wide
function M.search_word_under_cursor()
  local word = vim.fn.expand("<cword>")
  vim.cmd("silent! grep! " .. vim.fn.shellescape("\\b" .. word .. "\\b"))
  
  local qf_size = vim.fn.getqflist({ size = 1 }).size
  if qf_size > 0 then
    vim.cmd("copen")
    vim.notify(string.format("Found %d matches for '%s'", qf_size, word), vim.log.levels.INFO)
  else
    vim.notify("No matches found for: " .. word, vim.log.levels.WARN)
  end
end

-- Substitute word under cursor project-wide
function M.substitute_word_under_cursor()
  local word = vim.fn.expand("<cword>")
  local replace = vim.fn.input("Replace '" .. word .. "' with: ")
  
  if replace == "" then
    return
  end

  vim.cmd("silent! grep! " .. vim.fn.shellescape("\\b" .. word .. "\\b"))

  local qf_size = vim.fn.getqflist({ size = 1 }).size
  if qf_size == 0 then
    vim.notify("No matches found for: " .. word, vim.log.levels.WARN)
    return
  end

  vim.cmd("copen")

  local confirm = vim.fn.input(
    string.format("Replace %d matches of '%s'? (y/n): ", qf_size, word)
  )
  
  if confirm:lower() == "y" then
    vim.cmd(string.format("cfdo %%s/\\b%s\\b/%s/g | update", 
      vim.fn.escape(word, "/"),
      vim.fn.escape(replace, "/")
    ))
    vim.notify(string.format("Replaced '%s' in %d files", word, qf_size), vim.log.levels.INFO)
  end
end

-- Toggle quickfix window
function M.toggle_quickfix()
  local qf_winid = vim.fn.getqflist({ winid = 1 }).winid
  if qf_winid > 0 then
    vim.cmd("cclose")
  else
    vim.cmd("copen")
  end
end

function M.clear_quickfix()
  vim.fn.setqflist({})
  vim.cmd("cclose")
  vim.notify("Quickfix list cleared", vim.log.levels.INFO)
end

-- Setup function to configure grepprg and keymaps
function M.setup()
  -- Use ripgrep for :grep command
  vim.opt.grepprg = "rg --vimgrep --smart-case --no-heading"
  vim.opt.grepformat = "%f:%l:%c:%m"
  
  -- Keymaps
  local set = vim.keymap.set
  
  -- Quickfix list operations
  set("n", "<leader>qo", M.toggle_quickfix, { desc = "Toggle quickfix" })
  set("n", "<leader>qc", M.clear_quickfix, { desc = "Clear quickfix" })
  set("n", "]q", ":cnext<CR>zz", { desc = "Next quickfix item" })
  set("n", "[q", ":cprev<CR>zz", { desc = "Prev quickfix item" })
  set("n", "]Q", ":clast<CR>zz", { desc = "Last quickfix item" })
  set("n", "[Q", ":cfirst<CR>zz", { desc = "First quickfix item" })
  
  -- Project-wide operations
  set("n", "<leader>qs", M.search_project, { desc = "Search project" })
  set("n", "<leader>qr", M.substitute_project, { desc = "Replace in project" })
  set("n", "<leader>qw", M.search_word_under_cursor, { desc = "Search word" })
  set("n", "<leader>qW", M.substitute_word_under_cursor, { desc = "Replace word" })
  
  -- Alternative shortcut for main substitute function (replaces grug-far)
  set("n", "<leader>G", M.substitute_project, { desc = "Project-wide substitute" })
  set("v", "<leader>G", function()
    -- Get visual selection
    vim.cmd('noau normal! "vy"')
    local selection = vim.fn.getreg("v")
    
    local replace = vim.fn.input("Replace '" .. selection .. "' with: ")
    if replace == "" then return end
    
    vim.cmd("silent! grep! " .. vim.fn.shellescape(selection))
    
    local qf_size = vim.fn.getqflist({ size = 1 }).size
    if qf_size == 0 then
      vim.notify("No matches found", vim.log.levels.WARN)
      return
    end
    
    vim.cmd("copen")
    local confirm = vim.fn.input(string.format("Replace %d matches? (y/n): ", qf_size))
    
    if confirm:lower() == "y" then
      vim.cmd(string.format("cfdo %%s/%s/%s/g | update", 
        vim.fn.escape(selection, "/"),
        vim.fn.escape(replace, "/")
      ))
      vim.notify("Replaced in " .. qf_size .. " files", vim.log.levels.INFO)
    end
  end, { desc = "Project-wide substitute selection" })
end

return M
