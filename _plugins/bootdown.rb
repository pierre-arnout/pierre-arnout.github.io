# frozen-string-literal: true
module Jekyll
    module Converters
      class Markdown
        class Bootdown
  
            def initialize(config)

            end

            def convert(content)
              content = Kramdown::Document.new(self.parse_grid(content)).to_html
              content = self.convert_grid(content)
              return content
            end

            def convert_grid(content)
              content.gsub!(/^<!-- open ([0-9]*) -->$/, "<div class=\"row\"><div class=\"col-md-\\1\">")
              content.gsub!(/^<!-- copen ([0-9]*) -->$/, "</div><div class=\"col-md-\\1\">")
              content.gsub!(/^<!-- close -->$/, "</div></div>")
              return content
            end

            RE_GRID_FULL = /^(\{[0-9]*\}>>.*?\n<<)$/m
            RE_GRID_START = /^\{([0-9]*)\}>>$/
            RE_GRID_ALL = /^\{([0-9]*)\}>>?$/
            RE_GRID_DELIM = /^\{([0-9]*)\}>$/
            RE_GRID_STOP = /^<<$/
            GRID_MAX = 12
            def parse_grid(content)
              updates = []
              positions = content.enum_for(:scan, RE_GRID_FULL).map {
                full_source = Regexp.last_match
                pos_start = Regexp.last_match.begin(0)
                pos_end = pos_start + Regexp.last_match[0].length
                block = content[pos_start..pos_end]

                empty_delims = 0
                slots_left = GRID_MAX

                block.scan(RE_GRID_ALL).each do |match|
                  if match[0].strip() != ''
                    slots_left -= Integer(match[0])
                  else
                    empty_delims += 1
                  end
                end

                first = true
                out = []
                block.enum_for(:scan, RE_GRID_ALL).map { |v, i|
                  last_char = Regexp.last_match[0].slice(Regexp.last_match[0].length - 2)
                  match = Regexp.last_match
                  pos = Regexp.last_match.begin(0)

                  if match[1].strip() != ''
                    replc = match[1]
                  else
                    # TODO: Handle not integer case
                    replc = slots_left / empty_delims
                  end

                  if last_char == '>'
                    html = "\n<!-- open #{replc} -->\n"
                  else
                    html = "\n<!-- copen #{replc} -->\n"
                  end

                  out << html
                }
                out.each do |item|
                  block.sub!(RE_GRID_ALL, item)
                end
                block.sub!(RE_GRID_STOP, "\n<!-- close -->\n")
                updates << {"start" => pos_start, "end" => pos_end, "update" => block}
              }
              updates.reverse_each do |item|
                content[item["start"]..item["end"]] = item["update"]
              end
              return content
            end
        end
      end
    end
  end
  
  