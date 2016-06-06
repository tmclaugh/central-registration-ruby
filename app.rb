require 'sinatra/base'
require 'sinatra/namespace'
require 'sinatra/json'

module CentralReg
  class App < Sinatra::Application
    register Sinatra::Namespace

    # Some structure ideas:
    # - https://nickcharlton.net/posts/structuring-sinatra-applications.html
    # - http://blog.carbonfive.com/2013/06/24/sinatra-best-practices-part-one/
    # - http://blog.sourcing.io/structuring-sinatra

    namespace '/v1' do
      require_relative 'app/routes/base'
      register CentralReg::Routes::Base

      namespace '/dns' do
        require_relative 'app/routes/dns'
        register CentralReg::Routes::DNS
      end
    end

  end
end
