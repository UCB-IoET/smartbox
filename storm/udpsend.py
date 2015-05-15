import os
import socket
import msgpack


# addressing information of target
IPADDR = '169.229.223.190'
#IPADDR = '2001:470:4956:1::1'
PORTNUM = 9666
 
# enter the data content of the UDP packet as hex
data = [1,15]
PACKETDATA = msgpack.packb(data)
 
# initialize a socket, think of it as a cable
# SOCK_DGRAM specifies that this is UDP
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, 0)
 
# connect the socket, think of it as connecting the cable to the address location
s.connect((IPADDR, PORTNUM))
 
# send the command
s.send(PACKETDATA)
 
# close the socket
s.close()
