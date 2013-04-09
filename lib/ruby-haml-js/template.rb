require 'tilt/template'

module RubyHamlJs
  class Template < Tilt::Template
    self.default_mime_type = 'application/javascript'

    def self.engine_initialized?
      defined? ::ExecJS
    end

    def initialize_engine
      require_template_library 'execjs'
    end
    
    def prepare
    end

    # Compiles the template using HAML-JS
    #
    # Returns a JS function definition String. The result should be
    # assigned to a JS variable.
    #
    #     # => "function(data) { ... }"
    def evaluate(scope, locals, &block)
      compile_to_function
    end



    private

    def compile_to_function
      function = ExecJS.
        compile(self.class.haml_source).
        eval "Haml('#{js_string data}', {escapeHtmlByDefault: true, customEscape: #{js_custom_escape}}).toString()"
      # make sure function is annonymous
      function.sub /function \w+/, "function "
    end

    def js_string str
      (str || '').
        gsub("'")  {|m| "\\'" }.
        gsub("\n") {|m| "\\n" }
    end

    def js_custom_escape
      escape_function = self.class.custom_escape
      escape_function ? "'#{js_string escape_function}'" : 'null'
    end

    class << self
      attr_accessor :custom_escape
      attr_accessor :haml_path

      def haml_source
        # Haml source is an asset
        @haml_path = File.expand_path('../../../vendor/assets/javascripts/haml.js', __FILE__) if @haml_path.nil?
        @haml_source ||= IO.read @haml_path
      end

    end

  end
end

