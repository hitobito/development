alias rspec="bundle exec rspec"
alias ls='ls -hF'
LC_ALL="en_US.UTF-8"

# active_wagon resides in core/tmp to avoid it's checked-in in core git repo
active_wagon () {
  (/opt/app-root/src/hitobito/tmp/active_wagon $1)
}

parse_git_branch() {
 git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

PS1="🚃($RAILS_ENV)🕎$(parse_git_branch)\[\033[00m\]\$: "

if [ -f "/opt/app-root/src/hitobito/.envrc" ]; then
  direnv allow /opt/app-root/src/hitobito/.envrc
  eval "$(direnv hook bash)"
fi

