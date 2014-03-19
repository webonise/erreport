require 'active_support/all'
require 'rails'
require 'project_106/log_reporter'
require 'project_106/request_data_extractor'

module Project106
  class Railtie < Rails::Railtie
    include RequestDataExtractor
    include LogReporter

    config.after_initialize do
      # Catch uninitialized typed errors in ErrorController#routing
      ActiveSupport::Notifications.subscribe "process_action.action_controller" do |name, start, finish, id, payload|
        if payload[:exception].present?
        elsif payload[:controller] == "Project106::ErrorController"
          req_data = extract_request_data_from_payload(payload)
          Project106.report_exception_to_project_106_server(req_data)
          report_log "[Project-106] Uninitialized Routing Error"
        end
      end

      # Catch all other rails error except routing error in the same way as rails did
      if defined?(ActionDispatch::DebugExceptions)
        # Rails 3.2.x
        require 'project_106/middleware/rails/show_exceptions'
        ActionDispatch::DebugExceptions.send(:include, Project106::Middleware::Rails::ShowExceptions)
      elsif defined?(ActionDispatch::ShowExceptions)
        # Rails 3.0.x and 3.1.x
        require 'project_106/middleware/rails/show_exceptions'
        ActionDispatch::ShowExceptions.send(:include, Project106::Middleware::Rails::ShowExceptions)
      end

    end
  end
end