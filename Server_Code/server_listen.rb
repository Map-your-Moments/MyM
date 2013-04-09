#!/usr/bin/env ruby
require 'rubygems'
require 'aws-sdk'
require 'socket'
require 'net/http'


server = TCPServer.open(2000)

loop {
  Thread.start(server.accept) do |client|
    puts 'Time requested on client side'
    lines = []
    while line = client.gets and line !~/^\s*$/
      lines << line.chomp
      for line in lines
        puts line
      end
    end

    #socket.print(Time.now.ctime)
    client.puts(Time.now.ctime)
      client.puts 'Closing connection'
    client.close
  end
}

