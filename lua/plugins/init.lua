-- This file collects all plugin specs from subdirectories
return {
  -- Import all .lua files from each subdirectory
  { import = "plugins.ui" },
  { import = "plugins.git" },
  { import = "plugins.lsp" },
  { import = "plugins.editor" },
  { import = "plugins.languages" },
  { import = "plugins.ai" },
  { import = "plugins.debugger" },
  { import = "plugins.goofing" },
}
