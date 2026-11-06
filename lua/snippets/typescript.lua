local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
    s("clog", {
        t("console.log("),
        i(1),
        t(");"),
    }),

    s("asyncfn", {
        t("async function "),
        i(1, "name"),
        t("("),
        i(2, "params"),
        t({ ") {", "    " }),
        i(3),
        t({ "", "}" }),
    }),

    s("fetchjson", {
        t("const res = await fetch("),
        i(1, "url"),
        t({ ");", "if (!res.ok) throw new Error(`HTTP ${res.status}`);", "const data = await res.json();", "" }),
        i(2),
    }),
}
