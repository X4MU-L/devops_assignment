namespace :health do
  desc 'Check the health of the Rails service'
  task check: :environment do
    require 'httparty'
    config = ApplicationConfig.new
    response = HTTParty.get("http://localhost:#{config.port}/health", timeout: 5)
    if response.code == 200 && response['status'] == 'healthy'
      puts "Rails service is healthy (env: #{response['env']})"
    else
      puts "Health check failed: #{response.code} #{response.body}"
      exit 1
    end
  rescue StandardError => e
    puts "Health check failed: #{e.message}"
    exit 1
  end
end