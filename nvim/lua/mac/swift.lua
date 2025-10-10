-- cmd = xcrun -f sourcekit-lsp
-- https://wojciechkulik.pl/ios/the-complete-guide-to-ios-macos-development-in-neovim
local get_cmp = function()
  local ok, module = pcall(require, "cmp_nvim_lsp")
  if not ok then
    return nil
  end
  return module.default_capabilities()
end

vim.lsp.config("sourcekit", {
  cmd = {
    "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/sourcekit-lsp",
    -- "-Xswiftc",
    -- "-sdk",
    -- "-Xswiftc",
    -- "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk",
    -- "-Xswiftc",
    -- "-target",
    -- "-Xswiftc",
    -- "iPhoneSimulator26.0"
  },
  capabilities = {
    workspace = {
      didChangeWatchedFiles = {
        dynamicRegistration = true,
      },
    },
  },
})
