namespace :deps do
  desc 'Check and update Gemfile dependencies'
  task check: :environment do
    puts 'Checking Gemfile dependencies...'
    sh 'bundle check || bundle install'
    puts 'Dependencies are up to date.'
  end

  desc 'Generate Gemfile.lock'
  task generate_lock: :environment do
    puts 'Generating Gemfile.lock...'
    sh 'bundle install'
    if File.exist?('Gemfile.lock')
      puts 'Gemfile.lock generated successfully.'
    else
      puts 'Error: Gemfile.lock was not generated.'
      exit 1
    end
  end
end