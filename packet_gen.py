
from scapy.all import *
import zlib
import struct

def ping(dest_ip, dest_mac, src_ip, src_mac, port):
    return Ether(src=src_mac, dst = dest_mac) / Dot1Q(vlan=port) / IP(dst=dest_ip, src=src_ip) / ICMP() / "abcdefghijklmnopqrstuvwabcdefghi"

def arp_request(dest_ip, src_ip, src_mac, port):
    return Ether(src=src_mac) / Dot1Q(vlan=port) / ARP(hwsrc=src_mac, psrc=src_ip, pdst=dest_ip)

def padding(byte_array):
    length = 60
    return byte_array.ljust(length, bytes(1))

def wrapCrc32(pkt):
    pkt = padding(pkt)
    crc = zlib.crc32(pkt)
    pkt += struct.pack('<I', crc)
    return pkt

def toString(ba):
    ret = ''
    for i in ba:
        ret += '%02X ' % (i)
    return ret

def gen(x):
    return '55 55 55 55 55 55 55 D5 ' + toString(wrapCrc32(raw(x)))

def genCPU(x):
    return toString(raw(x))

def Case1():
    print(gen(ping('10.0.3.14', '02:02:03:03:00:00', '10.0.0.12', '98:40:bb:18:eb:5a', 2)))
    print(gen(ping('10.0.0.1',  '02:02:03:03:00:00', '10.0.0.12', '98:40:bb:18:eb:5a', 2)))
    print(gen(arp_request('10.0.0.1', '10.0.0.12', '98:40:bb:18:eb:5a', 2)))
    print(gen(arp_request('10.0.0.1', '10.0.3.14', '23:45:67:89:01:23', 4)))

def Case2():
    print(genCPU(ping('10.0.0.12', 'ff:ff:ff:ff:ff:ff', '10.0.0.1', '02:02:03:03:00:00', 2)))


# Case1()

print(gen(arp_request('10.0.1.1', '10.0.1.11', 'ac:e2:d3:6b:e0:ef', 1)))
