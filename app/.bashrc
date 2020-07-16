if [ -f "/opt/app-root/src/hitobito/.envrc" ]; then
  direnv allow /opt/app-root/src/hitobito/.envrc
  eval "$(direnv hook bash)"
fi

alias rspec="bundle exec rspec"
alias ls='ls -hF'
LC_ALL="en_US.UTF-8"

parse_git_branch() {
 git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

PS1="Hitobito-💻🚃($RAILS_ENV)$(parse_git_branch)\[\033[00m\]\$: "
