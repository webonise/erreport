module Project106
  class Configuration

    attr_accessor :access_token
    attr_accessor :endpoint

    DEFAULT_ENDPOINT = 'http://stage106.weboapps.com/api/v1/error_requests/'

    def initialize
      @endpoint = DEFAULT_ENDPOINT
    end
  end
end
