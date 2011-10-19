# Ruby HAML-JS

Precompiles the HAML-JS templates into a function.

This can be used as a standalone template or as part of Rails 3.1 assets pipeline.

# Installation - Rails 3.1

```ruby
# Gemfile
gem 'ruby-haml-js'
```

```bash
# Then install it
bundle
```

# Usage - with Rails 3.1 assets pipeline

1. Put your template unders `app/assets/javascripts` (or other path where Rails can find it).
2. Use the naming `my-template.jst.hamljs`.
3. Serve the template to browser by `require my-template` from `application.js` or link to it as `my-template.js`
4. Use the template from the JavaScript: `JST['my-template']({your: 'local', variables: 'go here'})`


# Development

- Source hosted at [GitHub](https://github.com/dnagir/ruby-haml-js)
- Report issues and feature requests to [GitHub Issues](https://github.com/dnagir/ruby-haml-js/issues)

Pull requests are very welcome! But please write the specs.

To start, clone the repo and then:

```shell
bundle install
bundle exec rspec spec/
```
