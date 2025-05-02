class ApiController < ApplicationController
    def initialize(service = ApiService.new)
      @service = service
      super()
      Rails.logger.info('Initialized ApiController')
    end
  
    def health
      Rails.logger.debug('Handling health endpoint')
      render json: @service.health_check, status: :ok
    end
  
    def chain
      Rails.logger.debug('Handling chain endpoint')
      render json: @service.chain_request, status: :ok
    end
  end