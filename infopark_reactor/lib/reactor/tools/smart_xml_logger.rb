require "nokogiri"

class SmartXmlLogger
  def initialize(forward_to, method = nil)
    @logger = forward_to
    @method = method
  end

  def configure(key, options)
    @configuration ||= {}
    @configuration[key] = options
  end

  def log(text)
    return unless @logger

    @logger.send(@method, text)
  end

  def log_xml(key, xml)
    return unless @logger

    options = @configuration[key]

    dom = Nokogiri::XML::Document.parse(xml)

    node_set = options[:xpath] ? dom.xpath(options[:xpath]) : dom

    log(if node_set.respond_to?(:each)
          node_set.map { |node| print_node(node, options[:start_indent] || 0) }.join
        else
          print_node(node_set, options[:start_indent] || 0)
    end)
  end

  # private

  def print_node(node, indent = 0)
    return "" if node.text?

    empty = node.children.empty?
    has_text = node.children.detect { |child| child.text? }

    out = " " * indent

    attrs = node.attributes.values.map { |attr| %(#{attr.name}="#{attr.value}") }.join(" ")
    attrs = " #{attrs}" if attrs.present?

    out << "<#{node.name}#{attrs}#{"/" if empty}>"

    out << if has_text
             node.text.to_s
           else
             "\n"
           end

    node.children.each do |child|
      out << print_node(child, indent + 2)
    end

    out << " " * indent unless has_text || empty
    out << "</#{node.name}>\n" unless empty
    out
  end
end
