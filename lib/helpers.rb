def server_address
  Socket.ip_address_list.detect do |intf|
    intf.ipv4_private?
  end.ip_address
end
