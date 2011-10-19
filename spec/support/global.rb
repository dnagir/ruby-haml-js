require 'ruby-haml-js'

def assets
  Rails.application.assets
end

def asset_for(name)
  assets[name]
end
