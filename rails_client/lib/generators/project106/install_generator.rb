require 'rails/generators'
require 'rails/generators/named_base'

module Project106
  class InstallGenerator < Rails::Generators::Base
    argument :access_token, :type => :string, :banner => 'access_token', :default => :use_env_sentinel

    source_root File.expand_path("../templates", __FILE__)

    def create_initializer
      say "creating initializer..."
      if access_token_configured?
        say "It looks like you've already configured Project106."
        say "To re-create the config file, remove it first: config/initializers/project_106.rb"
        exit
      end

      if access_token === :use_env_sentinel
        say "Generator run without an access token; assuming you want to configure using an environment variable."
        say "You'll need to add an environment variable PROJECT106_ACCESS_TOKEN with your access token:"
        say "\n$ export PROJECT106_ACCESS_TOKEN=yourtokenhere"
        say "\nIf that's not what you wanted to do:"
        say "\n$ rm config/initializers/project_106.rb"
        say "$ rails generate project106:install yourtokenhere"
        say "\n"
      else
        say "access token: " << access_token
      end

      template 'initializer.rb', 'config/initializers/project_106.rb',
        :assigns => { :access_token => access_token_expr }
    end

    def access_token_expr
      if access_token === :use_env_sentinel
        "ENV['PROJECT106_ACCESS_TOKEN']"
      else
        "'#{access_token}'"
      end
    end

    def access_token_configured?
      File.exists?('config/initializers/project_106.rb')
    end
  end
end