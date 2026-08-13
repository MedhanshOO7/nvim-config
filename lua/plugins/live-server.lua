return {
    "barrett-ruth/live-server.nvim",
    build = "npm i -g live-server || true",
    cmd = { "LiveServerStart", "LiveServerStop" },
    config = true,
    keys = {
        { "<leader>lv", "<cmd>LiveServerStart<cr>", desc = "Live Server Start" },
        { "<leader>lV", "<cmd>LiveServerStop<cr>", desc = "Live Server Stop" },
    },
}
