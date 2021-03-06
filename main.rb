# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'

JSON_FILE_PATH = 'memos/memo.json'
json_data = open(JSON_FILE_PATH) { |io| JSON.load(io) }
memos = json_data['memos']

def write_json(json_data)
  File.open(JSON_FILE_PATH, 'w') do |file|
    # p file
    JSON.dump(json_data, file)
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
  target_memo = memos.find { |memo| memo['id'] == id }
  @title = target_memo['title']
  @content = target_memo['content']
  erb :show
end

post '/memo' do
  id = SecureRandom.uuid
  new_memo = { 'id' => id.to_s, 'title' => params[:title], 'content' => params[:content] }
  memos.push(new_memo)
  write_json(json_data)
  redirect '/'
  erb :top
end

get '/memo/:id/edit' do |id|
  target_memo = memos.find { |memo| memo['id'] == id }
  @title = target_memo['title']
  @content = target_memo['content']
  erb :edit
end

patch '/memo/:id' do |id|
  target_memo = memos.find { |memo| memo['id'] == id }
  target_memo['title'] = params[:title]
  target_memo['content'] = params[:content]
  write_json(json_data)
  redirect '/'
  erb :top
end

delete '/memo/:id' do |id|
  target_memo = memos.find { |memo| memo['id'] == id }
  memos.delete(target_memo)
  write_json(json_data)
  redirect '/'
  erb :top
end
