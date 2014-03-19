module Project106
  module LogReporter
    # Call to the rails default logger method with message and level
    # level can be error, debug, info, etc
    def report_log(message, level = :debug)
      if defined?(Rails)
        ::Rails.logger.send(level, message)
      else
        puts message
      end
    end
  end
end