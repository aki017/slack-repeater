
require 'faraday'
require 'sinatra/base'
require 'json'

def post(name, message, channel)
  connection = Faraday.new(url: 'https://slack.com/') do |faraday|
    faraday.request  :url_encoded
    faraday.adapter  :net_http
  end
  connection.post '/api/chat.postMessage', {
    token: ENV['SLACK_TOKEN'],
    channel: channel,
    text: message,
    username: name
  }
end

class SlackRepeater < Sinatra::Base
  post "/airbrake" do
    request.body.rewind
    json = JSON.parse(request.body.read)

    error = json['error']

    project = error['project']
    environment = error['environment']

    message = "<https://happyelements.airbrake.io/projects/#{project['id']}/groups/#{error['id']}|#{error['error_message']}>\n"
    message << "　- peoject name: #{project['name']}\n"
    message << "　- environment: #{environment}\n"
    message << "　- last occurence: #{error['last_occurred_at']}\n"
    message << "　- times occurred: #{error['times_occurred']}\n"
    post "Airbrake [#{environment}]", message, ENV["SLACK_AIRBRAKE_CHANNEL_#{project['id']}"]
  end
end

