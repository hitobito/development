if [ -f "/opt/app-root/src/hitobito/.envrc" ]; then
  direnv allow /opt/app-root/src/hitobito/.envrc
  eval "$(direnv hook bash)"
fi

alias rspec="bundle exec rspec"
