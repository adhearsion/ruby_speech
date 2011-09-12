require 'spec_helper'

module RubySpeech
  module GRXML
    describe Item do
      subject { Item.new :weight => 1.1, :repeat => '1' }

      its(:name) { should == 'item' }

      its(:weight)  { should == 1.1 }
      its(:repeat)  { should == '1' }

      it 'registers itself' do
        Element.class_from_registration(:item).should == Item
      end

      describe "from a document" do
        let(:document) { '<item weight="1.1" repeat="1">one</item>' }

        subject { Element.import parse_xml(document).root }

        it { should be_instance_of Item }

        its(:weight)  { should == 1.1 }
        its(:repeat)  { should == '1' }
        its(:content) { should == 'one' }
      end

      # TODO: validate various values for weight
      # TODO: validate various values for repeat
      # TODO: validate various values for language
    end # Item
  end # GRXML
end # RubySpeech
