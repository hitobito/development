alias rspec="bundle exec rspec"
alias ls='ls -hF'

parse_git_branch() {
 git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

PS1="🚃($RAILS_ENV)🕎$(parse_git_branch)\[\033[00m\]\$: "

if [ -f "/usr/src/app/hitobito/.envrc" ]; then
  direnv allow /usr/src/app/hitobito/.envrc
  eval "$(direnv hook bash)"
fi

PATH=$PATH:/usr/src/app/hitobito/bin

# make sure APP_ROOT is NOT set
unset APP_ROOT

alias rake="/usr/src/app/hitobito/bin/rake"
