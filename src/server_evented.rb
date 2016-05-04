require 'socket'
require './lib/evented'

puts "Starting server on port 2000"

server = TCPServer.open(2000)

CLIENTS = {}
MESSAGES = []

def create_client(nickname, socket)
  Fiber.new do
    # Store some info about this connection
    last_write = Time.now

    loop do
      state = Fiber.yield

      if state == :readable
        # Read a message from the socket
        incoming = read_line_from(socket)

        # If the message is nil the client disconnected
        if incoming.nil?
          puts "Disconnected nickname"
          # Remove the client from storage
          CLIENTS.delete(socket)
          # Exit fiber by breaking the loop
          break
        end

        # All good, add it to the list to write
        MESSAGES.push(
          :time => Time.now,
          :nickname => nickname,
          :text => incoming
        )
      elsif state == :writable
        get_messages_to_send(last_write, nickname, MESSAGES).each do |message|
          socket.puts "#{message[:nickname]}: #{message[:text]}"
        end

        last_write = Time.now
      end
    end
  end
end

# Our event loop
loop do

  # Step 1: See if we have any new incoming connections
  begin
    socket = server.accept_nonblock
    nickname = socket.gets.chomp
    CLIENTS[socket] = create_client(nickname, socket)
    puts "Accepted connection from #{nickname} on #{socket.addr.last}"
  rescue IO::WaitReadable, Errno::EINTR
    # No new incoming connections at the moment
  end

  # Step 2: Ask the OS to inform us when a connection is ready, wait for 10ms for this to happen
  readable, writable = IO.select(
    CLIENTS.keys,
    CLIENTS.keys,
    CLIENTS.keys,
    0.01
  )

  # Step 3: See if any of our connections are readable and trigger the client
  if readable
    readable.each do |ready_socket|
      # Get the client from storage
      client = CLIENTS[ready_socket]

      client.resume(:readable)
    end
  end

  # Step 4: See if any of our connections are writable and trigger the client
  if writable
    writable.each do |ready_socket|
      # Get the client from storage
      client = CLIENTS[ready_socket]
      next unless client

      client.resume(:writable)
    end
  end

  # Done! Onto the next tick of the event loop
end
