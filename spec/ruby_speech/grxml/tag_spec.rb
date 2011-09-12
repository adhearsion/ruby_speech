require 'spec_helper'

module RubySpeech
  module GRXML
    describe Tag do
      its(:name) { should == 'tag' }

      it 'registers itself' do
        Element.class_from_registration(:tag).should == Tag
      end

      # TODO: more stuff...

    end # Tag
  end # GRXML
end # RubySpeech
