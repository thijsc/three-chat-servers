require 'socket'

ip = ARGV[0]
nickname = ARGV[1]

if ip.nil? || nickname.nil?
  puts 'Please provide an IP adress and name: ruby client.rb 10.0.0.1 nickname'
  exit 1
end

puts "Connecting to #{ip} on port 2000"

# Connect to the server
client = TCPSocket.open(ip, 2000)

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
