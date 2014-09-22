require "pry"
class AdaptersController < ApplicationController
  def connect
    binding.pry
    render text: request.env['omniauth.auth'].inspect
  end
end
