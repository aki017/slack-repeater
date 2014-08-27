
require 'faraday'
require 'sinatra/base'
require 'json'

def post(name, message, channel, options = {})
  connection = Faraday.new(url: 'https://slack.com/') do |faraday|
    faraday.request  :url_encoded
    faraday.adapter  :net_http
  end
  data = {
    token: ENV['SLACK_TOKEN'],
    channel: channel,
    text: message,
    username: name,
  }.merge(options)
  connection.post '/api/chat.postMessage', data
end

class SlackRepeater < Sinatra::Base
  post "/airbrake" do
    request.body.rewind
    json = JSON.parse(request.body.read)

    error = json['error']

    project = error['project']
    environment = error['environment']

    error_message = error['error_message']
    error_message.gsub!(/</m, '&lt;')
    error_message.gsub!(/>/m, '&gt;')
    message = "<https://happyelements.airbrake.io/projects/#{project['id']}/groups/#{error['id']}|#{error_message}>"

    text = error['error_message']
    fields = [
      ["project name", project["name"], true],
      ["environment", environment, true],
      ["times occurred", error["times_occurred"], true],
      ["last occurence", error["last_occurred_at"], true],
      ["request url", (error["last_notice"]["request_url"] rescue ""), false],
    ]

    attachments = [{
      fallback: text,
      color: "#ff0000",
      fields: fields.map {|title, value, short|
        {
          title: title,
          value: value,
          short: short,
        }
      }
    }]

    options = {
      attachments: attachments.to_json,
      icon_emoji: ":scream:",
    }

    post "Airbrake [#{environment}]", message, ENV["SLACK_AIRBRAKE_CHANNEL_#{project['id']}"], options
  end
end

