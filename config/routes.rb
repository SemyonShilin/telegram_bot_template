Rails.application.routes.draw do
  telegram_webhook TelegramWebhooksController
  # rails encrypted:edit config/staging-credentials.yml.enc --key config/staging.key
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
