# Facebook Rescrape

This code uses Selenium Webdriver to do something other than testing. In this
case, it is automating the rescrape of pages via the Facebook Developer page
debug tool found here: https://developers.facebook.com/tools/debug/og/object/

This could be useful to you if you have a number of pages that have been shared
on Facebook, but the share data shows an error or is out of date.

## Use

1. Copy `fb_rescrape.yml.example` to `fb_rescrape.yml` and edit contents to add
   valid Facebook login credentials.
2. Create a file: `list_of_urls.txt` which contains a list of URLs to be
   checked and rescraped.
3. Install and run the script:

~~~
bundle install
ruby rb_rescrape.rb <list_of_urls.txt
~~~

## Notes

I'm using [rbenv](https://github.com/sstephenson/rbenv) and Ruby version 2.1.2.
You should be able to run it with RVM or other versions of Ruby from 1.9.3 on up.

## Limitations

This is more of a "useful example" than a complete application and was the
quickest way to get to the desired solution and no more.

This code makes a lot of assumptions about the DOM on the Facebook Developer
site. Any of that could change at any time, breaking this code.

Facebook may put limitations on the number of rescrapes in a given time frame.

This *could* be a gem, but I only anticipate limited use.