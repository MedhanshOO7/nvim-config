local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

-- Prefixes are intentionally distinct from friendly-snippets (`def`, `class`,
-- `ifmain`, ...) so both collections can be loaded without duplicates.
return {
    s("argparse", {
        t({
            "import argparse",
            "",
            "",
            "def main() -> None:",
            '    parser = argparse.ArgumentParser(description="',
        }),
        i(1, "CLI tool"),
        t({ '")', '    parser.add_argument("' }),
        i(2, "input"),
        t({ '", help="' }),
        i(3, "input path"),
        t({ '")', "    args = parser.parse_args()", "", "    print(args." }),
        i(4, "input"),
        t({ ")", "", "", 'if __name__ == "__main__":', "    main()" }),
    }),

    s("dataclass", {
        t({ "from dataclasses import dataclass", "", "", "@dataclass", "class " }),
        i(1, "ClassName"),
        t({ ":", "    " }),
        i(2, "field: type"),
    }),

    s("ctxmanager", {
        t({ "from contextlib import contextmanager", "", "", "@contextmanager", "def " }),
        i(1, "resource"),
        t({ "():", "    " }),
        i(2, "yield resource"),
    }),
}
