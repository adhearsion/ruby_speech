require 'spec_helper'

module RubySpeech
  module SSML
    describe SayAs do
      subject { SayAs.new 'one', :format => 'two', :detail => 'three' }

      its(:name) { should == 'say-as' }

      its(:interpret_as) { should == 'one' }
      its(:format)       { should == 'two' }
      its(:detail)       { should == 'three' }

      describe "without interpret_as" do
        it "should raise an ArgumentError" do
          expect { SayAs.new }.should raise_error(ArgumentError)
        end
      end

      describe "comparing objects" do
        it "should be equal if the content, interpret_as, format, age, variant, name are the same" do
          SayAs.new('jp', :format => 'foo', :detail => 'bar', :content => "hello").should == SayAs.new('jp', :format => 'foo', :detail => 'bar', :content => "hello")
        end

        describe "when the content is different" do
          it "should not be equal" do
            SayAs.new('jp', :content => "Hello").should_not == SayAs.new('jp', :content => "Hello there")
          end
        end

        describe "when the interpret_as is different" do
          it "should not be equal" do
            SayAs.new("Hello").should_not == SayAs.new("Hello there")
          end
        end

        describe "when the format is different" do
          it "should not be equal" do
            SayAs.new('jp', :format => 'foo').should_not == SayAs.new('jp', :format => 'bar')
          end
        end

        describe "when the detail is different" do
          it "should not be equal" do
            SayAs.new('jp', :detail => 'foo').should_not == SayAs.new('jp', :detail => 'bar')
          end
        end
      end

      describe "<<" do
        it "should accept String" do
          lambda { subject << 'anything' }.should_not raise_error
        end

        it "should raise InvalidChildError with non-acceptable objects" do
          lambda { subject << Voice.new }.should raise_error(InvalidChildError, "A SayAs can only accept Strings as children")
        end
      end
    end # SayAs
  end # SSML
end # RubySpeech
