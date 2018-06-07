# require 'active_support'
require 'dotenv'
require_relative 'multi_logger'

class Configurator
  attr_accessor :env, :cert_file
  attr_reader :host

  def initialize
    Dotenv.load
    @env = ENV['BOT_ENV']
    @cert_file = ENV['CERT_FILE']
    @host = ENV['APP_HOST']
  end

  def logger
    Logger.new MultiLogger.new(STDERR, File.open("#{@env}.telegram.log", 'a'))
  end

  def route(token)
    "#{@host}/telegram/#{token}/"
  end
end