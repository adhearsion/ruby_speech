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
