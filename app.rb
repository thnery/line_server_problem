require 'sinatra'
require 'sinatra/json'
require_relative 'services/line_service'

class LineServerAPI < Sinatra::Base
  configure do
    set :json_content_type, :json
    set :line_service, LineService.new
  end

  # Routes
  get '/lines/:index' do
    content_type :json

    index = params[:index].to_i
    line_content = settings.line_service.get_line(index)

    {
      line_index: index.to_i,
      content: line_content,
      status: :ok
    }.to_json
  rescue LineService::FileLoadError => e
    halt 422, json(
      error: "Invalid file format",
      detail: e.message
    )
  rescue LineService::LineNotFoundError
    status 413
    "Line index out of range"
  end

  # Health check
  get '/ping' do
    json status: 'ok'
  end

  run! if __FILE__ == $0
end
