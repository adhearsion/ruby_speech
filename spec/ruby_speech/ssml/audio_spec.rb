require 'spec_helper'

module RubySpeech
  module SSML
    describe Audio do
      its(:name) { should == 'audio' }

      describe "setting options in initializers" do
        subject { Audio.new :src => 'http://whatever.you-say-boss.com', :content => 'Hello' }

        its(:src)     { should == 'http://whatever.you-say-boss.com' }
        its(:content) { should == 'Hello' }
      end

      it 'registers itself' do
        Element.class_from_registration(:audio).should == Audio
      end

      describe "from a document" do
        let(:document) { '<audio src="http://whatever.you-say-boss.com">Hello</audio>' }

        subject { Element.import document }

        it { should be_instance_of Audio }

        its(:src)     { should == 'http://whatever.you-say-boss.com' }
        its(:content) { should == 'Hello' }
      end

      describe "#src" do
        before { subject.src = 'http://whatever.you-say-boss.com' }

        its(:src) { should == 'http://whatever.you-say-boss.com' }
      end

      describe "#content" do
        context "with a valid value" do
          before { subject.content = "Hello" }

          its(:content) { should == "Hello" }
        end
      end

      describe "<<" do
        it "should accept String" do
          lambda { subject << 'anything' }.should_not raise_error
        end

        it "should accept Audio" do
          lambda { subject << Audio.new }.should_not raise_error
        end

        it "should accept Break" do
          lambda { subject << Break.new }.should_not raise_error
        end

        it "should accept Desc" do
          lambda { subject << Desc.new }.should_not raise_error
        end

        it "should accept Emphasis" do
          lambda { subject << Emphasis.new }.should_not raise_error
        end

        it "should accept Mark" do
          lambda { subject << Mark.new }.should_not raise_error
        end

        it "should accept P" do
          lambda { subject << P.new }.should_not raise_error
        end

        it "should accept Phoneme" do
          pending
          lambda { subject << Phoneme.new }.should_not raise_error
        end

        it "should accept Prosody" do
          lambda { subject << Prosody.new }.should_not raise_error
        end

        it "should accept SayAs" do
          lambda { subject << SayAs.new(:interpret_as => :foo) }.should_not raise_error
        end

        it "should accept Sub" do
          lambda { subject << Sub.new }.should_not raise_error
        end

        it "should accept S" do
          lambda { subject << S.new }.should_not raise_error
        end

        it "should accept Voice" do
          lambda { subject << Voice.new }.should_not raise_error
        end

        it "should raise InvalidChildError with non-acceptable objects" do
          lambda { subject << 1 }.should raise_error(InvalidChildError, "An Audio can only accept String, Audio, Break, Emphasis, Mark, P, Phoneme, Prosody, SayAs, Sub, S, Voice as children")
        end
      end

      describe "comparing objects" do
        it "should be equal if the content, and src are the same" do
          Audio.new(:src => "one", :content => "Hello there").should == Audio.new(:src => "one", :content => "Hello there")
        end

        describe "when the content is different" do
          it "should not be equal" do
            Audio.new(:content => "Hello").should_not == Audio.new(:content => "Hello there")
          end
        end

        describe "when the src is different" do
          it "should not be equal" do
            Audio.new(:src => 'one').should_not == Audio.new(:src => 'two')
          end
        end
      end
    end # Break
  end # SSML
end # RubySpeech
