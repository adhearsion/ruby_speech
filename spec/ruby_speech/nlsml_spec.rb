require 'spec_helper'

describe RubySpeech::NLSML do
  let :example_document do
    '''
<result xmlns="http://www.w3c.org/2000/11/nlsml" xmlns:xf="http://www.w3.org/2000/xforms" xmlns:myApp="foo" grammar="http://flight">
  <interpretation confidence="60">
    <input mode="speech">I want to go to Pittsburgh</input>
    <xf:model>
      <xf:group name="airline">
        <xf:string name="to_city"/>
      </xf:group>
    </xf:model>
    <xf:instance>
      <myApp:airline>
        <myApp:to_city>Pittsburgh</myApp:to_city>
      </myApp:airline>
    </xf:instance>
  </interpretation>
  <interpretation confidence="40">
    <input>I want to go to Stockholm</input>
    <xf:model>
      <xf:group name="airline">
        <xf:string name="to_city"/>
      </xf:group>
    </xf:model>
    <xf:instance>
      <myApp:airline>
        <myApp:to_city>Stockholm</myApp:to_city>
      </myApp:airline>
    </xf:instance>
  </interpretation>
</result>
    '''
  end

  describe 'drawing a document' do
    let :expected_document do
      Nokogiri::XML(example_document).to_xml
    end

    it "should allow building a document" do
      document = RubySpeech::NLSML.draw(grammar: 'http://flight', 'xmlns:myApp' => 'foo') do
        interpretation confidence: 0.6 do
          input "I want to go to Pittsburgh", mode: :speech

          model do
            group name: 'airline' do
              string name: 'to_city'
            end
          end

          instance do
            self['myApp'].airline do
              to_city 'Pittsburgh'
            end
          end
        end

        interpretation confidence: 0.4 do
          input "I want to go to Stockholm"

          model do
            group name: 'airline' do
              string name: 'to_city'
            end
          end

          instance do
            self['myApp'].airline do
              to_city "Stockholm"
            end
          end
        end
      end

      document.to_xml.should == expected_document
    end
  end

  describe "parsing a document" do
    subject do
      RubySpeech.parse example_document
    end

    let(:empty_result) { '<result xmlns="http://www.w3c.org/2000/11/nlsml" xmlns:xf="http://www.w3.org/2000/xforms"/>' }

    its(:grammar) { should == 'http://flight' }

    it { should be_match }

    let(:expected_best_interpretation) do
      {
        confidence: 0.6,
        input: { mode: :speech, content: 'I want to go to Pittsburgh' },
        instance: { airline: { to_city: 'Pittsburgh' } }
      }
    end

    let(:expected_interpretations) do
      [
        expected_best_interpretation,
        {
          confidence: 0.4,
          input: { content: 'I want to go to Stockholm' },
          instance: { airline: { to_city: 'Stockholm' } }
        }
      ]
    end

    its(:interpretations)     { should == expected_interpretations }
    its(:best_interpretation) { should == expected_best_interpretation }

    it "should be equal if the XML is the same" do
      subject.should be == RubySpeech.parse(example_document)
    end

    it "should not be equal if the XML is different" do
      subject.should_not be == RubySpeech.parse(empty_result)
    end

    context "with an interpretation that has no model/instance" do
      let :example_document do
        '''
<result xmlns="http://www.w3c.org/2000/11/nlsml" grammar="http://flight">
  <interpretation confidence="60">
    <input mode="speech">I want to go to Pittsburgh</input>
  </interpretation>
  <interpretation confidence="40">
    <input>I want to go to Stockholm</input>
  </interpretation>
</result>
        '''
      end

      let(:expected_best_interpretation) do
        {
          confidence: 0.6,
          input: { mode: :speech, content: 'I want to go to Pittsburgh' },
          instance: nil
        }
      end

      let(:expected_interpretations) do
        [
          expected_best_interpretation,
          {
            confidence: 0.4,
            input: { content: 'I want to go to Stockholm' },
            instance: nil
          }
        ]
      end

      its(:interpretations)     { should == expected_interpretations }
      its(:best_interpretation) { should == expected_best_interpretation }
    end

    context "without any interpretations" do
      subject do
        RubySpeech.parse empty_result
      end

      it { should_not be_match }
    end

    context "with interpretations out of confidence order" do
      let :example_document do
        '''
<result xmlns="http://www.w3c.org/2000/11/nlsml" xmlns:myApp="foo" xmlns:xf="http://www.w3.org/2000/xforms" grammar="http://flight">
  <interpretation confidence="40">
    <input>I want to go to Stockholm</input>
    <xf:model>
      <xf:group name="airline">
        <xf:string name="to_city"/>
      </xf:group>
    </xf:model>
    <xf:instance>
      <myApp:airline>
        <myApp:to_city>Stockholm</myApp:to_city>
      </myApp:airline>
    </xf:instance>
  </interpretation>
  <interpretation confidence="60">
    <input mode="speech">I want to go to Pittsburgh</input>
    <xf:model>
      <xf:group name="airline">
        <xf:string name="to_city"/>
      </xf:group>
    </xf:model>
    <xf:instance>
      <myApp:airline>
        <myApp:to_city>Pittsburgh</myApp:to_city>
      </myApp:airline>
    </xf:instance>
  </interpretation>
</result>
        '''
      end

      its(:interpretations)     { should == expected_interpretations }
      its(:best_interpretation) { should == expected_best_interpretation }
    end
  end
end
