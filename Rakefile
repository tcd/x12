require 'bundler/gem_tasks'

require 'rake'
require 'rake/testtask'

desc 'Test the plugin'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

# desc 'Test the plugin, and run benchmarks'
# Rake::TestTask.new(:benchmark) do |t|
#   ENV['BENCH'] = 'true'
#   t.libs << 'lib'
#   t.libs << 'test'
#   t.test_files = FileList['test/**/*_test.rb']
#   t.verbose = true
# end

task(default: :test)
