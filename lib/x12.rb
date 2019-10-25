require 'libxml'
require 'pp'

require 'x12/base'
require 'x12/composite'
require 'x12/empty'
require 'x12/field'
require 'x12/loop'
require 'x12/parser'
require 'x12/segment'
require 'x12/table'
require 'x12/version'
require 'x12/xmldefinitions'

# X12 implements direct manipulation of X12 structures using Ruby syntax.
module X12
  include LibXML
  EMPTY = Empty.new()
  TEST_REPEAT = 1
end
