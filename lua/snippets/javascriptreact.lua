local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
    s("jsxfc", {
        t({ "export function " }),
        i(1, "Component"),
        t({ "({ children }) {", "    return (", "        <div>" }),
        i(2, "content"),
        t({ "</div>", "    );", "}" }),
    }),
}
