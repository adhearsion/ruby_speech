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

        subject { Element.import document }

        it { should be_instance_of OneOf }
      end

      describe "#language" do
        before { subject.language = 'fr-CA' }

        its(:language) { should == 'fr-CA' }
      end

      describe "<<" do
        it "should accept Item" do
          lambda { subject << Item.new }.should_not raise_error
        end

        it "should raise InvalidChildError with non-acceptable objects" do
          lambda { subject << 1 }.should raise_error(InvalidChildError, "A OneOf can only accept Item as children")
        end
      end

      describe "comparing objects" do
        it "should be equal if the language (when specified) is the same" do
          OneOf.new(:language => "jp").should == OneOf.new(:language => "jp")
        end

        describe "when the language is different" do
          it "should not be equal" do
            OneOf.new(:language => "jp").should_not == OneOf.new(:content => "fr-CA")
          end
        end
      end

      describe "#potential_match?" do
        before do
          items.each { |item| subject << item }
        end

        context "with a single item of '6'" do
          let(:items) { [Item.new << (Token.new << '6')] }

          it "should be true for '6'" do
            subject.potential_match?('6').should be true
          end

          %w{5 7}.each do |input|
            it "should be false for '#{input}'" do
              subject.potential_match?(input).should be false
            end
          end
        end

        context "with options of '6' or '7'" do
          let(:items) { [Item.new << (Token.new << '6'), Item.new << (Token.new << '7')] }

          %w{6 7}.each do |input|
            it "should be true for '#{input}'" do
              subject.potential_match?(input).should be true
            end
          end

          %w{5 8 67 76}.each do |input|
            it "should be false for '#{input}'" do
              subject.potential_match?(input).should be false
            end
          end
        end

        context "with options of '67' or '25'" do
          let(:items) { [Item.new << (Token.new << '6') << (Token.new << '7'), Item.new << (Token.new << '2') << (Token.new << '5')] }

          %w{6 2}.each do |input|
            it "should be true for '#{input}'" do
              subject.potential_match?(input).should be true
            end
          end

          %w{3 7 5 65 27 76 52}.each do |input|
            it "should be false for '#{input}'" do
              subject.potential_match?(input).should be false
            end
          end
        end

        context "with options of '678' or '251'" do
          let(:items) { [Item.new << (Token.new << '6') << (Token.new << '7') << (Token.new << '8'), Item.new << (Token.new << '2') << (Token.new << '5') << (Token.new << '1')] }

          %w{6 67 2 25}.each do |input|
            it "should be true for '#{input}'" do
              subject.potential_match?(input).should be true
            end
          end

          %w{3 7 5 65 27 76 52}.each do |input|
            it "should be false for '#{input}'" do
              subject.potential_match?(input).should be false
            end
          end
        end

        context "with options of '6' or ('7' repeated twice)" do
          let(:items) { [Item.new << (Token.new << '6'), Item.new << (Item.new(:repeat => 2) << (Token.new << '7'))] }

          %w{6 7 77}.each do |input|
            it "should be true for '#{input}'" do
              pending
              subject.potential_match?(input).should be true
            end
          end

          %w{5 67 76 66}.each do |input|
            it "should be false for '#{input}'" do
              subject.potential_match?(input).should be false
            end
          end
        end
      end

      describe "#longest_potential_match" do
        before do
          items.each { |item| subject << item }
        end

        context "with a single item of '6'" do
          let(:items) { [Item.new << (Token.new << '6')] }

          %w{6 65 6776}.each do |input|
            it "should be '6' for '#{input}'" do
              subject.longest_potential_match(input).should == '6'
            end
          end

          %w{5 7 55 56}.each do |input|
            it "should be '' for '#{input}'" do
              subject.longest_potential_match(input).should == ''
            end
          end
        end

        context "with options of '6' or '7'" do
          let(:items) { [Item.new << (Token.new << '6'), Item.new << (Token.new << '7')] }

          %w{6 65 6776}.each do |input|
            it "should be '6' for '#{input}'" do
              subject.longest_potential_match(input).should == '6'
            end
          end

          %w{7 74 726}.each do |input|
            it "should be '7' for '#{input}'" do
              subject.longest_potential_match(input).should == '7'
            end
          end

          %w{5 55 56}.each do |input|
            it "should be '' for '#{input}'" do
              subject.longest_potential_match(input).should == ''
            end
          end
        end

        context "with options of '67' or '25'" do
          let(:items) { [Item.new << (Token.new << '6') << (Token.new << '7'), Item.new << (Token.new << '2') << (Token.new << '5')] }

          %w{6}.each do |input|
            it "should be '6' for '#{input}'" do
              subject.longest_potential_match(input).should == '6'
            end
          end

          %w{67 675 6767 6756}.each do |input|
            it "should be '67' for '#{input}'" do
              subject.longest_potential_match(input).should == '67'
            end
          end

          %w{2}.each do |input|
            it "should be '2' for '#{input}'" do
              subject.longest_potential_match(input).should == '2'
            end
          end

          %w{25 259 2525 2567}.each do |input|
            it "should be '25' for '#{input}'" do
              subject.longest_potential_match(input).should == '25'
            end
          end

          %w{5 7 72 56}.each do |input|
            it "should be '' for '#{input}'" do
              subject.longest_potential_match(input).should == ''
            end
          end
        end

        context "with options of '678' or '251'" do
          let(:items) { [Item.new << (Token.new << '6') << (Token.new << '7') << (Token.new << '8'), Item.new << (Token.new << '2') << (Token.new << '5') << (Token.new << '1')] }

          %w{6}.each do |input|
            it "should be '6' for '#{input}'" do
              subject.longest_potential_match(input).should == '6'
            end
          end

          %w{67 675 6767 6756}.each do |input|
            it "should be '67' for '#{input}'" do
              subject.longest_potential_match(input).should == '67'
            end
          end

          %w{678 6785 678678 67856}.each do |input|
            it "should be '678' for '#{input}'" do
              subject.longest_potential_match(input).should == '678'
            end
          end

          %w{2}.each do |input|
            it "should be '2' for '#{input}'" do
              subject.longest_potential_match(input).should == '2'
            end
          end

          %w{25 259 2525 2567}.each do |input|
            it "should be '25' for '#{input}'" do
              subject.longest_potential_match(input).should == '25'
            end
          end

          %w{251 2519 251251 25167}.each do |input|
            it "should be '251' for '#{input}'" do
              subject.longest_potential_match(input).should == '251'
            end
          end

          %w{5 7 72 56}.each do |input|
            it "should be '' for '#{input}'" do
              subject.longest_potential_match(input).should == ''
            end
          end
        end

        context "with options of '6' or '7' repeated twice" do
          let(:items) { [Item.new << (Token.new << '6'), Item.new << (Item.new(:repeat => 2) << (Token.new << '7'))] }

          %w{6 65 6776}.each do |input|
            it "should be '6' for '#{input}'" do
              subject.longest_potential_match(input).should == '6'
            end
          end

          %w{7 74 726}.each do |input|
            it "should be '7' for '#{input}'" do
              subject.longest_potential_match(input).should == '7'
            end
          end

          %w{7 77 774 7726}.each do |input|
            it "should be '77' for '#{input}'" do
              pending
              subject.longest_potential_match(input).should == '77'
            end
          end

          %w{5 55 56}.each do |input|
            it "should be '' for '#{input}'" do
              subject.longest_potential_match(input).should == ''
            end
          end
        end
      end
    end # OneOf
  end # GRXML
end # RubySpeech
