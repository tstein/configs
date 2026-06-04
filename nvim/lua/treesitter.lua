require('nvim-treesitter').install {
  "bash", "c", "cpp", "c_sharp", "go", "java", "kotlin", "lua", "perl",
  "python", "ruby", "rust", "toml", "sql", "typescript", "vim",
  "html", "javascript", "css",
  "cmake", "make", "dockerfile", "json", "yaml",
  "git_rebase", "gitattributes", "gitcommit", "gitignore",
  "comment", "markdown", "regex",
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

-- Actually enable treesitter whenever it's useful.
-- via https://github.com/nvim-treesitter/nvim-treesitter/issues/8221
vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    local treesitter = require('nvim-treesitter')
    local lang = vim.treesitter.language.get_lang(args.match)
    if vim.list_contains(treesitter.get_available(), lang) then
      if not vim.list_contains(treesitter.get_installed(), lang) then
        treesitter.install(lang):wait()
      end
      vim.treesitter.start(args.buf)
      vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      vim.wo[0][0].foldmethod = 'expr'
    end
  end,
  desc = "Enable nvim-treesitter and install parser if not installed"
})
