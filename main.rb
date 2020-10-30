# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'
require 'pg'

JSON_FILE_PATH = 'memos/memo.json'
@@json_data = open(JSON_FILE_PATH) { |io| JSON.load(io) }
memos = @@json_data['memos']

def write_json
  File.open(JSON_FILE_PATH, 'w') do |file|
    # p file
    JSON.dump(@@json_data, file)
  end
end

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

get '/memo/:id' do
  connection = PG.connect(host: 'localhost', user: 'memouser', dbname: 'memoapp')
  begin
    memos = connection.exec('SELECT * FROM memos;')
    memos.each do |memo|
      if memo['id'] == params[:id]
        @title = memo['title']
        @content = memo['content']
      end
    end
  ensure
    connection.finish
  end
  erb :show
end

post '/new' do
  connection = PG.connect(host: 'localhost', user: 'memouser', dbname: 'memoapp')
  title = params[:title]
  content = params[:content]
  begin
    connection.exec("INSERT INTO memos(title, content) VALUES ('#{title}', '#{content}');")
  ensure
    connection.finish
  end
  redirect '/'
  erb :top
end

get '/memo/edit/:id' do
  memos.each do |memo|
    if memo['id'].to_s == params[:id].to_s
      @title = memo['title']
      @content = memo['content']
    end
  end
  erb :edit
end

patch '/memo/edit/:id' do |id|
  connection = PG.connect(host: 'localhost', user: 'memouser', dbname: 'memoapp')
  title = params[:title]
  content = params[:content]
  begin
    connection.exec("UPDATE memos SET title = '#{title}', content = '#{content}' WHERE id = '#{id}';")
  ensure
    connection.finish
  end
  redirect '/'
  erb :top
end

delete '/memo/delete/:id' do |id|
  connection = PG.connect(host: 'localhost', user: 'memouser', dbname: 'memoapp')
  begin
    connection.exec("DELETE FROM Memos WHERE id = '#{id}';")
  ensure
    connection.finish
  end
  redirect '/'
  erb :top
end
