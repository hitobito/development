#  Copyright (c) 2026, Puzzle ITC. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

# Drives the *running* development application with the chromium that is already in this image,
# so a change can be checked in the real app without writing a feature spec.
#
# Quick look at a page:
#
#   bundle exec ruby /usr/src/app/docker/rails/dev_browser.rb /de/groups
#
# Anything more, from your own script:
#
#   require "/usr/src/app/docker/rails/dev_browser.rb"
#   page = DevBrowser.signed_in_session
#   page.visit "/de/groups/1"
#   page.click_link "Bearbeiten"
#   puts page.first("h1").text
#   DevBrowser.screenshot(page)
#
# `page` is a Capybara::Session, so the full Capybara API applies. Unlike in specs there is no
# test server and no test database: this is the development app with the development data, and
# anything you click really happens.

require "capybara/dsl"
require "selenium-webdriver"

module DevBrowser
  def self.checkout_root
    File.dirname(Dir.pwd)
  end

  def self.app_host
    ENV["DEV_APP_HOST"] || if File.basename(File.dirname(checkout_root)) == "worktrees"
      "http://hitobito-#{File.basename(checkout_root)}:3000"
    else
      "http://rails:3000"
    end
  end
  PASSWORD = ENV.fetch("DEV_APP_PASSWORD", "hito42bito")

  def self.session
    @session ||= begin
      Selenium::WebDriver::Chrome::Service.driver_path = "/usr/bin/chromedriver"
      Capybara.register_driver(:dev_browser) do |app|
        options = Selenium::WebDriver::Chrome::Options.new(binary: "/usr/bin/chromium")
        options.args.concat(%w[--headless=new --no-sandbox --disable-gpu --disable-dev-shm-usage
          --window-size=1600,1000])
        options.add_preference("intl.accept_languages", "de-CH,de")
        Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
      end
      Capybara.run_server = false # drive the running app, do not boot one
      Capybara.app_host = app_host
      Capybara::Session.new(:dev_browser)
    end
  end

  def self.signed_in_session(email = root_email, password = PASSWORD)
    session.tap do |page|
      page.visit "/"
      next unless page.has_field?("person[login_identity]", wait: 5)

      page.fill_in "person[login_identity]", with: email
      page.fill_in "person[password]", with: password
      page.find("form [type=submit]").click
      raise "login as #{email} failed, still on #{page.current_path}" if page.has_field?("person[password]", wait: 5)
    end
  end

  def self.root_email
    ENV["DEV_APP_EMAIL"] ||
      Dir["#{checkout_root}/hitobito_*/config/settings.yml",
           "#{checkout_root}/hitobito/config/settings.yml"]
        .lazy.filter_map { |f| File.read(f)[/^root_email:\s*(\S+@\S+)/, 1] }.first ||
      raise("no root_email found, pass one or set DEV_APP_EMAIL")
  end

  def self.screenshot(page = session, path = "#{checkout_root}/hitobito/tmp/dev_browser.png")
    page.save_screenshot(path)
    path
  end
end

if $PROGRAM_NAME == __FILE__
  page = DevBrowser.signed_in_session
  page.visit(ARGV.first || "/")
  puts "url:   #{page.current_url}"
  puts "title: #{page.title}"
  puts "h1:    #{page.first("h1", wait: 2)&.text.inspect}"
  puts "shot:  #{DevBrowser.screenshot(page)}"
end
