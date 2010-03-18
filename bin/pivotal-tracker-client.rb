#!/usr/bin/env ruby

require 'rubygems'
require 'yaml'
require 'pivotal-tracker-client'


token = YAML.load_file(File.expand_path("~/.pivotal_tracker"))['token']

PivotalTrackerClient.init token  

loop do
  sleep 5
end
