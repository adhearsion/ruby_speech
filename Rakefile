require 'bundler/gem_tasks'
Bundler::GemHelper.install_tasks

require 'rspec/core'
require 'rspec/core/rake_task'
require 'ci/reporter/rake/rspec'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rspec_opts = '--color'
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
  spec.rspec_opts = '--color'
end

task :default => [:compile, :spec]
task :ci => ['ci:setup:rspec', :compile, :spec]

require 'yard'
YARD::Rake::YardocTask.new

if RUBY_PLATFORM =~ /java/
  require 'rake/javaextensiontask'
  Rake::JavaExtensionTask.new 'ruby_speech' do |ext|
    ext.lib_dir = 'lib/ruby_speech'
  end
else
  require 'rake/extensiontask'
  Rake::ExtensionTask.new 'ruby_speech' do |ext|
    ext.lib_dir = 'lib/ruby_speech'
  end
end
