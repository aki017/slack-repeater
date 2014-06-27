
Eye.config do
  logger File.expand_path(File.join(File.dirname(__FILE__), 'eye.log'))
end

Eye.application 'slack-repeater' do
  working_dir File.expand_path(File.dirname(__FILE__))

  process 'sinatra' do
    pid_file 'slack-repeater.pid'
    start_command './start.sh'
  end
end

