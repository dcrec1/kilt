require 'rubygems'
require 'yaml'
require 'kilt'

token = YAML.load_file(File.expand_path("~/.pivotal_tracker"))['token']

Kilt.init token  

loop do
  sleep 5
end
