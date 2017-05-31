require 'yaml'
require 'ostruct'
require 'erb'

unless defined? CONFIG
  app_env = ENV["APP_ENV"] || "development"
  puts "Loading config for: #{app_env}"
  CONFIG = to_recursive_ostruct(YAML.load(ERB.new(File.read("config/config.yml")).result)[app_env])
end
