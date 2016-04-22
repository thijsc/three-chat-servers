require 'socket'
require './lib/evented'

puts "Starting server on port 2000"

server = TCPServer.open(2000)

clients = {}
messages = []

# Our event loop
loop do

  # Step 1: See if we have any new incoming connections
  begin
    socket = server.accept_nonblock
    nickname = socket.gets.chomp
    client = {
      :last_write => Time.now,
      :nickname => nickname,
      :ip => socket.addr.last
    }
    clients[socket] = client
    puts "Accepted connection from #{client[:nickname]} on #{client[:ip]}"
  rescue IO::WaitReadable, Errno::EINTR
    # No new incoming connections at the moment
  end

  # Step 2: Ask the OS to inform us when a connection is ready, wait for 10ms for this to happen
  readable, writable = IO.select(
    clients.keys,
    clients.keys,
    clients.keys,
    0.01
  )

  # Step 3: See if any of our connections are readable and write messages to them
  if readable
    readable.each do |ready_socket|
      # Read a message from the socket
      incoming = read_line_from(ready_socket)

      # Get the client from storage
      client = clients[ready_socket]

      # If the message is nil the client disconnected
      if incoming.nil?
        puts "Disconnected #{client[:nickname]} on #{client[:ip]}"
        # Remove the client from storage
        clients.delete(ready_socket)
        next
      end

      # All good, add it to the list to write
      messages.push(
        :time => Time.now,
        :nickname => client[:nickname],
        :text => incoming
      )
    end
  end

  # Step 4: See if any of our connections are writable and write messages to them
  if writable
    writable.each do |ready_socket|
      # Get the client from storage
      client = clients[ready_socket]
      next unless client

      get_messages_to_send(client, messages).each do |message|
        ready_socket.puts "#{message[:nickname]}: #{message[:text]}"
      end

      client[:last_write] = Time.now
    end
  end

  # Done! Onto the next tick of the event loop
end
