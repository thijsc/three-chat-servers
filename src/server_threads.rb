require 'socket'
require './lib/threads'

puts "Starting server on port 2000"

server = TCPServer.open(2000)

mutex = Mutex.new
messages = []

loop do

  # Accept incoming connections and spawn a thread for each one
  Thread.new(server.accept) do |client|
    nickname = read_line_from(client)
    puts "Accepted connection from #{nickname} on #{client.addr.last}"
    client.puts 'Connected to chat server, type away!'

    # Run another thread that sends incoming messages back to the client
    Thread.new do
      sent_until = Time.now
      loop do
        messages_to_send = mutex.synchronize do
          get_messages_to_send(nickname, messages, sent_until).tap do
            sent_until = Time.now
          end
        end
        messages_to_send.each do |message|
          client.puts "#{message[:nickname]}: #{message[:text]}"
        end
        sleep 0.2
      end

      puts "Disconnected #{nickname} on #{client.addr.last}"
    end

    # Listen for messages from the client and add these to the messages list
    while incoming = read_line_from(client)
      mutex.synchronize do
        messages.push(
          :time => Time.now,
          :nickname => nickname,
          :text => incoming
        )
      end
    end
  end

end
