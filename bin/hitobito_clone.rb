#!/usr/bin/ruby
# frozen_string_literal: true

require 'net/http'
require 'json'
require 'optparse'

WAGON_DEPENDENCIES = { hitobito_pbs: 'hitobito_youth' }

# ssh cloning as default
options = { https_clone: false }

# read hitobito repos from github
url = URI.parse('https://api.github.com/users/hitobito/repos')
raw_repo_data = Net::HTTP.get(url)
repo_data = JSON.parse(raw_repo_data)

# get repos of hitohito wagons
repos_to_skip = %w[ose_ github.io.git$ docs.git$]
repos = []
repos_with_dependencies = []
development_repo = {}
core_repo = {}


def clone_repo(repo, development_repo, core_repo)
  shortened_repo_name = repo[:name].gsub('hitobito_', '')

  # clone development repo
  system "cd hitobito && git clone #{development_repo[:url]} #{shortened_repo_name}" unless repo_path_exists?(shortened_repo_name)

  # clone core repo
  system "cd hitobito/#{shortened_repo_name}/app && git clone #{core_repo[:url]}" unless repo_path_exists?(shortened_repo_name, core_repo[:name])

  # clone wagon
  system "cd hitobito/#{shortened_repo_name}/app && git clone #{repo[:url]}" unless repo_path_exists?(shortened_repo_name, repo[:name])
end

def clone_repo_with_dependency(repo_with_dependency, development_repo, core_repo)
  repo = repo_with_dependency[:repo]
  dependant_repo = repo_with_dependency[:dependant]

  clone_repo repo, development_repo, core_repo

  shortened_repo_name = repo[:name].gsub('hitobito_', '')

  # clone dependant
  system "cd hitobito/#{shortened_repo_name}/app && git clone #{dependant_repo[:url]}" unless repo_path_exists?(shortened_repo_name, dependant_repo[:name])
end

def repo_path_exists?(name, wagon_name = nil)
  dir = "./hitobito/#{name}"
  dir = dir + "/app/#{wagon_name}" unless wagon_name.nil?
  puts dir
  Dir.exist?(dir)
end

# define usable options
OptionParser.new do |opts|
  opts.banner = "Usage: hitobito_clone.rb [options]"

  opts.on("-t", "--https", "Clone repos via https") do |t|
    options[:https_clone] = t
  end

  opts.on("-rREPO", "--repo=REPO", "Name of the repository to clone") do |r|
    options[:repo] = r
  end

  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end

end.parse!

repo_data.each do |repo|
  # just take name, clone_url and ssh_url
  repo_attrs = repo.slice('name', 'clone_url', 'ssh_url')

  # check for non hitobito dev repos
  next if /#{repos_to_skip.join('|')}/.match(repo_attrs["ssh_url"])

  # check if ssl is enabled
  repo_attrs = { name: repo_attrs["name"], url: options[:https_clone] ? repo_attrs["clone_url"] : repo_attrs["ssh_url"] }

  # remove development repo
  if repo_attrs[:name] == 'development'
    development_repo = repo_attrs
    next
  end

  # remove core repo
  if repo_attrs[:name] == 'hitobito'
    core_repo = repo_attrs
    next
  end

  repos.push(repo_attrs)
end

# filter repos with dependencies
WAGON_DEPENDENCIES.each do |repo_name, dependant_repo_name|
  filtered_repos = {}
  repos.delete_if do |repo|
    name = repo[:name]

    # add repo
    if name == repo_name.to_s
      filtered_repos[repo_name.to_s] = repo
    end

    # add dependant repo
    if name == dependant_repo_name
      filtered_repos[dependant_repo_name] = repo
    end

    # return value for delete if
    name == dependant_repo_name || name == repo_name.to_s
  end

  repos_with_dependencies.push({ repo: filtered_repos[repo_name.to_s], dependant: filtered_repos[dependant_repo_name]})
end

# select repos according to given options
unless options[:repo].nil?
  repos = repos.select { |repo| repo[:name] == options[:repo] }
  repos_with_dependencies = repos_with_dependencies.select { |repo| repo[:repo][:name] == options[:repo] || repo[:dependant][:name] == options[:repo] }
end

# give the user some nice information about what's going to happen
puts options[:repo].nil? ? 'Now cloning every hitobito dev repository 🚀' : "Now cloning #{options[:repo]} 🚀"

# create the hitobito directory if it does not exist
system "mkdir hitobito" unless Dir.exist?("./hitobito")

# cloning process
repos.each do |repo|
  clone_repo repo, development_repo, core_repo
end

repos_with_dependencies.each do |repo_with_dependency|
  clone_repo_with_dependency repo_with_dependency, development_repo, core_repo
end