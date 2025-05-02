require 'rails_helper'

RSpec.describe 'API Routes', type: :request do
  let(:service) { instance_double(ApiService) }
  before { allow(ApiService).to receive(:new).and_return(service) }

  describe 'GET /health' do
    it 'returns health status' do
      allow(service).to receive(:health_check).and_return(status: 'healthy', env: 'dev')
      get '/health'
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq('status' => 'healthy', 'env' => 'dev')
    end
  end

  describe 'GET /chain' do
    it 'returns chain response' do
      allow(service).to receive(:chain_request).and_return(rails_service: 'healthy', python_service: 'healthy')
      get '/chain'
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq('rails_service' => 'healthy', 'python_service' => 'healthy')
    end
  end

  describe 'Invalid methods' do
    it 'returns 405 for POST /health' do
      post '/health'
      expect(response).to have_http_status(:method_not_allowed)
    end

    it 'returns 405 for POST /chain' do
      post '/chain'
      expect(response).to have_http_status(:method_not_allowed)
    end
  end
end