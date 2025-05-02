namespace :ci do
  desc 'Run all tests and linting for CI/CD'
  task test: %w[deps:generate_lock spec lint:check] do
    puts 'CI tests and linting completed successfully.'
  end
end