# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'securerandom'
require 'pg'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/' do
  connection = PG.connect(host: 'localhost', user: 'memouser', dbname: 'memoapp')

  begin
    memos = connection.exec('SELECT * FROM memos;')
    @memos = memos
  ensure
    connection.finish
  end
  erb :top
end

get '/new' do
  erb :new
end

get '/memo/:id' do |id|
  connection = PG.connect(host: 'localhost', user: 'memouser', dbname: 'memoapp')
  begin
    memos = connection.exec('SELECT * FROM memos;')
    memos.each do |memo|
      if memo['id'] == id
        @title = memo['title']
        @content = memo['content']
      end
    end
  ensure
    connection.finish
  end
  erb :show
end

post '/memo' do
  connection = PG.connect(host: 'localhost', user: 'memouser', dbname: 'memoapp')
  title = h(params[:title])
  content = h(params[:content])
  begin
    connection.exec("INSERT INTO memos(title, content) VALUES ('#{title}', '#{content}');")
  ensure
    connection.finish
  end
  redirect '/'
  erb :top
end

get '/memo/:id/edit' do |id|
  connection = PG.connect(host: 'localhost', user: 'memouser', dbname: 'memoapp')
  begin
    memos = connection.exec('SELECT * FROM memos;')
    memos.each do |memo|
      if memo['id'] == id
        @title = memo['title']
        @content = memo['content']
      end
    end
  ensure
    connection.finish
  end
  erb :edit
end

patch '/memo/:id' do |id|
  connection = PG.connect(host: 'localhost', user: 'memouser', dbname: 'memoapp')
  title = h(params[:title])
  content = h(params[:content])
  begin
    connection.exec("UPDATE memos SET title = '#{title}', content = '#{content}' WHERE id = '#{id}';")
  ensure
    connection.finish
  end
  redirect '/'
  erb :top
end

delete '/memo/:id' do |id|
  connection = PG.connect(host: 'localhost', user: 'memouser', dbname: 'memoapp')
  begin
    connection.exec("DELETE FROM Memos WHERE id = '#{id}';")
  ensure
    connection.finish
  end
  redirect '/'
  erb :top
end
