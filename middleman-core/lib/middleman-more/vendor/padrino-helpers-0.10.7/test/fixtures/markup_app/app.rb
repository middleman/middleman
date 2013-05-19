require 'sinatra/base'
require 'haml'
require 'erubis'
require 'slim'

class MarkupDemo < Sinatra::Base
  register Padrino::Helpers

  configure do
    set :root, File.dirname(__FILE__)
  end

  get '/:engine/:file' do
    show(params[:engine], params[:file].to_sym)
  end

  helpers do
    # show :erb, :index
    # show :haml, :index
    def show(kind, template)
      send kind.to_sym, template.to_sym
    end

    def captured_content(&block)
      content_html = capture_html(&block)
      "<p>#{content_html}</p>"
    end

    def concat_in_p(content_html)
      concat_content "<p>#{content_html}</p>"
    end

    def determine_block_is_template(name, &block)
      concat_content "<p class='is_template'>The #{name} block passed in is a template</p>" if block_is_template?(block)
    end

    def ruby_not_template_block
      determine_block_is_template('ruby') do
        content_tag(:span, "This not a template block")
      end
    end
  end
end

class MarkupUser
  def errors; { :fake => "must be valid", :second => "must be present", :third  => "must be a number", :email => "must be a email"}; end
  def session_id; 45; end
  def gender; 'male'; end
  def remember_me; '1'; end
  def permission; Permission.new; end
  def telephone; Telephone.new; end
  def addresses; [Address.new('Greenfield', true), Address.new('Willowrun', false)]; end
end

class Telephone
  def number; "62634576545"; end
end

class Address
  attr_accessor :name
  def initialize(name, existing); @name, @existing = name, existing; end
  def new_record?; !@existing; end
  def id; @existing ? 25 : nil; end
end

class Permission
  def can_edit; true; end
  def can_delete; false; end
end

module Outer
  class UserAccount; end
end
