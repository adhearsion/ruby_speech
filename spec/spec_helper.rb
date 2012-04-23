require 'ruby_speech'
require 'mocha'

include RubySpeech::GRXML
include RubySpeech::XML::Language

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
  config.mock_with :mocha
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
end
