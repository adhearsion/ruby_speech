require 'spec_helper'

module RubySpeech
  module GRXML
    describe OneOf do
      its(:name) { should == 'one-of' }

      it 'registers itself' do
        Element.class_from_registration(:'one-of').should == OneOf
      end

      describe "from a document" do
        let(:document) { '<one-of> <item>test</item> </one-of>' }

        subject { Element.import parse_xml(document).root }

        it { should be_instance_of OneOf }
      end

      # TODO: ensure it has at least one item element

    end # OneOf
  end # GRXML
end # RubySpeech
