local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets("cpp", {

    -- Fast competitive programming template
    s("boil", {
        t({
            "#include <bits/stdc++.h>",
            "using namespace std;",
            "",
            "int main() {",
            "    cout<<\"Hello, World!\";",
            "",
            "    "
        }),
        i(1),
        t({
            "",
            "    return 0;",
            "}"
        }),
    }),

    -- Debug print that stays valid in every C++ dialect.
    s("dbg", {
        t("std::cerr << "),
        i(1, '"value: "'),
        t(" << "),
        i(2, "value"),
        t(" << std::endl;"),
    }),

    s("fastio", {
        t({
            "std::ios::sync_with_stdio(false);",
            "std::cin.tie(nullptr);",
        }),
    }),

})
