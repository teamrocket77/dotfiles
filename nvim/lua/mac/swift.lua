-- cmd = xcrun -f sourcekit-lsp
-- https://wojciechkulik.pl/ios/the-complete-guide-to-ios-macos-development-in-neovim
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
  settings = {
  },
})
