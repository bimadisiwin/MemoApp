# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'

json_file_path = 'memos/memo.json'

json_data = open(json_file_path) { |io| JSON.load(io) }

memos = json_data['memos']

get '/' do
  @memos = memos
  erb :top
end

get '/new' do
  erb :new
end

get '/memo/:id' do
  memos.each do |memo|
    if memo['id'].to_s == params[:id].to_s
      @title = memo['title'].to_s
      @content = memo['content']
    end
  end
  erb :show
end

post '/new' do
  id = SecureRandom.uuid
  new_memo = { 'id' => id.to_s, 'title' => params[:title], 'content' => params[:content] }
  memos.push(new_memo)

  File.open(json_file_path, 'w') do |file|
    JSON.dump(json_data, file)
  end
  redirect '/'
  erb :top
end

get '/memo/edit/:id' do
  memos.each do |memo|
    if memo['id'].to_s == params[:id].to_s
      @title = memo['title'].to_s
      @content = memo['content']
    end
  end
  erb :edit
end

patch '/memo/edit/:id' do
  memos.each do |memo|
    if memo['id'].to_s == params[:id].to_s
      memo['title'] = params[:title]
      memo['content'] = params[:content]
    end
  end
  File.open(json_file_path, 'w') do |file|
    JSON.dump(json_data, file)
  end
  redirect '/'
  erb :top
end

delete '/memo/delete/:id' do
  memos.each do |memo|
    memos.delete(memo) if memo['id'].to_s == params[:id].to_s
  end
  File.open(json_file_path, 'w') do |file|
    JSON.dump(json_data, file)
  end
  redirect '/'
  erb :top
end
