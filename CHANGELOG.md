# 0.2.1
  Bugfix: SSML element's children now include any text content, and text content is copied when importing/concatenating documents

# 0.2.0
  Feature: SSML elements can now be imported from a Nokogiri Node or a string
  Feature: SSML elements now respond to #children with an array of SSML elements, rather than a Nokogiri NodeSet
  Bugfix/Feature: Comparing SSML elements now compares children

# 0.1.5
  Feature: Now added support for SSML <audio/>

# 0.1.4
  Bugfix: Speak#+ now returns a brand new Speak rather than modifying the original object
  Bugfix: Speak#+ now re-sets the namespace on child elements to ensure no default namespace prefix is added

# 0.1.3
  Bugfix: Strings included via the DSL (both as a block return value and by calling #string) are now properly escaped

# 0.1.2
  API Change: SSML.draw now returns a Speak
  Feature: Speak objects can be turned into an XML document using #to_doc
  Feature: Speak objects can now be concatenated such that children are merged together

# 0.1.1
  * Bugfix: DSL now allows for nesting all allowed elements within each other

# 0.1.0
  * Initial Release
