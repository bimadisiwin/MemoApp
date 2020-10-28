# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'

JSON_FILE_PATH = 'memos/memo.json'
$json_data = open(JSON_FILE_PATH) { |io| JSON.load(io) }
memos = $json_data['memos']

def write_json
  File.open(JSON_FILE_PATH, 'w') do |file|
    JSON.dump($json_data, file)
  end
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/' do
  @memos = memos
  erb :top
end

get '/new' do
  erb :new
end

get '/memo/:id' do |id|
  memos.find do |memo|
    if memo['id'] == id
      @title = memo['title']
      @content = memo['content']
    end
  end
  erb :show
end

post '/memo' do
  id = SecureRandom.uuid
  new_memo = {'id' => id.to_s, 'title' => "#{h(params[:title])}", 'content' => "#{h(params[:content])}"}
  memos.push(new_memo)
  write_json
  redirect '/'
  erb :top
end

get '/memo/:id/edit' do |id|
  memos.find do |memo|
    if memo['id'] == id
      @title = memo['title']
      @content = memo['content']
    end
  end
  erb :edit
end

patch '/memo/:id' do |id|
  memos.each do |memo|
    if memo['id'] == id
      memo['title'] = "#{h(params[:title])}"
      memo['content'] = "#{h(params[:content])}"
    end
  end
  write_json
  redirect '/'
  erb :top
end

delete '/memo/:id' do |id|
  memos.find do |memo|
    memos.delete(memo) if memo['id'] == id
  end
  write_json
  redirect '/'
  erb :top
end
