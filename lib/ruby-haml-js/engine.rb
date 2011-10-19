module RubyHamlJs
  class Engine < Rails::Engine
    initializer "ruby-hamljs.configure_rails_initialization", :before => 'sprockets.environment', :group => :all do |app|
      next unless app.config.assets.enabled

      require 'sprockets'
      require 'sprockets/engines'
      require 'ruby-haml-js/template'
      #app.config.assets.register_engine '.hamljs', ::RubyHamlJs::Template
      Sprockets.register_engine '.hamljs', ::RubyHamlJs::Template
    end
  end
end
