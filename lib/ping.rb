require 'xmlrpc/client'

# By BrianTheCoder: http://refactormycode.com/codes/131-technorati-ping
module Ping
  
  def ping(rpc_server, title, url)
    begin
        server = XMLRPC::Client.new(rpc_server, "/rpc/ping", 80)
        begin
          result = server.call("weblogUpdates.ping", title, url)
          puts result.inspect
        rescue XMLRPC::FaultException => e
          puts "Error: [#{ e.faultCode }] #{ e.faultString }" 
        end
    rescue Exception => e
      puts "Error: #{ e.message }" 
    end
  end
end

