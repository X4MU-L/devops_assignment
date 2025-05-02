class ApplicationConfig
    attr_reader :env, :port, :python_service_url
  
    def initialize
      @env = ENV['ENV'] || 'dev'
      @port = (ENV['PORT'] || '8083').to_i
      @python_service_url = ENV['PYTHON_SERVICE_URL'] || 'http://python-service:8082'
      validate
    end
  
    private
  
    def validate
      Rails.logger.error('PORT is required') if @port.zero?
      Rails.logger.error('PYTHON_SERVICE_URL is required') if @python_service_url.empty?
      raise ArgumentError, 'PORT is required' if @port.zero?
      raise ArgumentError, 'PYTHON_SERVICE_URL is required' if @python_service_url.empty?
      Rails.logger.info("Loaded config: env=#{@env}, port=#{@port}, python_service_url=#{@python_service_url}")
    end
  end