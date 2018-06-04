require_relative 'config/environment.rb'

include ErlPort::Erlang

def run_bot(pid, token, listener, ex_module=nil)
  bot = Telegram::Bot::Client.new(token)
  # bot.instance_variable_set(:'@listener', listener)
  Telegram.bots[token.to_sym] = bot
  routes = Rails.application.routes.url_helpers
  cert_file = '/usr/src/app/cert/webhook_cert.pem'
  cert = File.open(cert_file)
  route_name = Telegram::Bot::RoutesHelper.route_name_for_bot(bot)
  url = routes.send("#{route_name}_url")
  puts "Setting webhook for #{token}..."
  bot.async(false) { bot.set_webhook(url: url, certificate: cert) }
end

def stop_bot(pid, token, listener, ex_module = nil)
  bot = Telegram::Bot::Client.new(token)
  Telegram.bots[token.to_sym] = bot
  puts "Delete webhook for #{token}..."
  bot.async(false) { bot.delete_webhook }
end