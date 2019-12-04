require 'libxml'

module X12
  # A class for parsing X12 message definition expressed in XML format.
  class XMLDefinitions < Hash

    # Parse definitions out of XML file.
    #
    # @param str [String]
    # @return [void]
    def initialize(str)
      doc = LibXML::XML::Document.string(str)
      definitions = doc.root.name =~ /^Definition$/i ? doc.root.find('*').to_a : [doc.root]

      definitions.each do |element|
        X12.logger.debug(element.name)
        syntax_element = case element.name
                         when /table/i
                           parse_table(element)
                         when /segment/i
                           parse_segment(element)
                         when /composite/i
                           parse_composite(element)
                         when /loop/i
                           parse_loop(element)
                         end
        self[syntax_element.class] ||= {}
        self[syntax_element.class][syntax_element.name] = syntax_element
      end
    end

    private

    # @param str [String]
    # @return [Boolean,nil]
    def parse_boolean(str)
      return case str
             when nil
               false
             when ''
               false
             when /(^y(es)?$)|(^t(rue)?$)|(^1$)/i
               true
             when /(^no?$)|(^f(alse)?$)|(^0$)/i
               false
             else
               nil
             end
    end

    # @param str [String]
    # @return [String,nil]
    def parse_type(str)
      return case str
             when nil
               'string'
             when /^C.+$/
               str
             when /^i(nt(eger)?)?$/i
               'int'
             when /^l(ong)?$/i
               'long'
             when /^d(ouble)?$/i
               'double'
             when /^s(tr(ing)?)?$/i
               'string'
             else
               nil
             end
    end

    # @param str [String]
    # @return [Integer,nil]
    def parse_int(str)
      return case str
             when nil then 0
             when /^\d+$/ then str.to_i
             when /^inf(inite)?$/ then 999_999
             else
               nil
             end
    end

    # @param e [LibXML::XML::Node]
    # @return [Multiple Values]
    def parse_attributes(e)
      throw X12::Error.new("No name attribute found for : #{e.inspect}")          unless (name = e.attributes['name'])
      throw X12::Error.new("Cannot parse attribute 'min' for: #{e.inspect}")      unless (min  = parse_int(e.attributes['min']))
      throw X12::Error.new("Cannot parse attribute 'max' for: #{e.inspect}")      unless (max  = parse_int(e.attributes['max']))
      throw X12::Error.new("Cannot parse attribute 'type' for: #{e.inspect}")     unless (type = parse_type(e.attributes['type']))
      throw X12::Error.new("Cannot parse attribute 'required' for: #{e.inspect}") if (required = parse_boolean(e.attributes['required'])).nil?

      validation = e.attributes['validation']
      min = 1 if required && min < 1
      max = 999_999 if max.zero?

      return name, min, max, type, required, validation
    end

    # @param e [LibXML::XML::Node]
    # @return [X12::Field]
    def parse_field(e)
      name, min, max, type, required, validation = parse_attributes(e)

      # FIXME: for compatibility with d12 - constants are stored in attribute 'type' and are enclosed in
      # double quotes
      const_field = e.attributes['const']
      if const_field
        type = "\"#{const_field}\""
      end

      Field.new(name, type, required, min, max, validation)
    end

    # @param e [LibXML::XML::Node]
    # @return [X12::Table]
    def parse_table(e)
      name, _min, _max, _type, _required, _validation = parse_attributes(e)

      content = e.find('Entry').inject({}) do |t, entry|
        t[entry.attributes['name']] = entry.attributes['value']
        t
      end
      Table.new(name, content)
    end

    # @param e [LibXML::XML::Node]
    # @return [X12::Segment]
    def parse_segment(e)
      name, min, max, _type, _required, _validation = parse_attributes(e)

      fields = e.find('Field').inject([]) do |f, field|
        f << parse_field(field)
      end
      Segment.new(name, fields, Range.new(min, max))
    end

    # @param e [LibXML::XML::Node]
    # @return [X12::Composite]
    def parse_composite(e)
      name, _min, _max, _type, _required, _validation = parse_attributes(e)

      fields = e.find('Field').inject([]) do |f, field|
        f << parse_field(field)
      end
      Composite.new(name, fields)
    end

    # @param e [LibXML::XML::Node]
    # @return [X12::Loop]
    def parse_loop(e)
      name, min, max, _type, _required, _validation = parse_attributes(e)

      components = e.find('*').to_a.inject([]) do |r, element|
        r << case element.name
             when /loop/i
               parse_loop(element)
             when /segment/i
               parse_segment(element)
             else
               throw X12::Error.new("Cannot recognize syntax for: #{element.inspect} in loop #{e.inspect}")
             end
      end
      Loop.new(name, components, Range.new(min, max))
    end

  end

end
