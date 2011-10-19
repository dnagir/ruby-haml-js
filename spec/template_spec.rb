require 'spec_helper'

describe RubyHamlJs::Template do
  def template haml, file
    RubyHamlJs::Template.new(file) { haml }
  end

  def render haml, file = "file.jst.js.hamljs"
    template(haml, file).render
  end

  it 'should have default mime type' do
    RubyHamlJs::Template.default_mime_type.should == 'application/javascript'
  end

  describe 'rendering' do
    subject { render "#main= 'quotes'\n  #inner= name", 'myTemplate.js.hamljs' }

    it { should include "function (locals) {" }
    it { should include 'function html_escape' }
  end

  describe 'executing' do
    let(:name) { 'Dima' }
    subject do
      func = render "#main= 'quotes'\n  #inner= name", 'myTemplate.js.hamljs'
      ExecJS.compile("var f = #{func};").eval "f({name: '#{name}'})"
    end

    it { should include 'Dima' }

    context "injecting <script> tag as parameter" do
      let(:name)      { '<script>' }
      it { should     include '&lt;script&gt;' }
      it { should_not include '<script>'       }
    end
  end

  describe 'serving' do
    subject { assets }
    it { should serve 'sample.js' }
  end
end
