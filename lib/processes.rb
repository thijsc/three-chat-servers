# Listen for incoming messages on the master's reader and write
# every incoming message to all forked processes
def write_incoming_messages_to_child_processes(master_reader, client_writers)
  Thread.new do
    while incoming = master_reader.gets
      client_writers.each do |writer|
        writer.puts incoming
      end
    end
  end
end

# Run a thread that listens to incoming messages from the master process and
# writes these back to the client
def write_incoming_messages_to_client(nickname, client_reader, socket)
  Thread.new do
    while incoming = client_reader.gets
      unless incoming.start_with?(nickname)
        puts incoming
        socket.puts incoming
      end
    end
  end
end

# Read a line and strip any newlines
def read_line_from(socket)
  if read = socket.gets
    read.chomp
  end
end
