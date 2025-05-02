require 'rails_helper'

RSpec.describe ApiService do
  let(:config) { ApplicationConfig.new }
  let(:service) { ApiService.new(config) }

  describe '#health_check' do
    it 'returns healthy status and env' do
      result = service.health_check
      expect(result).to eq(status: 'healthy', env: config.env)
      expect(result[:env]).to eq('dev')
    end
  end

  describe '#chain_request' do
    it 'returns successful response from Python service' do
      VCR.use_cassette('python_service_chain_success') do
        result = service.chain_request
        expect(result[:rails_service]).to eq('healthy')
        expect(result[:python_service]).to include('python_service')
      end
    end

    it 'handles timeout error' do
      stub_request(:get, "#{config.python_service_url}/chain").to_timeout
      result = service.chain_request
      expect(result[:error]).to match(/Failed to reach Python service: execution expired/)
    end

    it 'handles non-200 response' do
      stub_request(:get, "#{config.python_service_url}/chain").to_return(status: 500, body: 'Server Error')
      result = service.chain_request
      expect(result[:error]).to match(/Failed to reach Python service: 500/)
    end

    it 'handles malformed response' do
      stub_request(:get, "#{config.python_service_url}/chain").to_return(status: 200, body: '')
      result = service.chain_request
      expect(result[:rails_service]).to eq('healthy')
      expect(result[:python_service]).to eq('')
    end
  end
end