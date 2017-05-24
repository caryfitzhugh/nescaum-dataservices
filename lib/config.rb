require 'yaml'
require 'ostruct'
require 'erb'

CONFIG = OpenStruct.new(YAML.load(ERB.new(File.read("config/config.yml")).result)[ENV["APP_ENV"] || "development"])
