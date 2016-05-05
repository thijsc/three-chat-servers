require 'socket'

nickname = ARGV[0]

if nickname.nil?
  puts 'Please provide a host and name: ruby client.rb host nickname'
  exit 1
end

puts "Connecting on port 2000..."

# Connect to the server
client = TCPSocket.open('0.tcp.ngrok.io', 12518)

puts 'Connected to chat server, type away!'

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
