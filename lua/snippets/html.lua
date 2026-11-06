local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

-- `html5` and `!` already exist in friendly-snippets; this prefix is distinct.
return {
    s("html5doc", {
        t({
            "<!DOCTYPE html>",
            '<html lang="en">',
            "<head>",
            '    <meta charset="UTF-8" />',
            '    <meta name="viewport" content="width=device-width, initial-scale=1.0" />',
            "    <title>",
        }),
        i(1, "Document"),
        t({ "</title>", '    <link rel="stylesheet" href="' }),
        i(2, "styles.css"),
        t({ '" />', "</head>", "<body>", "    " }),
        i(3, "<!-- content -->"),
        t({ "", "</body>", "</html>" }),
    }),
}
