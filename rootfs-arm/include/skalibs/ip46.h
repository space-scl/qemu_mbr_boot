/* ISC license. */

#ifndef SKALIBS_IP46_H
#define SKALIBS_IP46_H

#include <string.h>
#include <stdint.h>
#include <errno.h>

#include <skalibs/fmtscan.h>
#include <skalibs/socket.h>

#define IP46_FMT IP6_FMT
#define IP4_ANY "\0\0\0"
#define IP6_ANY "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
#define IP4_LOCAL "\177\0\0\1"
#define IP6_LOCAL "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1"

typedef struct ip46full_s ip46full, *ip46full_ref ;

struct ip46full_s
{
  char ip[16] ;
  unsigned int is6: 1 ;
} ;
#define IP46FULL_ZERO { .ip = IP6_ANY, .is6 = 0 }

#define ip46full_is6(i) ((i)->is6)
#define ip46full_fmt(s, i) ((i)->is6 ? ip6_fmt(s, (i)->ip) : ip4_fmt(s, (i)->ip))
extern size_t ip46full_scan (char const *, ip46full *) ;
extern size_t ip46full_scanlist (ip46full *, size_t, char const *, size_t *) ;
#define ip46full_from_ip4(i, ip4) (memcpy((i)->ip, ip4, 4), memset((i)->ip + 4, 0, 12), (i)->is6 = 0)
#define ip46full_from_ip6(i, ip6) (memcpy((i)->ip, ip6, 16), (i)->is6 = 1)

typedef ip46full ip46, *ip46_ref ;
#define IP46_ZERO IP46FULL_ZERO

#define SKALIBS_IPV6_ENABLED
#define SKALIBS_IP_SIZE 16
#define ip46_is6(i) ip46full_is6(i)
#define ip46_fmt(s, i) ip46full_fmt(s, i)
#define ip46_scan(s, i) ip46full_scan(s, i)
#define ip46_scanlist(out, max, s, num) ip46full_scanlist(out, max, s, num)
#define ip46_from_ip4(i, ip4) (ip46full_from_ip4(i, ip4), 1)
#define ip46_from_ip6(i, ip6) (ip46full_from_ip6(i, ip6), 1)

#define socket_connect46(s, i, port) ((i)->is6 ? socket_connect6(s, (i)->ip, port) : socket_connect4(s, (i)->ip, port))
#define socket_bind46(s, i, port) ((i)->is6 ? socket_bind6(s, (i)->ip, port) : socket_bind4(s, (i)->ip, port))
#define socket_bind46_reuse(s, i, port) ((i)->is6 ? socket_bind6_reuse(s, (i)->ip, port) : socket_bind4_reuse(s, (i)->ip, port))

#define socket_tcp46(h) ((h) ? socket_tcp6() : socket_tcp4())
#define socket_tcp46_b(h) ((h) ? socket_tcp6_b() : socket_tcp4_b())
#define socket_tcp46_nb(h) ((h) ? socket_tcp6_nb() : socket_tcp4_nb())
#define socket_tcp46_coe(h) ((h) ? socket_tcp6_coe() : socket_tcp4_coe())
#define socket_tcp46_nbcoe(h) ((h) ? socket_tcp6_nbcoe() : socket_tcp4_nbcoe())
#define socket_tcp46_internal(h, flags) ((h) ? socket_tcp6_internal(flags) : socket_tcp4_internal(flags))

#define socket_udp46(h) ((h) ? socket_udp6() : socket_udp4())
#define socket_udp46_b(h) ((h) ? socket_udp6_b() : socket_udp4_b())
#define socket_udp46_nb(h) ((h) ? socket_udp6_nb() : socket_udp4_nb())
#define socket_udp46_coe(h) ((h) ? socket_udp6_coe() : socket_udp4_coe())
#define socket_udp46_nbcoe(h) ((h) ? socket_udp6_nbcoe() : socket_udp4_nbcoe())
#define socket_udp46_internal(h, flags) ((h) ? socket_udp6_internal(flags) : socket_udp4_internal(flags))

#define socket_recv46(fd, s, len, i, port) ((i)->is6 ? socket_recv6(fd, s, len, (i)->ip, port) : socket_recv4(fd, s, len, (i)->ip, port))
#define socket_send46(fd, s, len, i, port) ((i)->is6 ? socket_send6(fd, s, len, (i)->ip, port) : socket_send4(fd, s, len, (i)->ip, port))
extern int socket_local46 (int, ip46 *, uint16_t *) ;
extern int socket_remote46 (int, ip46 *, uint16_t *) ;

#define socket_recvnb46(fd, buf, len, i, port, deadline, stamp) ((i)->is6 ? socket_recvnb6(fd, buf, len, (i)->ip, port, deadline, stamp) : socket_recvnb4(fd, buf, len, (i)->ip, port, deadline, stamp))
#define socket_sendnb46(fd, buf, len, i, port, deadline, stamp) ((i)->is6 ? socket_sendnb6(fd, buf, len, (i)->ip, port, deadline, stamp) : socket_sendnb4(fd, buf, len, (i)->ip, port, deadline, stamp))

#define ip46_from_ip(i, s, h) ((h) ? ip46_from_ip6(i, s) : ip46_from_ip4(i, s))

#define socket_recvnb46_g(fd, buf, len, i, port, deadline) socket_recvnb46(fd, buf, len, i, port, (deadline), &STAMP)
#define socket_sendnb46_g(fd, buf, len, i, port, deadline) socket_sendnb46(fd, buf, len, i, port, (deadline), &STAMP)

extern int socket_deadlineconnstamp46 (int, ip46 const *, uint16_t, tain const *, tain *) ;
#define socket_deadlineconnstamp46_g(fd, ip, port, deadline) socket_deadlineconnstamp46(fd, ip, port, (deadline), &STAMP)

#endif
