alias rspec="bundle exec rspec"
alias ls='ls -hF'

shortened_git_branch() {
    git rev-parse --abbrev-ref HEAD 2> /dev/null | \
        awk -v len=15 '{ if (length($0) > len) print "..." substr($0, length($0)-len+3, len); else print; }'
}

PS1="🚃 \$RAILS_ENV 🕎 \$(shortened_git_branch) 📁 \w \$ "

if [ -f ./.envrc ]; then
  direnv allow ./.envrc
  eval "$(direnv hook bash)"
fi

PATH=$PATH:./bin

# make sure APP_ROOT is NOT set
unset APP_ROOT

alias rake="../hitobito/bin/rake"
