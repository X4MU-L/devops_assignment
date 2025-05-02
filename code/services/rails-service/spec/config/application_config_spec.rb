require 'rails_helper'

RSpec.describe ApplicationConfig do
  describe '#initialize' do
    it 'loads valid configuration' do
      ENV['PORT'] = '8083'
      ENV['PYTHON_SERVICE_URL'] = 'http://python-service:8082'
      config = ApplicationConfig.new
      expect(config.env).to eq('dev')
      expect(config.port).to eq(8083)
      expect(config.python_service_url).to eq('http://python-service:8082')
    end

    it 'raises error for missing PORT' do
      ENV.delete('PORT')
      ENV['PYTHON_SERVICE_URL'] = 'http://python-service:8082'
      expect { ApplicationConfig.new }.to raise_error(ArgumentError, 'PORT is required')
    end

    it 'raises error for missing PYTHON_SERVICE_URL' do
      ENV['PORT'] = '8083'
      ENV.delete('PYTHON_SERVICE_URL')
      expect { ApplicationConfig.new }.to raise_error(ArgumentError, 'PYTHON_SERVICE_URL is required')
    end

    it 'raises error for invalid PORT' do
      ENV['PORT'] = 'invalid'
      ENV['PYTHON_SERVICE_URL'] = 'http://python-service:8082'
      expect { ApplicationConfig.new }.to raise_error(ArgumentError, 'PORT is required')
    end
  end
end