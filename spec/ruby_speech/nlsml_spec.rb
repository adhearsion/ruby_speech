require 'spec_helper'

describe RubySpeech::NLSML do
  let :example_document do
    '''
<result xmlns="http://www.ietf.org/xml/ns/mrcpv2" grammar="http://flight">
  <interpretation confidence="0.6">
    <input mode="speech">I want to go to Pittsburgh</input>
    <instance>
      <airline>
        <to_city>Pittsburgh</to_city>
      </airline>
    </instance>
  </interpretation>
  <interpretation confidence="0.4">
    <input>I want to go to Stockholm</input>
    <instance>
      <airline>
        <to_city>Stockholm</to_city>
      </airline>
    </instance>
  </interpretation>
</result>
    '''
  end

  describe 'drawing a document' do
    let :expected_document do
      Nokogiri::XML(example_document, nil, nil, Nokogiri::XML::ParseOptions::NOBLANKS).to_xml
    end

    it "should allow building a document" do
      document = RubySpeech::NLSML.draw(grammar: 'http://flight') do
        interpretation confidence: 0.6 do
          input "I want to go to Pittsburgh", mode: :speech

          instance do
            airline do
              to_city 'Pittsburgh'
            end
          end
        end

        interpretation confidence: 0.4 do
          input "I want to go to Stockholm"

          instance do
            airline do
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

    let(:empty_result) { '<result xmlns="http://www.ietf.org/xml/ns/mrcpv2"/>' }

    its(:grammar) { should == 'http://flight' }

    it { should be_match }

    let(:expected_best_interpretation) do
      {
        confidence: 0.6,
        input: { mode: :speech, content: 'I want to go to Pittsburgh' },
        instance: { airline: { to_city: 'Pittsburgh' } },
        instances: [{ airline: { to_city: 'Pittsburgh' } }]
      }
    end

    let(:expected_interpretations) do
      [
        expected_best_interpretation,
        {
          confidence: 0.4,
          input: { content: 'I want to go to Stockholm' },
          instance: { airline: { to_city: 'Stockholm' } },
          instances: [{ airline: { to_city: 'Stockholm' } }]
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

    context "with an interpretation that has no instance" do
      let :example_document do
        '''
<result xmlns="http://www.ietf.org/xml/ns/mrcpv2" grammar="http://flight">
  <interpretation confidence="0.6">
    <input mode="speech">I want to go to Pittsburgh</input>
  </interpretation>
  <interpretation confidence="0.4">
    <input>I want to go to Stockholm</input>
  </interpretation>
</result>
        '''
      end

      let(:expected_best_interpretation) do
        {
          confidence: 0.6,
          input: { mode: :speech, content: 'I want to go to Pittsburgh' },
          instance: nil,
          instances: []
        }
      end

      let(:expected_interpretations) do
        [
          expected_best_interpretation,
          {
            confidence: 0.4,
            input: { content: 'I want to go to Stockholm' },
            instance: nil,
            instances: []
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
<result xmlns="http://www.ietf.org/xml/ns/mrcpv2" grammar="http://flight">
  <interpretation confidence="0.4">
    <input>I want to go to Stockholm</input>
    <instance>
      <airline>
        <to_city>Stockholm</to_city>
      </airline>
    </instance>
  </interpretation>
  <interpretation confidence="0.6">
    <input mode="speech">I want to go to Pittsburgh</input>
    <instance>
      <airline>
        <to_city>Pittsburgh</to_city>
      </airline>
    </instance>
  </interpretation>
</result>
        '''
      end

      its(:interpretations)     { should == expected_interpretations }
      its(:best_interpretation) { should == expected_best_interpretation }
    end

    context "with multiple instances for a single interpretation" do
      let :example_document do
        '''
<result xmlns="http://www.ietf.org/xml/ns/mrcpv2" grammar="http://flight">
  <interpretation confidence="1">
    <input mode="speech">I want to go to Boston</input>
    <instance>
      <airline>
        <to_city>Boston, MA</to_city>
      </airline>
    </instance>
    <instance>
      <airline>
        <to_city>Boston, UK</to_city>
      </airline>
    </instance>
  </interpretation>
</result>
        '''
      end

      let(:expected_interpretation) do
        {
          confidence: 1.0,
          input: { content: 'I want to go to Boston', mode: :speech },
          instance: { airline: { to_city: 'Boston, MA' } },
          instances: [
            { airline: { to_city: 'Boston, MA' } },
            { airline: { to_city: 'Boston, UK' } }
          ]
        }
      end

      its(:interpretations)     { should == [expected_interpretation] }
      its(:best_interpretation) { should == expected_interpretation }
    end

    context "with no namespace" do
      let :example_document do
        '''
<result grammar="http://flight">
  <interpretation confidence="0.6">
    <input mode="speech">I want to go to Pittsburgh</input>
    <instance>
      <airline>
        <to_city>Pittsburgh</to_city>
      </airline>
    </instance>
  </interpretation>
  <interpretation confidence="0.4">
    <input>I want to go to Stockholm</input>
    <instance>
      <airline>
        <to_city>Stockholm</to_city>
      </airline>
    </instance>
  </interpretation>
</result>
        '''
      end

      its(:interpretations)     { should == expected_interpretations }
      its(:best_interpretation) { should == expected_best_interpretation }
    end

    context "with a single interpretation with a nomatch input" do
      let :example_document do
        '''
<result xmlns="http://www.ietf.org/xml/ns/mrcpv2" grammar="http://flight">
  <interpretation>
    <input>
       <nomatch/>
    </input>
  </interpretation>
</result>
        '''
      end

      it { should_not be_match }
    end

    context "with multiple interpretations where one is a nomatch input" do
      let :example_document do
        '''
<result xmlns="http://www.ietf.org/xml/ns/mrcpv2" grammar="http://flight">
  <interpretation confidence="0.6">
    <input mode="speech">I want to go to Pittsburgh</input>
    <instance>
      <airline>
        <to_city>Pittsburgh</to_city>
      </airline>
    </instance>
  </interpretation>
  <interpretation>
    <input>
       <nomatch/>
    </input>
  </interpretation>
</result>
        '''
      end

      it { should be_match }
    end

    context "with a single interpretation with a noinput" do
      let :example_document do
        '''
<result xmlns="http://www.ietf.org/xml/ns/mrcpv2" grammar="http://flight">
  <interpretation>
    <input>
       <noinput/>
    </input>
  </interpretation>
</result>
        '''
      end

      it { should_not be_match }
      it { should be_noinput }
    end
  end
end
