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

    context "with multiple instances for a single interpretation" do
      let :example_document do
        '''
<result xmlns="http://www.w3c.org/2000/11/nlsml" xmlns:myApp="foo" xmlns:xf="http://www.w3.org/2000/xforms" grammar="http://flight">
  <interpretation confidence="100">
    <input mode="speech">I want to go to Boston</input>
    <xf:model>
      <xf:group name="airline">
        <xf:string name="to_city"/>
      </xf:group>
    </xf:model>
    <xf:instance>
      <myApp:airline>
        <myApp:to_city>Boston, MA</myApp:to_city>
      </myApp:airline>
    </xf:instance>
    <xf:instance>
      <myApp:airline>
        <myApp:to_city>Boston, UK</myApp:to_city>
      </myApp:airline>
    </xf:instance>
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

    context "with no namespaces (because some vendors think this is ok)" do
      let :example_document do
        '''
<result grammar="http://flight">
  <interpretation confidence="60">
    <input mode="speech">I want to go to Pittsburgh</input>
    <model>
      <group name="airline">
        <string name="to_city"/>
      </group>
    </model>
    <instance>
      <airline>
        <to_city>Pittsburgh</to_city>
      </airline>
    </instance>
  </interpretation>
  <interpretation confidence="40">
    <input>I want to go to Stockholm</input>
    <model>
      <group name="airline">
        <string name="to_city"/>
      </group>
    </model>
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

    context "with just an NLSML namespace (because we need something, damnit!)" do
      let :example_document do
        '''
<result xmlns="http://www.w3c.org/2000/11/nlsml" grammar="http://flight">
  <interpretation confidence="60">
    <input mode="speech">I want to go to Pittsburgh</input>
    <model>
      <group name="airline">
        <string name="to_city"/>
      </group>
    </model>
    <instance>
      <airline>
        <to_city>Pittsburgh</to_city>
      </airline>
    </instance>
  </interpretation>
  <interpretation confidence="40">
    <input>I want to go to Stockholm</input>
    <model>
      <group name="airline">
        <string name="to_city"/>
      </group>
    </model>
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
<result xmlns="http://www.w3c.org/2000/11/nlsml" grammar="http://flight">
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
<result xmlns="http://www.w3c.org/2000/11/nlsml" grammar="http://flight">
  <interpretation confidence="60">
    <input mode="speech">I want to go to Pittsburgh</input>
    <model>
      <group name="airline">
        <string name="to_city"/>
      </group>
    </model>
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
<result xmlns="http://www.w3c.org/2000/11/nlsml" grammar="http://flight">
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
