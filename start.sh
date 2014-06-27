#! /bin/sh

bundle exec dotenv rackup -D -P ./slack-repeater.pid -p 7654 config.ru

