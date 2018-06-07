require 'telegram/bot'
require_relative '../lib/responder'

class Bot
  include ErlPort::Erlang

  attr_accessor :logger, :pid, :token, :listener, :config

  def initialize(pid:, token:, listener:, **options)
    @config = Configurator.new

    @env = @config.env
    @logger = @config.logger
    @pid = pid
    @token = token
    @listener = listener
  end

  def bot
    send("#{@env}_bot")
  end

  def handler
    send("#{@env}_handler")
  end

  def stop
    bot = Telegram::Bot::Api.new(@token)
    @logger.debug "Delete webhook for #{@token}..."
    @logger.debug { bot.delete_webhook }
  end

  def development_bot
    Telegram::Bot::Client.run(@token) do |bot|
      bot.listen do |message|
        options = { bot: bot, message: message, listener: @listener, kind: :supervisor }
        @logger.debug "#{message.from.first_name} (chat_id - #{message.from.id}) : #{message}"
        MessageResponder.new(options).respond
      end
    end
  end

  def production_bot
    bot = Telegram::Bot::Api.new(@token)
    cert = File.open(@config.cert_file)
    url = @config.route(@token)
    @logger.debug "Setting webhook for #{@token}..."
    @logger.debug { bot.set_webhook(url: url, certificate: cert) }
  end

  def development_handler
    set_message_handler { |message|
      Telegram::Bot::Client.run(@token) do |bot|
        options = { bot: bot, message: message = JSON.parse(message), token: @token, kind: :user }
        @logger.debug "#{message.dig('data', 'chat', 'id')} : #{message['text']}"
        MessageResponder.new(options).respond
      end
    }
    ErlPort::Erlang::self()
  end

  def production_handler; end
end