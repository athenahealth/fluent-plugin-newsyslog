# encoding: UTF-8
require 'rubygems'
require 'bundler'

require 'rspec'
require 'fluent/test'
require 'fluent/parser'

Dir["./lib/**/*.rb"].each{| f | require f}
