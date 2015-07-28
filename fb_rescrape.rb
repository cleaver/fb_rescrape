# == Synopsis
#   This code uses Selenium Webdriver to automate rescraping pages via the
#   Facebook Developer page debug tool.
#
# == Usage
#   ruby fb_rescrape.rb < list_of_urls.txt
#

require 'json'
require 'selenium-webdriver'
require 'yaml'

class FbRescrape

  def initialize(stdin)
    @stdin = stdin
    @driver = Selenium::WebDriver.for :firefox
    if !File.exist?('fb_rescrape.yml')
      raise 'File not found: fb_rescrape.yml. See README.md'
    end
    @fb_login = YAML.load_file('fb_rescrape.yml')
    @login_url = 'https://www.facebook.com/'
    @base_url = 'https://developers.facebook.com/tools/debug/og/object/'
    @driver.manage.timeouts.implicit_wait = 30
  end

  def run
    fb_login
    @stdin.each {|url| process url}
    teardown
  end

  ## Log in to Facebook
  def fb_login
    @driver.get(@login_url + 'login')
    email_field = @driver.find_element(:id, 'email')
    email_field.clear
    email_field.send_keys @fb_login['fb_user']
    password_field = @driver.find_element(:id, 'pass')
    password_field.clear
    password_field.send_keys @fb_login['fb_pass']
    @driver.find_element(:name, 'login').click
    wait = Selenium::WebDriver::Wait.new(:timeout => 10)
    wait.until {@driver.find_element(:id, 'q')}
  end

  def process(url)
    if show_existing(url) != '200'
      rescrape url
    end
  end

  # get status of existing URL
  def show_existing(url)
    puts "Checking: #{url}"
    load_query_form
    query = @driver.find_element(:name, 'q')
    query.clear
    query.send_keys url
    show_button = @driver.find_element(:xpath, '//button[1]')
    show_button.click
    response = @driver.find_element(:xpath, '//table//tr[2]//td[2]//span').text
    puts "The response code is: #{response}."
    return response
  end

  def rescrape(url)
    puts "Rescraping: #{url}"
    load_query_form
    query = @driver.find_element(:name, 'q')
    query.clear
    query.send_keys url
    fetch_button = @driver.find_element(:name, 'rescrape')
    fetch_button.click
    response = @driver.find_element(:xpath, '//table//tr[2]//td[2]//span').text
    puts "The response code is: #{response}."
    return response
  end

  def load_query_form
    @driver.get(@base_url)
    wait = Selenium::WebDriver::Wait.new(:timeout => 10)
    wait.until {@driver.find_element(:id, 'u_0_1')}
  end

  def teardown
    @driver.quit
  end

end

fb_rescrape = FbRescrape.new(STDIN)
fb_rescrape.run
