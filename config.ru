require 'rubygems'
require 'bundler'
Bundler.require

$:.unshift(File.dirname(__FILE__))

require "slack-repeater"

run SlackRepeater

