require 'spec_helper'

describe RubySpeech::NLSML do
  describe 'drawing a document' do
    let :expected_document do
      string = '''
<result xmlns:myApp="foo" xmlns:xf="http://www.w3.org/2000/xforms" grammar="http://flight">
  <interpretation confidence="60">
    <input mode="speech">I want to go to Pittsburgh</input>
    <xf:model>
      <xf:group name="airline">
        <xf:string name="to_city"/>
      </xf:group>
    </xf:model>
    <xf:instance>
      <myApp:airline>
        <myApp:to_city>Pittsburgh</to_city>
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
        <myApp:to_city>Stockholm</to_city>
      </myApp:airline>
    </xf:instance>
  </interpretation>
</result>
'''
      Nokogiri::XML(string).to_xml
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

      puts document.to_xml

      document.to_xml.should == expected_document
    end
  end
end
