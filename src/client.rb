require 'socket'

nickname = ARGV[0]

if nickname.nil?
  puts 'Please provide a name: ruby client.rb nickname'
  exit 1
end

puts "Connecting to chat server on port 2000"

# Connect to the server
client = TCPSocket.open('0.tcp.ngrok.io', 11481)

# Write the nickname to the server first
client.puts nickname

# Run a thread that puts anything the server sends
Thread.new do
  while line = client.gets
    puts line.chop
  end
end

# Send anything we type to the server
while input = STDIN.gets.chomp
  client.puts input
end
