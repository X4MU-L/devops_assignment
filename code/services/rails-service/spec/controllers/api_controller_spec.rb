require 'rails_helper'

RSpec.describe ApiController, type: :controller do
  let(:service) { instance_double(ApiService) }
  before { allow(ApiService).to receive(:new).and_return(service) }

  describe 'GET #health' do
    it 'returns health status' do
      allow(service).to receive(:health_check).and_return(status: 'healthy', env: 'dev')
      get :health
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq('status' => 'healthy', 'env' => 'dev')
    end

    it 'handles empty service response' do
      allow(service).to receive(:health_check).and_return({})
      get :health
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq({})
    end
  end

  describe 'GET #chain' do
    it 'returns chain response' do
      allow(service).to receive(:chain_request).and_return(rails_service: 'healthy', python_service: 'healthy')
      get :chain
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq('rails_service' => 'healthy', 'python_service' => 'healthy')
    end

    it 'handles error response' do
      allow(service).to receive(:chain_request).and_return(error: 'Failed to reach Python service')
      get :chain
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq('error' => 'Failed to reach Python service')
    end
  end
end