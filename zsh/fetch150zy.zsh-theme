local current_dir='$(basename "$PWD")'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[black]%} git:%{$reset_color%}(%{$fg[white]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[black]%} ✗%{$reset_color%})"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%} ✔%{$reset_color%})"

# ➦ ⚑ ▴ ☁ ⚡ ➜ ➭ ❯ ✗ ➤ ✈ ✱ λ ❯❯❯ ♥ ❮❮❮ ➟ ⬅ ✹ ✘
PROMPT="
%{$fg_bold[green]%} § %{$fg_bold[blue]%}${current_dir}"
PROMPT+='$(git_prompt_info) '
PROMPT+="%{$fg[cyan]%}❯❯❯ %{$reset_color%}"
