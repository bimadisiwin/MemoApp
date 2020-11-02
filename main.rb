# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'pg'
require 'dotenv/load'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

connection = PG::connect(
    host: ENV["DB_HOST"],
    user: ENV["DB_USER"],
    dbname: ENV["DB_NAME"]
)

get '/' do
  memos = connection.exec('SELECT * FROM memos;')
  @memos = memos
  erb :top
end

get '/new' do
  erb :new
end

get '/memo/:id' do |id|
  memo = connection.exec_params("SELECT * FROM memos WHERE id=$1;", [id])
  @title = memo[0]["title"]
  @content = memo[0]["content"]
  erb :show
end

post '/memo' do
  title = params[:title]
  content = params[:content]
  connection.exec_params("INSERT INTO memos(title, content) VALUES ($1, $2);", [title, content])
  redirect '/'
  erb :top
end

get '/memo/:id/edit' do |id|
  memo = connection.exec_params("SELECT * FROM memos WHERE id=$1;", [id])
  @title = memo[0]["title"]
  @content = memo[0]["content"]
  erb :edit
end

patch '/memo/:id' do |id|
  title = params[:title]
  content = params[:content]
  connection.exec_params("UPDATE memos SET title = $1, content = $2 WHERE id = $3;", [title, content, id])
  redirect '/'
  erb :top
end

delete '/memo/:id' do |id|
  connection.exec_params("DELETE FROM Memos WHERE id=$1;", [id])
  redirect '/'
  erb :top
end
