namespace :lint do
  desc 'Run RuboCop to check code style'
  task check: :environment do
    sh 'bundle exec rubocop --format progress'
  end

  desc 'Run RuboCop with auto-correction'
  task fix: :environment do
    sh 'bundle exec rubocop --auto-correct-all --format progress'
  end
end