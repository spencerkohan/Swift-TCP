//
//  CNetworkingUtils.c
//  TCP
//
//  Created by Spencer Kohan on 9/18/17.
//

#include "include/CNetworkingUtils/CNetworkingUtils.h"

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <netdb.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <unistd.h>
#include <arpa/inet.h>

#define BUFSIZE 1024

void CSocketRead(int socketId, unsigned char* buffer, int maxBufferSize, int* bytesReceived) {
    if ((*bytesReceived=recv(socketId, buffer, maxBufferSize, 0)) == -1) {
        perror("recv");
    }
    buffer[*bytesReceived] = '\0';
}

void CSocketWrite(int socketId, const unsigned char* buffer, int bufferSize) {
    if (send(socketId, buffer, bufferSize, 0) == -1){
        perror("send");
    }
}

void CSocketClose(int socketId) {
    close(socketId);
}

// Clienrt handling
int CClientSocketConnectToHost(int* socketId, const char* hostName, int port) {
   
    int sockfd, numbytes;
    char buf[BUFSIZE];
    struct hostent *he;
    struct sockaddr_in their_addr; /* connector's address information */
    
    
    if ((he=gethostbyname("localhost")) == NULL) {  /* get the host info */
        herror("gethostbyname");
        return 1;
    }
    
    if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) == -1) {
        perror("socket");
        return 2;
    }
    
    their_addr.sin_family = AF_INET;      /* host byte order */
    their_addr.sin_port = htons(port);    /* short, network byte order */
    their_addr.sin_addr = *((struct in_addr *)he->h_addr);
    bzero(&(their_addr.sin_zero), 8);     /* zero the rest of the struct */
    
    if (connect(sockfd, (struct sockaddr *)&their_addr, \
                sizeof(struct sockaddr)) == -1) {
        perror("connect");
        return 3;
    }
    
    *socketId = sockfd;
    
    return 0;
    
}

// Server handling
void CServerSocketListen(int* socketId, int port) {
    
    // Implementation borrows heavily from: https://www.cs.cmu.edu/afs/cs/academic/class/15213-f99/www/class26/tcpserver.c
    
    int parentfd; /* parent socket */
    int childfd; /* child socket */
    int portno; /* port to listen on */
    int clientlen; /* byte size of client's address */
    struct sockaddr_in serveraddr; /* server's addr */
    struct hostent *hostp; /* client host info */
    char buf[BUFSIZE]; /* message buffer */
    char *hostaddrp; /* dotted decimal host addr string */
    int optval; /* flag value for setsockopt */
    int n; /* message byte size */
    
    portno = port;
    
    /*
     * socket: create the parent socket
     */
    parentfd = socket(AF_INET, SOCK_STREAM, 0);
    if (parentfd < 0) {
        perror("ERROR opening socket");
    }
    
    /* setsockopt: Handy debugging trick that lets
     * us rerun the server immediately after we kill it;
     * otherwise we have to wait about 20 secs.
     * Eliminates "ERROR on binding: Address already in use" error.
     */
    optval = 1;
    setsockopt(parentfd, SOL_SOCKET, SO_REUSEADDR,
               (const void *)&optval , sizeof(int));
    
    /*
     * build the server's Internet address
     */
    bzero((char *) &serveraddr, sizeof(serveraddr));
    
    /* this is an Internet address */
    serveraddr.sin_family = AF_INET;
    
    /* let the system figure out our IP address */
    serveraddr.sin_addr.s_addr = htonl(INADDR_ANY);
    
    /* this is the port we will listen on */
    serveraddr.sin_port = htons((unsigned short)portno);
    
    /*
     * bind: associate the parent socket with a port
     */
    if (bind(parentfd, (struct sockaddr *) &serveraddr,
             sizeof(serveraddr)) < 0) {
        perror("ERROR on binding");
    }
    
    /*
     * listen: make this socket ready to accept connection requests
     */
    if (listen(parentfd, 5) < 0) { /* allow 5 requests to queue up */
        perror("ERROR on listen");
    }
    
    *socketId = parentfd;
    
}

int CServerSocketAccept(int socketId) {
    struct sockaddr_in clientaddr; /* client addr */
    socklen_t clientlen; /* byte size of client's address */
    clientlen = sizeof(clientaddr);
    int clientSocket = accept(socketId, (struct sockaddr *) &clientaddr, &clientlen);
    return clientSocket;
}

