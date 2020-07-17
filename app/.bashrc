alias rspec="bundle exec rspec"
alias ls='ls -hF'
LC_ALL="en_US.UTF-8"

parse_git_branch() {
 git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

PS1="🚃($RAILS_ENV)🕎$(parse_git_branch)\[\033[00m\]\$: "

if [ -f "/opt/app-root/src/hitobito/.envrc" ]; then
  direnv allow /opt/app-root/src/hitobito/.envrc
  eval "$(direnv hook bash)"
fi

# don't use these bins from hitobito/bin
alias bundle="/opt/rh/rh-ruby26/root/usr/local/bin/bundle"
alias spring="/opt/rh/rh-ruby26/root/usr/local/bin/spring"
alias active_wagon.rb="/opt/app-root/src/hitobito/tmp/active_wagon.rb"
