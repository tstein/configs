require'nvim-treesitter.configs'.setup {
  ensure_installed = {
    "bash", "c", "cpp", "c_sharp", "go", "java", "kotlin", "lua", "perl",
    "python", "ruby", "rust", "toml", "sql", "typescript", "vim",
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

-- There's no dedicated zsh parser for now. The bash one is usable, and enables
-- things like heredoc injection.
vim.treesitter.language.register("bash", "zsh")

-- Enable SQL highlighting in strings starting with `--sql` or `/*sql*/`.
vim.treesitter.query.set("python", "injections", [[
; extends
(((string_content)(interpolation)*)+ @injection.content
  (#any-match? @injection.content "^(--sql|\\/\\*sql\\*\\/)")
  (#set! injection.language "sql")
)
]])
-- Language servers that emit semantic tokens, like ty, will nullify the above
-- rule because semantic tokens have a priority of 125 and injections are
-- supposed to be between 90 and 120. Disabling this doesn't break anything
-- else.
vim.api.nvim_set_hl(0, "@lsp.type.string.python", {})
