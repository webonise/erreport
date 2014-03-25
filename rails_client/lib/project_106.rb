require 'net/http'
require "json"
require "shellwords"
require "fileutils"
require 'benchmark'
require "project_106/version"
require "project_106/configuration"
require 'project_106/exception_reporter'
require 'project_106/log_reporter'
require 'rails'
require "project_106/railtie" if defined? Rails
require "active_support/dependencies"

module Project106
  include LogReporter

  # install nodeJS on client machine
  def self.install_nodejs
    puts "Installing nodejs dependencies\n"
    `sudo apt-get install python-software-properties python g++ make`
    puts "Adding nodejs ppa\n"
    `sudo add-apt-repository ppa:chris-lea/node.js`
    puts "Updating system\n"
    `sudo apt-get update`
    puts "Installing nodeJS\n"
    `sudo apt-get install nodejs`
    puts "NodeJS Installed ...\n"
  end

  class << self
    attr_writer :configuration
    include LogReporter

    def configure
      yield(configuration)
    end

    def configuration
      @configuration ||= Configuration.new
    end

    # give memory usage of process using unix shell command
    # def get_memory_usage
    #   `ps -o rss= -p #{Process.pid}`.to_i
    # end

    def append_access_token_to_data(data)
      data[:api_key] = configuration.access_token
      data
    end

    # Making api call to send error report to project-106 server
    def report_exception_to_project_106_server(data)

      # Append api_key to data
      data = append_access_token_to_data(data)

      # If handler == node then request data will be pass to nodejs to make api call
      # If handler == ruby then request data will be directly pass through ruby api call
      handler = "node"
      begin
        # benchmarking code
        # Benchmark.bm do |bm|

          if handler == "node"
            # bm.report("Node") do

            #   before = get_memory_usage
            #   report_log "BEFORE: " + before.to_s


              # Pass request data to node_handler.js which will make api call to project-106-server
              # Stringifing data
              jdata = data.to_json
              # Get node_handler path
              node_handler = File.join(File.dirname(__FILE__), "node_handler.js")
              report_log "[Project-106] Calling NODE script to send data to project-106 server"
              `node #{node_handler} #{Shellwords.escape(jdata)}`

              # after = get_memory_usage
              # report_log "AFTER: " + (after).to_s
              # report_log "Node Memory Usage: " + (after-before).to_s

            # end
          else
            # bm.report("Ruby") do

            #   before = get_memory_usage
            #   report_log "BEFORE: " + before.to_s

              # Ruby api call to pass request data to project-106-server
              report_log "[Project-106] Calling RUBY script to send data to project-106 server"
              url = URI.parse('http://localhost:3000/api/v1/error_reports')
              resp = Net::HTTP.post_form(url, data)
              report_log "[Project-106] Exception Reported to Project-106 server"
              # after = get_memory_usage
              # report_log "AFTER: " + (after).to_s
              # report_log "Ruby Memory Usage: " + (after-before).to_s

            # end
          end

        # end
      rescue => e
        report_log "[Project-106] Error reporting exception to Project-106: #{e}"
      end
    end
  end
end

# Require engine
require "project_106/engine"
