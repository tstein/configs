require'nvim-treesitter.configs'.setup {
  ensure_installed = {
    "bash", "c", "cpp", "c_sharp", "go", "java", "kotlin", "lua", "perl",
    "python", "ruby", "rust", "toml", "scala", "sql", "typescript", "vim",
    "html", "javascript", "css",
    "cmake", "make", "dockerfile", "json", "yaml",
    "git_rebase", "gitattributes", "gitcommit", "gitignore",
    "comment", "regex",
  },
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}
