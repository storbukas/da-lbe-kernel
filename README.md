# DA-LBE Linux Kernel Framework #

The DA-LBE Linux Kernel Framework. Implementing Less than Best Effort with Deadlines in the Linux Kernel as a contribution to the New, Evolutive API and Transport-Layer (NEAT) Architecture for the Internet.

A Deadline Aware, Less Than Best Effort framework implemented in the Linux Kernel, providing mechanisms which allow an arbitrary Congestion Control (CC) to behave Less than Best Effort (LBE) with the notion of time in order to complete within given a soft deadline.


## Abstract

Applications which do not carry strong capacity or latency constraints, such as backups, could use a Less than Best Effort (LBE) transport protocol as an alternative to best-effort TCP. This could minimize their potential to disrupt network flows with a higher significance. Existing Less than Best Effort Congestion Controls, such as LEDBAT, enforce LBE behaviour without any timeliness requirements regarding completion time.

This paper introduces a framework API in the Linux kernel that provides the ability to impose timeliness requirements and LBE behaviour on an arbitrary CC. The framework measures the degree of network congestion based on the most commonly used metrics of network congestion (loss, delay, and explicit congestion notification). The framework introduces functionality which provides the ability for network traffic to adjust its relative share of network capacity on a per-flow level. This functionality should be used to control the level of LBEness based on the congestion level in the network, as well as the relative time until the contracted completion time.

The implementation in the Linux kernel builds on the framework proposal composed by David A. Hayes, David Ros, Andreas Petlund, and Iffat Ahmed. The framework proposal includes a solid foundation for the implemented framework. The effectiveness of the approach in the framework proposal is validated by numerical and emulation experiments. The effectiveness of the implemented framework is validated by simulation experiments. Both the emulation and simulation experiments use TCP Cubic or TCP Vegas as a Congestion Control mechanism.


## DA-LBE Framework

The Deadline Aware, Less than Best Effort (DA-LBE) framework, implemented in Linux should provide the following functionality:

* Keep disruption of concurrent BE interactive services to a minimum.
* Add a timeliness constraint to the transport, i.e., the transfer should be finished by a soft deadline to fit in with other network activities and to ensure the timely correctness of replicated data.

The key motivational points of the DA-LBE framework is to:

* Impose LBE behaviour with a notion of time in order to support soft deadlines by dynamically adjusting the aggressiveness when competing with BE network traffic. Soft deadlines can prevent network starvation and latecomer unfairness as is observed in an LBE implementation such as LEDABT.
* Support a wide range of CCs as opposed to attempt to develop a one-size-fits-all CC. This will allow application developers to enable deadline aware LBE behaviour on new or existing applications with minimal configuration requirements.

To achieve the functionality described above, it should be able to dynamically adjust its aggressiveness in competing with BE traffic from that of a scavenger-type service up to that of a BE-type service. The DA-LBE framework would be required to provide information which shows the current state of the network in regards to network congestion and bandwith utilization. In order to support modification of the transmission rate of an arbitrary CC, mechanisms which will change the perception of network congestion indications is required. The DA-LBE framework must provide mechanism which are applicable to commonly used network congestion indicators such as loss, queueing delay and explicit congestion notifications.


### Less than Best Effort (LBE)

Commonly, network traffic is carried out using a Best Effort (BE) service in order to  maximize their transmission rate. Network traffic carried out by an LBE service is yielding towards network traffic using a BE service. LBE behaviour is commonly called a scavenger service, based on the fact that it is utilizing unused network bandwidth. Providing LBE service entails only using bandwidth which is unused by other consumers on the network, particularly non-LBE traffic. LBE yield to non-LBE traffic, adapting to network changes and traffic load on the network. When an LBE service observes a decrease in network congestion it will increase its transmission rate. Similarly, an LBE service will decrease its transmission rate when it observes an increase in congestion indications, in order to allow for traffic of differing urgency to maximize their transmission rate, resulting in a more efficient utilization of network bandwidth. Below is a graph showing how LBE yields towards other network flows.

![Less than Best Effort behaviour](Documentation/DA-LBE/lbe-example.png?raw=true "LBE behaviour")

