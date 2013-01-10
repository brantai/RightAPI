#!/usr/bin/env ruby
#
# run a rightscript on a particular server 
# expects RightAPI.rb and config.yml in the same directory
#
$: << File.dirname(__FILE__)
require 'RightAPI'
require 'rexml/document'
require 'yaml'
require 'debugger'

config = YAML.load(File.read 'config.yml')
[:account_id, :email, :password, :server_nickname, :script_name, :project_directory].each do |k|
  raise "invalid config, missing #{k}" unless config[k]
end

puts "SERVER: #{config[:server_nickname]}, SCRIPT: #{config[:script_name]}"

api = RightAPI.new
api.log = true
api.login(:username => config[:email], :password => config[:password], :account => config[:account_id])
@authen = api.send('login')

# get server 
response = api.send('servers', 'get', :headers => {:cookies => @authen.cookies})
xml = REXML::Document.new(response)
servers = xml.root.elements.collect('//server[state="operational"]') {|el| el if el.text('nickname') == config[:server_nickname]}.compact
puts servers.first.text('href')
server_id = servers.first.text('href').split('/').last

# get rightscript
content = api.send('right_scripts', 'get', :headers => {:cookies => @authen.cookies})
xml = REXML::Document.new(content)
scripts = xml.root.elements.collect('//right-script') {|el| el if el.text('name') == config[:script_name]}.compact
script_href = scripts.find {|el| el.text('is-head-version') == 'true' }.text('href')
puts script_href

# run script
content = api.send("servers/#{server_id}/run_script", 'post', 
                   :payload => {'server[right_script_href]' => script_href,
                     'server[parameters][PROJECT_DIRECTORY]'=> config[:project_directory],},
                   :headers => {:cookies => @authen.cookies})

# check result
raise "call failed: #{api.headers}" unless api.headers[:status] == '201'
interval = 10
10.times do
  content = api.send("audit_entries/#{api.resourceid}", 'get', :headers => {:cookies => @authen.cookies})
  state = REXML::Document.new(content).root.text('state')
  puts "state for audit entry #{api.resourceid}: #{state}"
  break if state =~ /(complete|fail)/
  sleep interval
end
