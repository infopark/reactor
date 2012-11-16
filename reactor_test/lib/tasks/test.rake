# Rake::Task['test'].clear
# 
# desc "Run all tests (specs)"
# task :test => ['cm:seed:test'] do
#   exec "bundle exec rspec ./spec/"
# end


# Remove release task
task :spec do ; end
task(:spec).clear_prerequisites.clear_actions

desc "Run all specs in spec directory"
RSpec::Core::RakeTask.new(:spec => ["cm:migrate", "cm:seed:test"])