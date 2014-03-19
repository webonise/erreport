require 'project_106/log_reporter'
require 'project_106/request_data_extractor'

module Project106
  module ExceptionReporter
    include LogReporter
    include RequestDataExtractor
    def report_exception_to_project_106(env, exception)
      report_log "[Project106] Reporting Exception: #{exception}", :error
      req_data = extract_request_data_from_rack(env, exception)
      Project106.report_exception_to_project_106_server(req_data)
    end
  end
end