module Project106
  module RequestDataExtractor
    # Collecting data from rack to be send to project-106 server
    def extract_request_data_from_rack(env, exception)
      rack_req = Rack::Request.new(env)
      request_params = project_106_request_params(env)

      get_params = project_106_get_params(rack_req)
      post_params = project_106_post_params(rack_req)
      cookies = project_106_request_cookies(rack_req)
      session = env['rack.session.options']

      params = request_params.merge(get_params).merge(post_params)

      # Collect data from rails env.
      request_data = {
                      :params => params,
                      :url => project_106_url(env),
                      :user_ip => project_106_user_ip(env),
                      :headers => project_106_headers(env),
                      :method => project_106_request_method(env),
                      :error => {
                        :message => exception.message,
                        :backtrace => exception.backtrace,
                        :error_controller => params[:controller],
                        :error_action => params[:action]
                      }
                     }
      # Excluding session and cookies from request data
                      # :cookies => cookies,
                      # :session => session,

      # Data to be sent to project-106 server through api call in case of rails error except routing
      # sorting out data from request_data which might have extra data.
      # note : remove this once finalize data to be send to project-106 server
      # req_data = {
      #               "error_controller" => request_data[:params][:controller],
      #               "error_action" => request_data[:params][:action],
      #               "error_format" => "Not Assigned",
      #               "method" => request_data[:method],
      #               "path" => request_data[:url],
      #               "error" => "Not Assigned",
      #               "error_info" => exception.inspect
      #             }
    end

    # Data to be sent to project-106 server through api call in case of routing error
    def extract_request_data_from_payload(payload)

      # Note : remove this once finalize data to be send to project-106 server

      # {
      #   "error_controller" => payload[:controller],
      #   "error_action" => payload[:action],
      #   "error_format" => payload[:format],
      #   "method" => payload[:method],
      #   "path" => payload[:path],
      #   "error" => "routing error",
      #   "error_info" => "It may be that the user have misspelled or devs have forgot to ensure the path"
      # }

      request_data = {
                :params => "",
                :url => payload[:path],
                :user_ip => "",
                :headers => "",
                :method => payload[:method],
                :error => {
                  :message => "routing error",
                  :backtrace => "",
                  :error_controller => payload[:controller],
                  :error_action => payload[:action],
                }
               }
    end

    private

    # Methods for collecting data required in method "extract_request_data_from_rack"
    # from rack
    def project_106_request_params(env)
      route = ::Rails.application.routes.recognize_path(env['PATH_INFO']) rescue {}
      {
        :controller => route[:controller],
        :action => route[:action],
        :format => route[:format],
      }.merge(env['action_dispatch.request.parameters'] || {})
    end

    def project_106_get_params(rack_req)
      rack_req.GET
    rescue
      {}
    end

    def project_106_post_params(rack_req)
      rack_req.POST
    rescue
      {}
    end

    def project_106_request_cookies(rack_req)
      rack_req.cookies
    rescue
      {}
    end

    def project_106_url(env)
      scheme = env['rack.url_scheme']
      host = env['HTTP_HOST'] || env['SERVER_NAME']
      path = env['ORIGINAL_FULLPATH'] || env['REQUEST_URI']
      unless path.nil? || path.empty?
        path = '/' + path.to_s if path.to_s.slice(0, 1) != '/'
      end

      [scheme, '://', host, path].join
    end

    def project_106_user_ip(env)
      (env['action_dispatch.remote_ip'] || env['HTTP_X_REAL_IP'] || env['HTTP_X_FORWARDED_FOR'] || env['REMOTE_ADDR']).to_s
    end

    def project_106_headers(env)
      env.keys.grep(/^HTTP_/).map do |header|
        name = header.gsub(/^HTTP_/, '').split('_').map(&:capitalize).join('-')
        { name => env[header] }
      end.inject(:merge)
    end

    def project_106_request_method(env)
      env['REQUEST_METHOD'] || env[:method]
    end
  end
end