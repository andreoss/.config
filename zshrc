bindkey -v
unsetopt beep
setopt autocd appendhistory

zstyle :compinstall filename "${ZDOTDIR:-$HOME}/.zshrc"

autoload -U colors && colors
autoload -Uz compinit && compinit
autoload -Uz bashcompinit && bashcompinit
autoload -Uz promptinit && promptinit

zstyle ':completion:*:*:cp:*' file-sort size
zstyle ':completion:*' file-sort modification
zstyle ':completion:*' verbose yes

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"

zstyle ':completion:*' menuselect

zstyle ':completion:*:*:*:*:descriptions' format '%F{green}-- %d --%f'

zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'

zstyle ':completion:*' group-name ''
zstyle ':completion:*:*:-command-:*:*' group-order alias builtins functions commands
zstyle ':completion:*' file-list all
zstyle ':completion:*' complete-options true


zstyle ':completion:*:*:cd:*' menu yes select
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s%p
zstyle ':completion:*' rehash true

# Change cursor shape for different vi modes.
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init

autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

autoload -Uz add-zsh-hook


autoload -Uz vcs_info
autoload -Uz add-zsh-hook

bindkey -v
bindkey '^R' history-incremental-search-backward


__short_pwd() {
    DIR=
    if [ -z "${INSIDE_EMACS-}" ]; then
        case "$PWD" in
            "$HOME")
                DIR=
                ;;
            $HOME/*)
                DIR=${PWD##"$HOME/"}
                ;;
            *)
                DIR="$PWD"
                ;;
        esac
    fi
    printf '%s' "$DIR"
}
__git_work_tree() {
    git rev-parse --is-inside-work-tree 2>/dev/null >/dev/null
}
__git_branch() {
    if git show-ref --verify --quiet HEAD; then
        git rev-parse --symbolic-full-name --abbrev-ref HEAD
    else
        echo "(empty)"
    fi
}
__vcs_status() {
    if __git_work_tree; then
        printf '%s' "$(__git_branch)"
    fi
}
__title() {
    COMMAND="$1"
    DIR="$(__short_pwd)"
    DIR="${DIR:-~}"
    VCS="$(__vcs_status)"
    case "$COMMAND" in
        history* | autojump*)
            COMMAND=""
            ;;
    esac
    if [ "$COMMAND" ]; then
        echo -ne "\e]0;${VCS} ${DIR}: ${COMMAND}\007"
    else
        echo -ne "\e]0;${VCS} ${DIR}\007"
    fi
}

__title_precmd() {
         __title
}

__title_preexec() {
         __title "$2"
}


__ps1_short() {
    if [ "${USER:-}" = "root" ]; then
        __PROMPT='# '
    else
        __PROMPT="${__PROMPT:-* }"
    fi
    printf '%s' "$__PROMPT"
}

__ps1() {
    if [ "${USER:-}" = "root" ]; then
        __PROMPT='# '
    else
        __PROMPT="${__PROMPT:-* }"
    fi
    DIR="$(__short_pwd)"

    if [ "$DIR" ]; then
        VCS="$(__vcs_status)"
        printf '%s %s %s\n%s' "$VCS" "$DIR" "${IN_NIX_SHELL-}" "$__PROMPT"
    else
        printf '%s' "$__PROMPT"
    fi
}

export PATH
PROMPT_COMMAND="history -a"

set -o vi

setopt PROMPT_SUBST
if [ "${ZSH_VERSION:-}" ]
then
    if [ "${TMUX:-}" ]
    then
       PROMPT='$(__ps1_short)'
    else
       PROMPT='$(__ps1)'
    fi
   if [[ "$TERM" == (screen*|xterm*|rxvt*) ]]
   then
      autoload -Uz add-zsh-hook
      add-zsh-hook -Uz precmd __title_precmd
      add-zsh-hook -Uz preexec __title_preexec
    fi
fi
