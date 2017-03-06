require 'socket'

Thread.abort_on_exception = true

host = ARGV[0]
nickname = ARGV[1]

if host.nil? || nickname.nil?
  puts 'Please provide a host and name: ruby client.rb host nickname'
  exit 1
end

puts "Connecting to #{host} on port 2000..."

# Connect to the server
client = TCPSocket.open(host, 2000)

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
