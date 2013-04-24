require "cgi"

class FencedCodeBlock < Nanoc3::Filter
  identifier :fenced_code_block

  def run(content, params = {})
    content.gsub(/(^\`{3}\s*(\S+)\s*$([^`]*)^`{3}\s*$)+?/m) do |match|
      lang_spec  = $2
      code_block = $3

      if lang_spec == "groovy"
        lang_spec = "java"
      end

      rest = '">'
      code_block.gsub!("[:backtick:]", "`")
      rest << CGI::escapeHTML(code_block)

      replacement = "<pre"

      if lang_spec && lang_spec.length > 0
        if lang_spec == "bash"
          replacement << ' class="terminal'
          replacement << rest
          replacement << "</pre>\n"
        else
          replacement << '><code class="language-'
          replacement << lang_spec
          replacement << rest
          replacement << "</code></pre>\n"
        end
      end
    end
  end
end