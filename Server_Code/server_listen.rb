#!/usr/bin/env ruby
require 'rubygems'
require 'aws-sdk'
require 'socket'

server = TCPServer.open(2000)
loop {
  Thread.start(server.accept) do |client|
    puts 'Time requested on client side'
    client.puts(Time.now.ctime)
      client.puts 'Closing connection'
    client.close
  end
}

puts 'Hello World'
