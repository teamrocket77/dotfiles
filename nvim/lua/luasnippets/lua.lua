local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local c = ls.choice_node
local sn = ls.snippet_node
local f = ls.function_node
local isn = ls.indent_snippet_node
local fmt = require("luasnip.extras.fmt").fmt
local types = require("luasnip.util.types")

local same = function(index)
  return f(function(arg)
    return arg[1][1]
  end, { index })
end

return {
  s("sametest", fmt([[example: {}, function: {}]], { i(1), same(1) })),
}
