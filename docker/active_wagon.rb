#!/usr/bin/env ruby
# frozen_string_literal: true

#  Copyright (c) 2020, Puzzle ITC. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'fileutils'
require 'pathname'

# Allows switching wagons quickly (depends on https://direnv.net/)
class Setup

  def run
    write_and_copy('.envrc', environment)
    write_and_copy('.tool-versions', 'ruby 2.5.5')
    write('Wagonfile', gemfile)
    FileUtils.rm_rf(root.join('tmp'))
  end

  def write(name, content)
    File.write(root.join(name), strip_heredoc(content))
  end

  def write_and_copy(name, content)
    write(name, content)
    FileUtils.cp(root.join(name), root.join("../hitobito_#{wagon}")) unless core?
  end

  def wagon(name = ARGV.first)
    if !available.include?(name)
      puts "Specify one of the following: #{available.join('|')}"
      exit
    end
    name
  end

  def gemfile
    <<~GEMFILE
      # rubocop:disable Naming/FileName,Lint/MissingCopEnableDirective
      # frozen_string_literal: true

      # vim:ft=ruby

      group :development, :test do
        ENV.fetch('WAGONS').split.each do |wagon|
          Dir[File.expand_path("../hitobito_\#{wagon}/hitobito_\#{wagon}.gemspec", __dir__)].each do |spec|
            gem File.basename(spec, '.gemspec'), path: File.expand_path('..', spec)
          end
        end
      end
    GEMFILE
  end

  def environment
    <<~DIRENV
      export RAILS_DB_ADAPTER=mysql2
      export RUBYOPT=-W0
      export WAGONS="#{wagons.join(' ')}"
      log_status "hitobito now uses: #{wagons.any? ? wagons.join(', ') : 'just the core'}"
      source_up
    DIRENV
  end

  def root
    @root ||= Pathname.new(File.expand_path('../../', __FILE__))
  end

  def wagons
    [wagon] + dependencies.fetch(wagon, []) - core_aliases
  end

  def dependencies
    %w(pbs cevi pro_natura sjas).product([%w(youth)]).to_h.merge({
      'jubla' => %w(youth jubla_ci),
      'tenants' => %w(generic),
    })
  end

  def available(excluded = %w(youth jubla_ci site))
    @available ||= root.parent.entries
      .collect { |x| x.to_s[/hitobito_(.*)/, 1]  }
      .compact.reject(&:empty?) - excluded + core_aliases
  end

  def core?
    core_aliases.include?(wagon)
  end

  def core_aliases
    %w(core hitobito)
  end

  def strip_heredoc(string)
    val = string.scan(/^[ \t]*(?=\S)/).min
    indent = val ? val.size : 0
    string.gsub(/^[ \t]{#{indent}}/, '')
  end

end

Setup.new.run
