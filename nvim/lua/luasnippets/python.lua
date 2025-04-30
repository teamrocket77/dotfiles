local ts_utils = require('nvim-treesitter.ts_utils')
local ls = require("luasnip")
local s = ls.snippet
local d = ls.dynamic_node
local i = ls.insert_node
local t = ls.text_node
local c = ls.choice_node
local sn = ls.snippet_node
local f = ls.function_node
local isn = ls.indent_snippet_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

local function to_init_assign(args)
  local tab = {}
  local a = args[1][1]
  local count = 1
  local ret_node = t("")
  local ret_obj = args[2][1]
  if #a == 0 then
  else
    table.insert(tab, isn(nil, { t({ "", "" }) }, "$PARENT_INDENT"))
    table.insert(tab, isn(nil, { t("\tArgs:") }, "$PARENT_INDENT"))
    for e in string.gmatch(a, " ?([^,]*) ?") do
      if #e > 0 then
        table.insert(tab, isn(nil, { t({ "", "" }) }, "$PARENT_INDENT"))
        table.insert(tab, isn(nil, { t("\t\t" .. e) }, "$PARENT_INDENT"))
        count = count + 1
      end
    end
  end

  table.insert(tab, isn(nil, { t({ "", "" }) }, "$PARENT_INDENT"))
  if ret_obj ~= "" then
    ret_obj = string.gsub(ret_obj, "-> ", "")
    ret_node = t("Returns:" .. ret_obj)
  end
  return isn(
    nil,
    fmt(
      [[{}{}
    {}
    {}]],
      { t('"""'), isn(nil, sn(nil, tab), "$PARENT_INDENT"), ret_node, t('"""') }
    ),
    "$PARENT_INDENT"
  )
end

local function handle_args()
	local function_node_types = {
		function_definition = true
	}
	local parameters = {
		parameters = true
	}
	local node = ts_utils.get_node_at_cursor()
	while node ~= nil do
		if function_node_types[node:type()] then
			break
		end
		node = node:parent()
	end
	if not node then
		vim.notify "We are not inside of a functions arguments cannot be used"
	end
	local children = ts_utils.get_named_children(node)
	for _, child in ipairs(children) do
		if parameters[child:type()] then
			vim.notify('We found parameters')
			for parameter in child:iter_children() do
				vim.notify(vim.inspect(parameter:type()))
				-- vim.notify(vim.inspect(ts_utils.get_node_text(parameter)))
			end
		end
	end
end

local function choose_doc_string(args)
  if args[1][1] ~= "" or args[2][1] ~= "" then
	  if args[1][1] ~= "" then
		  handle_args()
	  end
    return to_init_assign(args)
  end
  return isn(nil, t("pass"), "$PARENT_INDENT")
end

ls.add_snippets("python", {
  s(
    "d",
    fmt(
      [[def {}({}){}:
    {}]],
      {
        i(1),
        i(2),
        c(3, { t(""), fmt([[-> {}]], i(1)) }),
        d(4, choose_doc_string, { 2, 3 }),
      }
    )
  ),
  s(
    "lc",
    fmt([[{} = {}{} for {} in {}{}]], {
      i(1),
      t("["),
      i(2),
      rep(2),
      i(3),
      t("]"),
    })
  ),
  s(
    "lcf",
    fmt([[{} = {}{} for {} in {}{}]], {
      i(1),
      t("["),
      i(2),
      i(3),
      i(4),
      t("]"),
    })
  ),
  s(
    "dc",
    fmt([[{} = {}{}:{} for {} in {}{}]], {
      i(1),
      t("["),
      i(2),
      i(3),
      rep(2),
      i(4),
      t("]"),
    })
  ),
  s("test", fmt([["something"]], {})),
})
