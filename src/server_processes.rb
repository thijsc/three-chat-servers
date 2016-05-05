require 'socket'
require './lib/processes'

puts "Starting server on port 2000 with pid #{Process.pid}"

server = TCPServer.open(2000)

client_writers = []
master_reader, master_writer = IO.pipe

write_incoming_messages_to_child_processes(master_reader, client_writers)

# Run a loop that waits for incoming connections to the server and
# forks a child process for every connection.
loop do
  while socket = server.accept

    # Create a client reader and writer so that the master process can
    # write messages back to us
    client_reader, client_writer = IO.pipe

    # Put the client writer on the list of writers so the master process can write to them
    client_writers.push(client_writer)

    # Fork child process, everything in the fork block only runs in the child process
    fork do
      nickname = read_line_from(socket)
      puts "#{Process.pid}: Accepted connection from #{nickname}"

      write_incoming_messages_to_client(nickname, client_reader, socket)

      # Read incoming messages from the client.
      while incoming = read_line_from(socket)
        master_writer.puts "#{nickname}: #{incoming}"
      end

      puts "#{Process.pid}: Disconnected #{nickname}"
    end

  end
end
