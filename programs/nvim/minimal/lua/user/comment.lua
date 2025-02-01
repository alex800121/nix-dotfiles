local comment = require'Comment'

comment.setup({
  padding = true,
  sticky = true,
  ignore = nil,
  mappings = { basic = true, extra = true },
  pre_hook = nil,
  post_hook = nil,
})
