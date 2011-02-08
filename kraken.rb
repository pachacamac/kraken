#!/usr/bin/env ruby
require 'rubygems' if RUBY_VERSION < "1.9"
require 'sinatra/base'
require "net/http"
require 'pstore'
require 'json'
require 'md5'

#post(Create), get(Read), put(Update), delete(Delete)

class Kraken < Sinatra::Base
  configure do
    set :server, %w[thin mongrel webrick]
    @store = PStore.new(File.expand_path('kraken.store'))
    @store.transaction{
      @store[:hashes]  || = {}
      @store[:files]   || = {}
      @store[:deleted] || = {}
      @store[:peers]   || = {}
      @store[:config]  || = {}
    }
    set :port, 7007
    set :root, File.dirname(__FILE__)
    @interval = 30
    FILES = File.expand_path('public')
    set :public, FILES
  end
  
  def hashwork
    @store.transaction{
      #hash new files
      Dir.open(@files).each do |f|
        fp = File.join(@files,f)
        if File.file?(fp) && !@store[:hashes][f] && !@store[:deleted][f]
          hash = MD5.file(fp).to_s
          @store[:hashes][hash] = {:file => f}
          @store[:files][f] = {:hash => hash, :htime => Time.now, :size => File.size(fp)}
          #TODO: fire asynch "new file" event
        end
      end
      @store[:hashes].each_pair do |f,h|
        fp = File.join(@files,f)
        #handle deleted files
        if !File.exists?(fp)
          @store[:deleted][f] = @store[:hashes][f]
          @store[:hashes].delete(f)
          @store[:files]
          #TODO: fire asynch "file deleted" event
        #recalculate hash
        elsif repair || h[:htime] < File.mtime(fp)
          @store[:hashes][f] = {:hash  => MD5.file(fp).to_s, :htime => Time.now}
          #TODO: fire asynch "file updated" event
        end
      end
    }
  end
  
  def peerwork
    @store.transaction{
      @store[:peers].each do |peer|
        
      end
    }
  end
  
  #configure do #configure :production do #RACK_ENV environment variable
  #end

  get '/' do
    '<title>K R A K E N</title><h1>K R A K E N</h1><img src="kraken.png" alt="kraken">'
  end
  
  get '/favicon.ico' do
    send_file 'favicon.ico'
  end
  
  get '/kraken.png' do
    send_file 'kraken.png'
  end
  
  get '/test' do
    "port is set to #{ options.port }"
  end
  
  get '/peers' do
    content_type :json
    @store.transaction(true){@store[:peers]}
  end

  post '/peers/' do
    #???
    #TODO: merge with hash in post if it is valid
    #      how to access the post body?
    data = JSON.parse request.body.read
    @store.transaction{@store[:peers].merge! params[:peers]}
    #???
  end

  get '/file/:hash' do
    content_type 'application/octet-stream'
    @transaction(true){
      file = @store[:hashes][params[:hash]]
    }
    #send_file 'the file'
  end
  
  put '/files' do
    
  end  
  
end

Kraken.run!

