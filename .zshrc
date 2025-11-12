alias ...='cd ./../..'
alias afind='ack-grep --before-context=3 --after-context=3 --color --follow'
alias beta_flag='bin/rails g verdict:configure_flag $@'
alias gd='git diff'
alias gdiff='git diff'
alias gfl='git show --pretty="" --name-only'
alias glog='git log --pretty=format:'\''%C(yellow)%h %C(blue)%ad %C(green)[%cn] %C(red)%d %C(reset)%s'\'' --decorate --date=short'
alias gti=git
alias gtl='git log main..HEAD'
alias gts='git status'
alias gut=git
alias imagery='dev cd imagery4'
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alF'
alias run-help=man
alias sfr='dev cd //areas/core/storefront'
alias shopify='dev cd shopify'
alias timestamp='date +%Y%m%d%H%M%S'
alias weather='curl wttr.in'
alias which-command=whence

autoload -Uz colors && colors
autoload -Uz vcs_info
PROMPT_COLOR=124
precmd() {
  vcs_info
  PROMPT_COLORS=(125 126 127 128 129)
  PROMPT_COLOR=$(( (PROMPT_COLOR + 1) % ${#PROMPT_COLORS[@]} ))
  }
setopt prompt_subst

# for i in {0..255}; do print -P "%F{$i}Color $i%f"; done

zstyle ':vcs_info:*' enable git # Enable git support for vcs_info
zstyle ':vcs_info:git:*' check-for-changes true # Check for unstaged/staged changes
zstyle ':vcs_info:git:*' unstagedstr '*' # Show * for unstaged changes
zstyle ':vcs_info:git:*' stagedstr '+' # Show + for staged changes
zstyle ':vcs_info:git:*' formats $'%F{39}%b%F{208}%u%c%F{220}%m%{\x1b[0m%} ' # Normal: blue branch, orange */+, yellow misc and \x1b[0m resets all (color, bold, underline, etc.)
zstyle ':vcs_info:git:*' actionformats $'%{\x1b[94m%}%b%F{grey}%u%c %F{grey}[%F{yellow}%a %m%F{grey}]%{\x1b[0m%} ' # During merge/rebase: adds [action] in brackets
# PROMPT=$'🏠 %f %F{228}%B%~%b $vcs_info_msg_0_%(!.%B%F{202}#%b.%B%F{202}%%%b)%F{122} ' # %B bold %b; %F{color}
PROMPT=$'🏠 %f %F{228}%B%~%b $vcs_info_msg_0_%(!.%F{red}#.%B%F{${PROMPT_COLORS[$PROMPT_COLOR+1]}}%%%b)%f '

[ -f /opt/dev/dev.sh ] && source /opt/dev/dev.sh

[[ -f /opt/dev/sh/chruby/chruby.sh ]] && { type chruby >/dev/null 2>&1 || chruby () { source /opt/dev/sh/chruby/chruby.sh; chruby "$@"; } }

[[ -x /opt/homebrew/bin/brew ]] && eval $(/opt/homebrew/bin/brew shellenv)

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH=$PATH:/usr/local/mysql/bin

# Added by tec agent
[[ -x /Users/lanadzyuban/.local/state/tec/profiles/base/current/global/init ]] && eval "$(/Users/lanadzyuban/.local/state/tec/profiles/base/current/global/init zsh)"
