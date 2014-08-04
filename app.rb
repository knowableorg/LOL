require 'sinatra/base'

class KnowableLOL < Sinatra::Base
  get '/' do
    erb :index
  end
end
