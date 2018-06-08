require 'telegram/bot'
require_relative '../lib/responder'

class Bot
  include ErlPort::Erlang

  attr_accessor :logger, :pid, :token, :listener, :config, :message

  def initialize(pid:, token:, listener:, **options)
    @config = Configurator.new

    @env = @config.env
    @logger = @config.logger
    @pid = pid
    @token = token
    @listener = listener
    @message = options[:message]
  end

  def bot
    send("#{@env}_bot")
  end

  def handler
    send("#{@env}_handler")
  end

  def stop
    api = Telegram::Bot::Client.new(@token).api
    @logger.debug "Delete webhook for #{@token}..."
    @logger.debug { api.delete_webhook }
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
    api = Telegram::Bot::Client.new(@token).api
    cert = Faraday::UploadIO.new(config.cert_file, 'application/x-pem-file')
    url = @config.route(@token)
    @logger.debug "Setting webhook for #{@token}..."
    @logger.debug { api.set_webhook(url: url, certificate: cert) }
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

  def forward
    @logger.debug "#{@message.dig('from', 'first_name')} (chat_id - #{@message.dig('from', 'id')}) : #{@message}"
    bot = Telegram::Bot::Client.new(@token)
    options = { bot: bot, message: @message, listener: @listener, kind: :supervisor}
    MessageResponder.new(options).user
  end
end