# Read a line and strip any newlines
def read_line_from(socket)
  if read = socket.gets
    read.chomp
  end
end

def get_messages_to_send(nickname, messages, sent_until)
  [].tap do |out|
    messages.reverse_each do |message|
      # Once we're behind sent_until everything has already been sent
      break if message[:time] < sent_until
      # Don't send if we typed this ourselves
      next if message[:nickname] == nickname

      out.push(message)
    end
  end
end
