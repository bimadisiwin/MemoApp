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

not_found do
  '404 Not Found.'
end

def connect_db
  connection = PG.connect(
    host: ENV['DB_HOST'],
    user: ENV['DB_USER'],
    dbname: ENV['DB_NAME']
  )
  begin
    yield(connection) if block_given?
  ensure
    connection.finish
  end
end

get '/' do
  connect_db do |connection|
    memos = connection.exec('SELECT * FROM memos;')
    @memos = memos
  end

  erb :top
end

get '/new' do
  erb :new
end

get '/memo/:id' do |id|
  begin
    connect_db do |connection|
      memo = connection.exec_params('SELECT * FROM memos WHERE id=$1;', [id])
      @title = memo[0]['title']
      @content = memo[0]['content']
    end
  rescue StandardError
    not_found
  end
  erb :show
end

post '/memo' do
  title = params[:title]
  content = params[:content]
  connect_db do |connection|
    connection.exec_params('INSERT INTO memos(title, content) VALUES ($1, $2);', [title, content])
  end
  redirect '/'
  erb :top
end

get '/memo/:id/edit' do |id|
  begin
    connect_db do |connection|
      memo = connection.exec_params('SELECT * FROM memos WHERE id=$1;', [id])
      @title = memo[0]['title']
      @content = memo[0]['content']
    end
  rescue StandardError
    not_found
  end
  erb :edit
end

patch '/memo/:id' do |id|
  title = params[:title]
  content = params[:content]
  connect_db do |connection|
    connection.exec_params('UPDATE memos SET title = $1, content = $2 WHERE id = $3;', [title, content, id])
  end
  redirect '/'
  erb :top
end

delete '/memo/:id' do |id|
  begin
    connect_db do |connection|
      connection.exec_params('DELETE FROM Memos WHERE id=$1;', [id])
    end
  rescue StandardError
    not_found
  end
  redirect '/'
  erb :top
end
