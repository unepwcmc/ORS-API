if Rails.env.production? || Rails.env.staging?
  require 'exception_notification/rails'

  ExceptionNotification.configure do |config|
    # Ignore additional exception types.
    # ActiveRecord::RecordNotFound, AbstractController::ActionNotFound and ActionController::RoutingError are already added.
    # config.ignored_exceptions += %w{ActionView::TemplateError CustomError}

    # Adds a condition to decide when an exception must be ignored or not.
    # The ignore_if method can be invoked multiple times to add extra conditions.
    config.ignore_if do |exception, options|
      not (Rails.env.production? || Rails.env.staging?)
    end

    # Notifiers =================================================================

    # Email notifier sends notifications by email.
    config.add_notifier :email, {
      email_prefix:         "[ORS-API #{Rails.env}] ",
      sender_address:       %{"Exception Notification" <no-reply@unep-wcmc.org>},
      exception_recipients: Rails.application.secrets.exception_notification_email
    }

    # Campfire notifier sends notifications to your Campfire room. Requires 'tinder' gem.
    # config.add_notifier :campfire, {
    #   :subdomain => 'my_subdomain',
    #   :token => 'my_token',
    #   :room_name => 'my_room'
    # }

    # HipChat notifier sends notifications to your HipChat room. Requires 'hipchat' gem.
    # config.add_notifier :hipchat, {
    #   :api_token => 'my_token',
    #   :room_name => 'my_room'
    # }

    config.add_notifier :slack, {
      :webhook_url => Rails.application.secrets.slack_exception_notification_webhook_url,
      :channel => "#online-reporting-tool",
      :username => "TheTormentingBotOfORS-API-#{Rails.env}"
    }

  end
end
