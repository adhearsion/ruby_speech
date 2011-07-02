require 'spec_helper'

module RubySpeech
  module SSML
    describe Speak do
      it { should be_a_valid_ssml_document }

      its(:name) { should == 'speak' }
      its(:language) { should == 'en-US' }

      describe "setting options in initializers" do
        subject { Speak.new :language => 'jp', :base_uri => 'blah' }

        its(:language) { should == 'jp' }
        its(:base_uri) { should == 'blah' }
      end

      describe "#language" do
        before { subject.language = 'jp' }

        its(:language) { should == 'jp' }
      end

      describe "#base_uri" do
        before { subject.base_uri = 'blah' }

        its(:base_uri) { should == 'blah' }
      end

      describe "comparing objects" do
        it "should be equal if the content, language and base uri are the same" do
          Speak.new(language: 'en-GB', base_uri: 'blah', content: "Hello there").should == Speak.new(language: 'en-GB', base_uri: 'blah', content: "Hello there")
        end

        describe "when the content is different" do
          it "should not be equal" do
            Speak.new(content: "Hello").should_not == Speak.new(content: "Hello there")
          end
        end

        describe "when the language is different" do
          it "should not be equal" do
            Speak.new(language: 'en-US').should_not == Speak.new(language: 'en-GB')
          end
        end

        describe "when the base URI is different" do
          it "should not be equal" do
            Speak.new(base_uri: 'foo').should_not == Speak.new(base_uri: 'bar')
          end
        end
      end
    end # Speak
  end # SSML
end # RubySpeech
