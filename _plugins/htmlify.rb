module Jekyll
    class Htmlify < Liquid::Block
      def initialize(tag_name, text, tokens)
        super
      end
      require "kramdown"
      def render(context)
        content = super
        "#{Jekyll::Converters::Markdown::Bootdown.new({}).convert(content)}"
      end
    end
  end
  Liquid::Template.register_tag('htmlify', Jekyll::Htmlify)