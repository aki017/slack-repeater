#! /bin/sh

bundle exec dotenv rackup -D -P ./slack-repeater.pid -E production -p 7654 config.ru

