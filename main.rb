# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'pg'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

def connect_db(sql)
  connection = PG.connect(host: 'localhost', user: 'memouser', dbname: 'memoapp')
  begin
    result = connection.exec(sql)
  ensure
    connection.finish
  end
  result
end

get '/' do
  memos = connect_db('SELECT * FROM memos;')
  @memos = memos
  erb :top
end

get '/new' do
  erb :new
end

get '/memo/:id' do |id|
  memo = connect_db("SELECT * FROM memos WHERE id = '#{id}';")
  @title = memo[0]["title"]
  @content = memo[0]["content"]
  erb :show
end

post '/memo' do
  title = params[:title]
  content = params[:content]
  sql = "INSERT INTO memos(title, content) VALUES ('#{title}', '#{content}');"
  connect_db(sql)
  redirect '/'
  erb :top
end

get '/memo/:id/edit' do |id|
  memo = connect_db("SELECT * FROM memos WHERE id = '#{id}';")
  @title = memo[0]["title"]
  @content = memo[0]["content"]
  erb :edit
end

patch '/memo/:id' do |id|
  title = params[:title]
  content = params[:content]
  sql = "UPDATE memos SET title = '#{title}', content = '#{content}' WHERE id = '#{id}';"
  connect_db(sql)
  redirect '/'
  erb :top
end

delete '/memo/:id' do |id|
  sql = "DELETE FROM Memos WHERE id = '#{id}';"
  connect_db(sql)
  redirect '/'
  erb :top
end
