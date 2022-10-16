class GreetingsController < ApplicationController
  def hello
    render json: { content: 'Hello from Rails by Docker.' }
  end
end
