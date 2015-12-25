#!/usr/bin/env ruby
# encoding: UTF-8

require 'nokogiri'
require 'open-uri'

if ARGV.length < 2
  puts 'Abort | Missing arguments! Use: \'ruby download-der-spiegel.rb [year] [issue]\''
  exit
end

# Oldest issue: 1947 1
year = ARGV[0].to_i
issue = ARGV[1].to_i

# Check if year and issue are valid
if year < 1947 || issue < 1 || issue > 52
  puts 'Abort | Invalid year or issue!'
  exit
end

issue_dir_name = "#{year.to_s}_#{issue.to_s}"
issue_pages_dir_name = "#{issue_dir_name}/pages"
issue_cover_name = "Der_Spiegel_#{issue_dir_name}.jpg"

puts 'Downloading cover image'

url_str = "http://magazin.spiegel.de/EpubDelivery/image/title/SP/#{year}/#{issue}/1000"
curl_command = "curl --silent --insecure --junk-session-cookies --create-dirs --output #{issue_dir_name}/#{issue_cover_name} #{url_str}"
`#{curl_command}`

puts 'Downloading pages. This may take a while!'

# Download the issues main page from the web and parse it to find the article ids which can be used to download the PDF pages
begin
  issue_page = Nokogiri::HTML.parse(open("http://www.spiegel.de/spiegel/print/index-#{year}-#{issue}.html"))
rescue => e
  puts "Abort | Error: #{e.to_s}"
  exit
end

article_ids = []
issue_page.css('a').map do |link|
  url = link['href']
  # Find urls which link to articles
  if /spiegel\/print\/d/.match(url)
    # Extract the id from the url
    article_id = url.split('-')[-1].gsub('.html', '')
    article_ids.push(article_id)
  end
end

# Its important to sort the ids. This helps to avoid downloads of duplicate content (See further below)
article_ids.sort!
previous_content_length = 0

article_ids.each do |article_id|
  url_str = "http://magazin.spiegel.de/EpubDelivery/spiegel/pdf/#{article_id.to_s}"

  # Download header
  curl_command = "curl --head --silent --insecure --junk-session-cookies #{url_str}"
  http_header = `#{curl_command}`

  # Check if the request was successful
  next unless /200\sOK/.match(http_header) && /application\/pdf/.match(http_header)

  filename = ''
  current_content_length = 0

  http_header.split("\r\n").each do |line|
    if /^Content\-Disposition/.match(line)
      filename = line.split('filename=')[-1]
    end
    if /^Content\-Length/.match(line)
      current_content_length = line.split(': ')[-1].to_i
    end
  end

  # Don't download the PDF if the length difference to the previously downloaded PDF is to small.
  # There are multiple versions of the same file online which differ just a litte in size.
  # The few lines below are there to avoid any downloads of duplicates
  absolute_length_difference = (previous_content_length - current_content_length).abs
  next if absolute_length_difference < 20
  previous_content_length = current_content_length

  puts " - #{filename}"

  # Download the PDF page(s)
  curl_command = "curl --silent --insecure --junk-session-cookies --create-dirs --output #{issue_pages_dir_name}/#{filename} #{url_str}"
  `#{curl_command}`
end

puts 'Done! Bye :)'
