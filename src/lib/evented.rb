def get_messages_to_send(last_write, nickname, messages)
  [].tap do |out|
    # Get the messages we haven't written yet for this client and send them
    messages.reverse_each do |message|
      # Once we're behind the last write time everything has already been sent
      break if message[:time] < last_write
      # Don't send if we typed this ourselves
      next if message[:nickname] == nickname

      out << message
    end
  end
end

# Read a line and strip any newlines
def read_line_from(socket)
  if read = socket.gets
    read.chomp
  end
end
