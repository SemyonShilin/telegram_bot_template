require_relative '../config/config'
require_relative '../lib/bot'

config = Configurator.new

$logger = config.logger

def run_bot(pid, token, listener, ex_module=nil)
  $logger.debug 'bot start'
  Bot.new(pid: pid, token: token, listener: listener).bot
end

def register_handler(dest, token, listener)
  $logger.debug 'register handler start '
  Bot.new(pid: dest, token: token, listener: listener).handler
end

def stop_bot(pid, token, listener)
  $logger.debug 'stop bot'
  Bot.new(pid: pid, token: token, listener: listener).stop
end