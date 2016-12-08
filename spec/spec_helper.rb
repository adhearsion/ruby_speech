# encoding: utf-8

%w{
  ruby_speech
  rspec/its
}.each { |f| require f }

require 'coveralls'
Coveralls.wear!

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f}

schema_file_path = File.expand_path File.join(__FILE__, '../../assets/synthesis.xsd')
puts "Loading the SSML Schema from #{schema_file_path}..."
SSML_SCHEMA = Nokogiri::XML::Schema File.open(schema_file_path)
puts "Finished loading schema."

schema_file_path = File.expand_path File.join(__FILE__, '../../assets/grammar.xsd')
puts "Loading the GRXML Schema from #{schema_file_path}..."
GRXML_SCHEMA = Nokogiri::XML::Schema File.open(schema_file_path)
puts "Finished loading schema."

RSpec.configure do |config|
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
  config.treat_symbols_as_metadata_keys_with_true_values = true
end
