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
    @driver.manage.timeouts.implicit_wait = 5
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
    wait.until do
      @driver.find_element(:id, 'q')
    end
  end

  def process(url)
    if show_existing(url) == :rescrape
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
    begin
      wait = Selenium::WebDriver::Wait.new(:timeout => 15)
      response = wait.until { show_response }
      puts 'The response code is: ' + response.to_s
    rescue
      response = :rescrape
    end
    response
  end

  def rescrape(url)
    puts "Rescraping: #{url}"
    load_query_form
    query = @driver.find_element(:name, 'q')
    query.clear
    query.send_keys url
    fetch_button = @driver.find_element(:name, 'rescrape')
    fetch_button.click
    begin
      wait = Selenium::WebDriver::Wait.new(:timeout => 20)
      response = wait.until { show_response }
      puts 'The response code is: ' + response.to_s
    rescue
      puts 'Timeout'
      response = :rescrape
    end
    response
  end

  def show_response
    response = false
    # look for response code
    begin
      code_label = @driver.find_element(:xpath, '//table//tr[2]//td[1]//span').text
      if code_label === 'Response Code'
        code = @driver.find_element(:xpath, '//table//tr[2]//td[2]//span').text
        puts " Found code: #{code}"
        response = code == '200' ? :good : :rescrape
      end
    rescue
      # look for Error parsing input URL - it may have never been shared and scraped.
      error_message = @driver.find_element(:xpath, "//div[@id='u_0_1']//span").text
      puts " Found error: #{error_message}"
      if error_message=~ /Error parsing input URL/
        response = :rescrape
      end
    end
    response
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
