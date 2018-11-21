require 'byebug'

require 'active_support'
require 'active_support/core_ext'
require 'erb'
require 'active_support/inflector'

require_relative './session'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res)
    @req, @res = req, res
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    render_error
    @res.status = 302
    @res.header['location'] = url
    @already_built_response = true
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    render_error
    @already_built_response = true
    
    @res['Content-Type'] = content_type
    @res.write(content)
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    render_error
    path = File.dirname(__FILE__)
    path = File.join(path, "..", "views", self.class.name.underscore, "#{template_name}.html.erb")
    # byebug
    content = File.read(path)
    erb_content = ERB.new(content).result(binding)
    @res.write(erb_content)
    
    @res['Content-Type'] = 'text/html'
    @already_built_response = true
  end

  # method exposing a `Session` object
  def session
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end
  
  private 
  
  def render_error 
    if already_built_response?
      raise 'Error'
    end 
  end
  
end

