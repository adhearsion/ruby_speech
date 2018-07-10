require 'spec_helper'

module RubySpeech
  module GRXML
    describe Ruleref do
      let(:doc) { Nokogiri::XML::Document.new }

      subject { Ruleref.new doc, :uri => '#testrule' }

      its(:name)  { should == 'ruleref' }
      its(:uri)   { should == '#testrule' }

      it 'registers itself' do
        expect(Element.class_from_registration(:ruleref)).to eq(Ruleref)
      end

      describe "from a document" do
        let(:document) { '<ruleref uri="#one" />' }

        subject { Element.import document }

        it { is_expected.to be_instance_of Ruleref }

        its(:uri) { should == '#one' }
      end

      describe "#special" do
        subject { Ruleref.new doc }

        context "with reserved values" do
          it "with a valid value" do
            expect { subject.special = :NULL }.not_to raise_error
            expect { subject.special = :VOID }.not_to raise_error
            expect { subject.special = 'GARBAGE' }.not_to raise_error
          end
          it "with an invalid value" do
            expect { subject.special = :SOMETHINGELSE }.to raise_error
          end
        end
      end

      describe "#uri" do
        it "allows implict, explicit and external references" do
          expect { subject.uri = '#dtmf' }.not_to raise_error
          expect { subject.uri = '../test.grxml' }.not_to raise_error
          expect { subject.uri = 'http://grammar.example.com/world-cities.grxml#canada' }.not_to raise_error
        end
      end

      describe "only uri or special can be specified" do
        it "should raise an error" do
          expect { subject << Ruleref.new(doc, :uri => '#test', :special => :NULL) }.to raise_error(ArgumentError, "A Ruleref can only take uri or special")
        end
      end
    end # Ruleref
  end # GRXML
end # RubySpeech
