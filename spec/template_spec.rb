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

    context "with custom HTML escape function" do
      before { @original_escape = RubyHamlJs::Template.custom_escape }
      before { RubyHamlJs::Template.custom_escape = "App.custom_escape" }
      after  { RubyHamlJs::Template.custom_escape = @original_escape }
      it { should include "App.custom_escape(" }
    end
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

  describe 'rawjs.if.simple' do
    let(:choice) { true }
    subject do
      func = render <<eot, 'myTemplate.js.hamljs'
- if (choice)
  %p it is so
eot
      ExecJS.compile("var f = #{func};").eval "f({choice: #{choice}})"
    end

    it { should include '<p>it is so</p>' }

    context "changing opinion" do
      let(:choice) { false }
      it { should_not include '<p>it is so</p>' }
    end
  end

  describe 'rawjs.if.begin' do
    let(:choice) { true }
    subject do
      func = render <<eot, 'myTemplate.js.hamljs'
- if (choice) {
  %p it is so
eot
      ExecJS.compile("var f = #{func};").eval "f({choice: #{choice}})"
    end

    it { should include '<p>it is so</p>' }

    context "changing opinion" do
      let(:choice) { false }
      it { should_not include '<p>it is so</p>' }
    end
  end

  describe 'rawjs.for.simple' do
    let(:list) { [1,2,3] }
    subject do
      func = render <<eot, 'myTemplate.js.hamljs'
- for (i=0; i < list.length; i++)
  %p= list[i]
eot
      ExecJS.compile("var f = #{func};").eval "f({list: #{list}})"
    end

    it { should include '<p>1</p>' }
    it { should include '<p>2</p>' }
    it { should include '<p>3</p>' }

  end

  describe 'rawjs.for.begin' do
    let(:list) { [1,2,3] }
    subject do
      func = render <<eot, 'myTemplate.js.hamljs'
- for (i=0; i < list.length; i++) {
  %p= list[i]
eot
      ExecJS.compile("var f = #{func};").eval "f({list: #{list}})"
    end

    it { should include '<p>1</p>' }
    it { should include '<p>2</p>' }
    it { should include '<p>3</p>' }

  end

  describe 'rawjs.for.in' do
    let(:list) { [1,2,3] }
    subject do
      func = render <<eot, 'myTemplate.js.hamljs'
- for (i in list)
  %p= list[i]
eot
      ExecJS.compile("var f = #{func};").eval "f({list: #{list}})"
    end

    it { should include '<p>1</p>' }
    it { should include '<p>2</p>' }
    it { should include '<p>3</p>' }

  end

  describe 'rawjs.assign' do
    let(:list) { [1,2,3] }
    subject do
      func = render <<eot, 'myTemplate.js.hamljs'
- for (i=0; i < list.length; i++) {
  - pval = list[i];
  %p= pval
eot
      ExecJS.compile("var f = #{func};").eval "f({list: #{list}})"
    end

    it { should include '<p>1</p>' }
    it { should include '<p>2</p>' }
    it { should include '<p>3</p>' }

  end

  describe 'rawjs.for.complex' do
    let(:list) { [1,2,3] }
    subject do
      func = render <<eot, 'myTemplate.js.hamljs'
- for (i = 0; i < list.length; i++)
  %i= i
  - if (list[i] == 1)
    %p one
  - if (list[i] == 2)
    %p two
  - if (list[i] == 3)
    %p three
  %p= list[i]
eot
      ExecJS.compile("var f = #{func};").eval "f({list: #{list}})"
    end

    it { should include '<i>0</i>' }
    it { should include '<i>1</i>' }
    it { should include '<i>2</i>' }
    it { should include '<p>1</p>' }
    it { should include '<p>2</p>' }
    it { should include '<p>3</p>' }
    it { should include '<p>one</p>' }
    it { should include '<p>two</p>' }
    it { should include '<p>three</p>' }

  end

  describe 'rawjs.while' do
    let(:list) { [1,2,3] }
    subject do
      func = render <<eot, 'myTemplate.js.hamljs'
- i = 0;
- while (i < list.length) {
  %p= list[i]
  - i++;
eot
      ExecJS.compile("var f = #{func};").eval "f({list: #{list}})"
    end

    it { should include '<p>1</p>' }
    it { should include '<p>2</p>' }
    it { should include '<p>3</p>' }

  end

  describe 'rawjs.async' do
    let(:list) { [1,2,3] }
    subject do
      func = render <<eot, 'myTemplate.js.hamljs'
- list.forEach(function (i) {
  %p= i
eot
      ExecJS.compile("var f = #{func};").eval "f({list: #{list}})"
    end

    it { should include '<p>1</p>' }
    it { should include '<p>2</p>' }
    it { should include '<p>3</p>' }

  end

  describe 'serving' do
    subject { assets }
    it { should serve 'sample.js' }
  end
end
