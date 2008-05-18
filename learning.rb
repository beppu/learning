#!/usr/bin/ruby

require 'rubygems'
require 'camping'
require 'camping/session'
require 'ostruct'

Camping.goes :Learning

require 'learning/config'
require 'learning/helpers'
require 'learning/migrations'

class L
  def self.method_missing(method, *args)
    "Learning::Models::#{method.to_s}".constantize
  end
end

module Learning::RequestWrapper
  def service(*a)
    @css = [ '/static/css/main.css' ]
    @js  = [ '/static/js/jquery.js', '/static/js/main.js' ]
    @js_session = { :id => cookies.camping_sid }
    @u = User.find(@state.user_id) if @state.is_logged_in
    @subdomain = @env['HTTP_HOST'].split('.')[0] # not 100% correct
    @title = "Everything I know about X, I learned from Y."
    @google_ad_client  = Learning::GOOGLE_AD_CLIENT
    @google_ad_slot    = Learning::GOOGLE_AD_SLOT
    @google_analytics  = Learning::GOOGLE_ANALYTICS
    response = super(*a)
  end
end

module Learning::CookieWrapper
  def service(*a)
    @cgi_cookies    = Camping::H.new
    @default_cookie = Camping::H.new.merge({ :path => '/' })
    response = super(*a)
    @cgi_cookies.each do |name, settings|
      c = @default_cookie.merge(settings);
      c.name = name
      cookie = CGI::Cookie.new(c);
      headers['Set-Cookie'].push(cookie.to_s)
    end
    response
  end
end

module Learning
  include Camping::Session, Learning::RequestWrapper, Learning::CookieWrapper

  def self.create
    Camping::Models::Session.create_schema
    Learning::Models.create_schema
  end

  class UserNotFound < RuntimeError
  end
  class WorkspaceNotFound < RuntimeError
  end
end

require 'learning/models'
require 'learning/views'
require 'learning/controllers'
