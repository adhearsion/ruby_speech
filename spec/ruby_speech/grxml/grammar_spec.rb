require 'spec_helper'

module RubySpeech
  module GRXML
    describe Grammar do
      it { should be_a_valid_grxml_document }

      its(:name) { should == 'grammar' }
      its(:language) { should == 'en-US' }

      describe "setting options in initializers" do
        subject { Grammar.new :language => 'jp', :base_uri => 'blah', :root => "main_rule" }

        puts subject.to_s
        its(:language) { should == 'jp' }
        its(:base_uri) { should == 'blah' }
        its(:root) { should == 'main_rule' }
      end

#      describe "setting mode" do
#        subject { Grammar.new :mode => 'dtmf' }
#        it "should allow dtmf" do
#          its(:mode) { should == 'dtmf' }
#        end
#
#        subject { Grammar.new :mode => 'voice' }
#        it "should allow voice" do
#          its(:mode) { should == 'voice' }
#        end
#      end

      it 'registers itself' do
        Element.class_from_registration(:grammar).should == Grammar
      end


    end # Grammar
  end # GRXML
end # RubySpeech
