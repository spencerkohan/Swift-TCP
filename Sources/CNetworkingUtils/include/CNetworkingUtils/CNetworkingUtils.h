//
//  CNetworkingUtils.h
//  TCP
//
//  Created by Spencer Kohan on 9/18/17.
//

#ifndef CNetworkingUtils_h
#define CNetworkingUtils_h

void CSocketRead(int socketId, unsigned char* buffer, int maxBufferSize, int* bytesReceived);
void CSocketWrite(int socketId, const unsigned char* buffer, int bufferSize);
void CSocketClose(int socketId);

// Clienrt handling
int CClientSocketConnectToHost(int* socketId, const char* hostName, int port);

// Server handling
void CServerSocketListen(int* socketId, int port);
int CServerSocketAccept(int socketId);

#endif /* CNetworkingUtils_h */
