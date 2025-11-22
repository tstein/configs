require'nvim-treesitter.configs'.setup {
  ensure_installed = {
    "bash", "c", "cpp", "c_sharp", "go", "java", "kotlin", "lua", "perl",
    "python", "ruby", "rust", "toml", "scala", "sql", "typescript", "vim",
    "html", "javascript", "css",
    "cmake", "make", "dockerfile", "json", "yaml",
    "git_rebase", "gitattributes", "gitcommit", "gitignore",
    "comment", "markdown", "regex",
  },
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}

-- enable SQL highlighting in strings starting with `--sql` or `/*sql*/`
vim.treesitter.query.set("python", "injections", [[
; extends
(
    ((string_content)(interpolation)*)+ @injection.content
    (#any-match? @injection.content "^(--sql|\\/\\*sql\\*\\/)")
    (#set! injection.language "sql")
)
]])
