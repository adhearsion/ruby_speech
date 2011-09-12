require 'spec_helper'

module RubySpeech
  describe GRXML do
    describe "#draw" do
      it "should create an GRXML document" do
        expected_doc = GRXML::Grammar.new
        GRXML.draw.should == expected_doc
      end

      # Blocks are acting strange... maybe related to the other 1.9.2 &block ssml bug?
      # Doing a quick document create just to see append work...
      it "should allow other GRXML elements to be inserted in the document" do
        doc = GRXML::Grammar.new(:mode => :dtmf, :root => 'digits')
        rule = GRXML::Rule.new(:id => "digits")
        oneof = GRXML::OneOf.new
        1.upto(3) {|d| oneof << GRXML::Item.new(:content => d.to_s) }
        rule << oneof
        doc << rule

        puts "=== Example Document ==="
        puts doc.to_s
      end



      # it "should allow nested block return values" do
      #   doc = RubySpeech::GRXML.draw do
      #     #item { "1" }
      #     grammar :mode => 'dtmf' do
      #       rule :id => 'digit' do
      #         item { "1" } 
      #       end
      #     end
      #   end
      #   expected_doc = GRXML::Grammar.new(:mode => 'dtmf')
      #   expected_doc << GRXML::Rule.new(:id => 'digit')
      #   expected_doc << GRXML::Item.new(:content => "1")
      #   puts expected_doc.to_s
      #   doc.should == expected_doc
      # end

    end # draw
  end # GRXML
end # RubySpeech

__END__
doc = RubySpeech::GRXML.draw do
  rule :id => :digit do
    one_of do
      10.times do |i|
        item i
      end
    end
  end
end
<rule id="digit">
 <one-of>
   <item> 0 </item>
   <item> 1 </item>
   <item> 2 </item>
   <item> 3 </item>
   <item> 4 </item>
   <item> 5 </item>
   <item> 6 </item>
   <item> 7 </item>
   <item> 8 </item>
   <item> 9 </item>
 </one-of>
</rule>
