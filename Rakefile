require 'bundler/gem_tasks'

require 'rake'
require 'rake/testtask'
require 'rdoc/task'

desc 'Test the plugin'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  # t.pattern = 'test/t*.rb'
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

desc 'Generate RDoc docs'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'X12'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.md')
  rdoc.rdoc_files.include('lib/**/*.rb')
end


task :default => :test