vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/site/pack/kde-code-bridge/start/kde-code-bridge")

require("kde_code_bridge").setup({
  device_id = "679e4df0ed4f4b78955678d331b341da",
})
