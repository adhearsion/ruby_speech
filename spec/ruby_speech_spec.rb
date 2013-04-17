require 'spec_helper'

describe RubySpeech do
  describe ".parse" do
    subject do
      RubySpeech.parse example_document
    end

    context "with an SSML document" do
      let :example_document do
        '''<?xml version="1.0"?>
<!DOCTYPE speak PUBLIC "-//W3C//DTD SYNTHESIS 1.0//EN"
                  "http://www.w3.org/TR/speech-synthesis/synthesis.dtd">
<speak version="1.0"
       xmlns="http://www.w3.org/2001/10/synthesis"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.w3.org/2001/10/synthesis
                   http://www.w3.org/TR/speech-synthesis/synthesis.xsd"
       xml:lang="en-US">
  <p>
    <s>You have 4 new messages.</s>
    <s>The first is from Stephanie Williams and arrived at <break/> 3:45pm.
    </s>
    <s>
      The subject is <prosody rate="-20%">ski trip</prosody>
    </s>

  </p>
</speak>
        '''
      end

      it { should be_a RubySpeech::SSML::Element }
    end

    context "with a GRXML document" do
      let :example_document do
        '''<?xml version="1.0" encoding="UTF-8"?>

<!DOCTYPE grammar PUBLIC "-//W3C//DTD GRAMMAR 1.0//EN"
                  "http://www.w3.org/TR/speech-grammar/grammar.dtd">

<grammar xmlns="http://www.w3.org/2001/06/grammar" xml:lang="en"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://www.w3.org/2001/06/grammar
                             http://www.w3.org/TR/speech-grammar/grammar.xsd"
         version="1.0" mode="voice" root="basicCmd">

<meta name="author" content="Stephanie Williams"/>

<rule id="basicCmd" scope="public">
  <example> please move the window </example>
  <example> open a file </example>

  <ruleref uri="http://grammar.example.com/politeness.grxml#startPolite"/>

  <ruleref uri="#command"/>
  <ruleref uri="http://grammar.example.com/politeness.grxml#endPolite"/>

</rule>

<rule id="command">
  <ruleref uri="#action"/> <ruleref uri="#object"/>
</rule>

<rule id="action">
   <one-of>
      <item weight="10"> open   <tag>TAG-CONTENT-1</tag> </item>
      <item weight="2">  close  <tag>TAG-CONTENT-2</tag> </item>
      <item weight="1">  delete <tag>TAG-CONTENT-3</tag> </item>
      <item weight="1">  move   <tag>TAG-CONTENT-4</tag> </item>
    </one-of>
</rule>

<rule id="object">
  <item repeat="0-1">
    <one-of>
      <item> the </item>
      <item> a </item>
    </one-of>
  </item>

  <one-of>
      <item> window </item>
      <item> file </item>
      <item> menu </item>
  </one-of>
</rule>

</grammar>
        '''
      end

      it { should be_a RubySpeech::GRXML::Element }
    end

    context "with an NLSML document" do
      let :example_document do
        '''
<result xmlns="http://www.ietf.org/xml/ns/mrcpv2" grammar="http://flight">
  <interpretation confidence="60">
    <input mode="speech">I want to go to Pittsburgh</input>
    <instance>
      <airline>
        <to_city>Pittsburgh</to_city>
      </airline>
    </instance>
  </interpretation>
  <interpretation confidence="40">
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

      it { should be_a RubySpeech::NLSML::Document }
    end
  end
end
