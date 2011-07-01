require 'spec_helper'

module RubySpeech
  module SSML
    describe SayAs do
      subject { SayAs.new :interpret_as => 'one', :format => 'two', :detail => 'three' }

      its(:name) { should == 'say-as' }

      its(:interpret_as) { should == 'one' }
      its(:format)       { should == 'two' }
      its(:detail)       { should == 'three' }

      describe "without an :interpret_as option" do
        it "should raise an ArgumentError" do
          expect { SayAs.new }.should raise_error(ArgumentError, "You must specify a value for interpret_as")
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
