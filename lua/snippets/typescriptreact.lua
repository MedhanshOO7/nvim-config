local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

-- Friendly-snippets ships `rfc`, `rfce`, `tsrfc`, ...; `tsxfc` is our own
-- explicitly typed component scaffold.
return {
    s("tsxfc", {
        t({ 'import type { ReactNode } from "react";', "", "type " }),
        i(1, "Props"),
        t({ " = {", "    children?: ReactNode;", "};", "", "export function " }),
        i(2, "Component"),
        t({ "({ children }: " }),
        i(3, "Props"),
        t({ ") {", "    return (", "        <div>" }),
        i(4, "content"),
        t({ "</div>", "    );", "}" }),
    }),
}
