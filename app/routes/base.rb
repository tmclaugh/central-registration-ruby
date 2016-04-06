require 'sinatra/base'
require 'sinatra/json'

module CentralReg
  module Routes
    module Base
      def self.registered(app)
        app.get '/ping' do
          json :status => 'pong'
        end
      end
    end
  end
end
