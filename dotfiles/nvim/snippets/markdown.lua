local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local d = ls.dynamic_node
local f = ls.function_node

local function get_today()
  return os.date("%Y-%m-%d")
end

local function get_yesterday()
  return os.date("%Y-%m-%d", os.time() - 86400)
end

return {
  s("daylog", {
    f(function()
      local today = get_today()
      return "## " .. today
    end, {}), -- Cursorの一つしたの行に挿入
    t({
      "",
      "",
      "",
    }),
    f(function()
      local yesterday = get_yesterday()
      return "### " .. yesterday .. " 振り返り"
    end, {}), -- Cursorの一つしたの行に挿入
    t({
      "",
      "",
      "#### やったこと",
      "",
      "- ",
      "",
    }),
    t({
      "",
      "#### わかったこと",
      "",
      "- ",
      "",
    }),
    t({
      "",
      "#### 次に取り組むこと",
      "",
      "- ",
      "",
      "",
    }),
    f(function()
      local today = get_today()
      return "### " .. today .. " TODO"
    end, {}), -- Cursorの一つしたの行に挿入
    t({
      "",
      "",
      "- [ ]",
      "",
    }),
    t({
      "",
      "",
    }),
    f(function()
      local today = get_today()
      return "### " .. today .. " Log"
    end, {}), -- Cursorの一つしたの行に挿入
    t({
      "",
      "",
      "#### ライフログ",
      "",
      "- ",
      "",
    }),
    t({
      "",
      "#### 学び",
      "",
      "- ",
    }),
  }),
}
