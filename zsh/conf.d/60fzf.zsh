# If we have fzf, use it for completions.
if which fzf 2>&1 >/dev/null; then
  # Sets up three completions:
  # ^T: completes files under $PWD
  # ^R: replaces backwards history search with fzf
  # alt+C: completes directories under $PWD and cds immediately
  source <(fzf --zsh)
fi