There exist different transport protocols which implement LBE behaviour, such as LEDBAT and FLOWER, with LEDBAT being the most well-known deployed implementation.


### New Evolutive API and Transport-Layer (NEAT)

The DA-LBE framework is is a contribution to a [New Evolutive API and Transport-Layer (NEAT)](https://www.neat-project.org/) Architecture for the Internet. An overview of the NEAT architecture is presented below.

![NEAT](Documentation/DA-LBE/neat-architecture.png?raw=true "NEAT Architecture")

NEAT is funded by the European Union's Horizon 2020 research and innovation programme. Applications which do not carry strong capacity or latency constraints, such as backups, could use a Less than Best Effort (LBE) transport protocol as an alternative to best-effort TCP. This could minimize their potential to disrupt network flows with a higher significance. Existing LBE CCs, such as LEDBAT, enforce LBE behaviour without any timeliness requirements regarding completion time.


## Implementation in Linux

David Miller’s [net-next](https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git) tree has been used as a starting point in the implementation of the DA-LBE framework. Net-next is a fork of the Linux kernel which contains a wider range of different networking components in the source code (i.e., more TCP CC algorithms).

![Linux Kernel Map](Documentation/DA-LBE/da-lbe-linux-kernel-map.png?raw=true "Linux Kernel Map - DA-LBE parts highlighted")

The Linux Kernel parts which the DA-LBE framework is located is highlighted in the Linux Kernel Map presented above.


### DA-LBE API

The DA-LBE framework provides an API available to user-space by using socket options to retrieve and control the DA-LBE mechanisms. Below is a presentation of how the Linux Kernel communication is organized in regards to the DA-LBE API.

![Linux Kernel Communication with the DA-LBE API](Documentation/DA-LBE/kernel-communication.png?raw=true "DA-LBE API Linux Kernel Communication")

The DA-LBE mechanisms is accessed using newly implemented socket options, specific to the DA-LBE implementation. The socket options and DA-LBE mechanisms is described below.


#### Socket Options

This table gives an overview of the socket options implemented in the DA-LBE framework, and provides a short description about the purpose of each socket option.

Socket Option | Purpose
--- | ---
DA_LBE_INFO | Send data to Destination with DA-LBE enabled
DA_LBE_INFO_ECN | Send data to Destination with DA-LBE enabled
DA_LBE_MODE | The argument specifies whether or not DA-LBE should be enabled for the current socket (stream). The argument is either 1 (enabled) or 0 (disabled).
DA_LBE_ECN_BACKOFF | The argument given specifies the probab- ility of not backing off (ignoring) on a real ECN signal. The percentage must be multiplied with the maximum value of an unsigned INT.
DA_LBE_CWND_BACKOFF | The argument given specifies the probab- ility of not backing off on a congestion event. The percentage must be multiplied with the maximum value of an unsigned INT.
DA_LBE_CONGESTION_PRICE | The argument given specifies the infla- tion/deflation of the congestion price. The percentage must be multiplied with the maximum value of an unsigned INT.
DA_LBE_BASE_RTT_BASED | The argument specifies whether or not the CC in use is BASE_RTT based. The argument is either 1 (enabled) or 0 (disabled).
DA_LBE_DELAY_BASED_MODE | The argument specifies whether or not the CC in use is delay based. The argument is either 1 (enabled) or 0 (disabled).
DA_LBE_ECN_CONGESTION_DELAY | Receive data from DA-LBE and Background traffic machines
DA_LBE_EWMA_WEIGHT | Receive data from DA-LBE and Back- ground traffic machines

The individual socket options and their mechanisms are exaplained in more detailed below.


#### DA_LBE_INFO

Returns a struct with statistics related to the TCP stream and the DA-LBE system.

```c
struct da_lbe_info {
  __u8	dalbe_state;
  __u8  dalbe_ca_state;
  __u8	dalbe_options;

  __u32 dalbe_fast_retransmits;
  __u32 dalbe_slow_retransmits;

  __u32	dalbe_snd_cwnd;
  __u32	dalbe_snd_mss;
  __u32	dalbe_snd_ssthresh;
  __u32 dalbe_packets_acked;
  __u64	dalbe_bytes_acked;

  __u32 dalbe_ecn_count;
  __u32 dalbe_phantom_ecn_count;

  __s64 dalbe_avg_congestion_interval;
  __u32 dalbe_congestion_event_count;

  __u64 dalbe_cwnd_proportion_aggregated;
  __u32 dalbe_cwnd_nr_of_proportions;
};
```


#### DA_LBE_INFO_ECN

The argument given specifies the probability of generating an ECN signal. The percentage must be multiplied with the maximum value of an unsigned INT.

**Example:**

The argument to be sent with the socket option DA_LBE_INFO_ECN, given a percentage of 3%, you must do the following calculation.

```c
probability = UINT_MAX * 0.03;
```


#### DA_LBE_MODE

The argument specifies whether or not DA-LBE should be enabled for the current socket (stream). The argument is either 1 (enabled) or 0 (disabled).


#### DA_LBE_ECN_BACKOFF

The argument given specifies the probability of not backing off (ignoring) on a real ECN signal. The percentage must be multiplied with the maximum value of an unsigned INT.

**Example:**

The argument to be sent with the socket option DA_LBE_ECN_BACKOFF, given a percentage of 3%, you must do the following calculation.

probability = UINT_MAX * 0.03;


#### DA_LBE_CWND_BACKOFF

The argument given specifies the probability of not backing off on a congestion event. The percentage must be multiplied with the maximum value of an unsigned INT.

**Example:**

The argument to be sent with the socket option DA_LBE_CWND_BACKOFF, given a percentage of 3%, you must do the following calculation.

```c
probability = UINT_MAX * 0.03;
```


#### DA_LBE_CONGESTION_PRICE

The argument given specifies the inflation/deflation of the congestion price. The percentage must be multiplied with the maximum value of an unsigned INT.

**Example:**

The argument to be sent with the socket option DA_LBE_CONGESTION_PRICE, given a percentage of 150% (inflating with 50%), you must do the following calculation.

```c
probability = UINT_MAX * 1.5;
```


#### DA_LBE_BASE_RTT_BASED

The argument specifies whether or not the congestion control in use is BASE_RTT based. The argument is either 1 (enabled) or 0 (disabled).


#### DA_LBE_DELAY_BASED_MODE

The argument specifies whether or not the congestion control in use is delay based. The argument is either 1 (enabled) or 0 (disabled).


#### DA_LBE_ECN_CONGESTION_DELAY

TODO


## Miscellaneous

### Building the Linux Kernel

In order to get started building and installing the Linux Kernel containing the DA-LBE framework, you can follow the steps below.

* Download a copy of the source code ( `git clone git@github.com:storbukas/da-lbe-kernel.git` )
* Move the repository to the Linux Kernel source directory ( `mv da-lbe /usr/src/` )
* Install using the custom build script ( `sudo ./build-kernel.sh` )


### Example of use

#### Using getsockopt()

```c
if (getsockopt(tcp_socket, IPPROTO_TCP, DA_LBE_INFO,
                (void *)&da_lbe_info,
                (socklen_t *) &da_lbe_info_length) != 0) {
  printf("Can not get statistics from getsockopt: DA_LBE_INFO\n");
}
```

#### Using setsockopt()

```c
if (setsockopt(tcp_socket, IPPROTO_TCP, DA_LBE_INFO_ECN,
                 (char *) &opt_ecn_probability,
                 sizeof(opt_ecn_probability)) < 0) {
  printf("Can't set data with setsockopt: DA_LBE_INFO_ECN\n");
}
```

### Thorough Example

```c
/*
 *  Author: Lars Erik Storbukås <larserik@storbukas.no>
 *          http://larserik.storbukas.no
 *  Date: 11/02-2018
 *
 *  Description:
 *
 *    Simple TCP client transferring a file to a destination with
 *    DA-LBE mechanisms enabled. This transfer has configured a
 *    probability of 5% of Phantom ECN signals (which reduce the
 *    transmission rate without dropping packets).
 *    
 *  Setup:
 *  
 *    This scripts sends a file located in the same directory as
 *    this script, called 'foobar.data' which is a file populated
 *    with random data. A file of 100 megabyte can be produced by
 *    issuing the following command:
 *    
 *      $ head -c 100MB < /dev/urandom > foobar.data
 *
 */

#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <sys/wait.h>
#include <sys/socket.h>
#include <signal.h>
#include <ctype.h>
#include <arpa/inet.h>
#include <netdb.h>

#include <linux/tcp.h>  // for DA-LBE socket options
#include <limits.h> // for UINT_MAX

#define PORT 12345
#define LENGTH 1448
#define DESTINATION_IP "192.168.1.100"
#define INPUT_FILE "foobar.data"

void error(const char *msg) {
  perror(msg);
  exit(1);
}

int main(int argc, char *argv[]) {
  /* Variable Definition */
  int sockfd;
  int nsockfd;
  char revbuf[LENGTH];
  struct sockaddr_in remote_addr;

  /* Get the Socket file descriptor */
  if ((sockfd = socket(AF_INET, SOCK_STREAM, IPPROTO_IP)) == -1) {
    error("ERROR: Failed to obtain Socket Descriptor!\n");
  }

  /* Fill the socket address struct */
  remote_addr.sin_family = AF_INET;
  remote_addr.sin_port = htons(PORT);
  inet_pton(AF_INET, DESTINATION_IP, &remote_addr.sin_addr);
  bzero(&(remote_addr.sin_zero), 8  );

  /* Try to connect the remote */
  if (connect(sockfd, (struct sockaddr *)&remote_addr, sizeof(struct sockaddr)) == -1) {
    error("ERROR: Failed to connect to the host!\n");
  }
  else {
    printf("Connected to the host at port %d\n", PORT);
  }

  /* Send File to recipient */
  char* fs_name = INPUT_FILE;
  char sdbuf[LENGTH];

  printf("Sending %s to %s\n", fs_name, DESTINATION_IP);

  FILE *fs = fopen(fs_name, "r");
  if(fs == NULL) {
    printf("ERROR: File %s not found.\n", fs_name);
    exit(1);
  }

  /* DA-LBE setsockopt */
  int opt_da_lbe_mode = TCP_DA_LBE_ENABLED;
  if (setsockopt(sockfd, IPPROTO_TCP, DA_LBE_MODE,
                (char *)&opt_da_lbe_mode,
                sizeof(opt_da_lbe_mode)) != 0) {
    printf("Can't set data with setsockopt: DA_LBE_MODE\n");
    exit(1);
  }

  unsigned int opt_ecn_probability = 0.05 * UINT_MAX; // 5% Phantom ECN probability
  if (setsockopt(sockfd, IPPROTO_TCP, DA_LBE_INFO_ECN,
                (char *)&opt_ecn_probability,
                sizeof(opt_ecn_probability)) != 0) {
    printf("Can't set data with setsockopt: DA_LBE_INFO_ECN\n");
    exit(1);
  }

  bzero(sdbuf, LENGTH);
  int fs_block_sz;

  while((fs_block_sz = fread(sdbuf, sizeof(char), LENGTH, fs)) > 0) {
    if(send(sockfd, sdbuf, fs_block_sz, 0) < 0) {
      printf("ERROR: Failed to send file %s.\n", fs_name);
      break;
    }

    bzero(sdbuf, LENGTH);
  }

  printf("Transfer of %s done!\n", fs_name);

  /* DA-LBE setsockopt */
  struct da_lbe_info da_lbe_info;
  unsigned short da_lbe_info_length = sizeof(da_lbe_info);
  if (getsockopt(sockfd, IPPROTO_TCP, DA_LBE_INFO,
                (void *)&da_lbe_info,
                (socklen_t *)&da_lbe_info_length) != 0) {
    printf("ERROR: Failed to fetch DA_LBE_INFO\n");
  } else {
    printf("Number of phantom ECNs generated: %u\n", da_lbe_info.dalbe_phantom_ecn_count);
  }

  close(fs);
  close (sockfd);
  printf("Connection closed.\n");
  return (0);
}
```

The example shown above is also available [here](https://gist.github.com/storbukas/ec1e7ca97c9c1942c52e20143c9ebec0).


### Author

Lars Erik Storbukås <<larserik@storbukas.no>>
