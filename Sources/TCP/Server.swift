//
//  Server.swift
//  TCPPackageDescription
//
//  Created by Spencer Kohan on 9/18/17.
//

import Foundation
import EventEmitter
import CNetworkingUtils

open class Server {
    
    public init(port:Int) {
        self.port = port
    }
    
    public struct Events {
        public let clientConnected = Event<Connection>()
        public let clientDisconnected = Event<Connection>()
        public let dataReceived = Event<Data>()
    }
    
    public let events = Events()
    
    open var connections = Set<Connection>()
 
    let port: Int
    var socketId : Int32 = 0
    
    let acceptQueue : DispatchQueue = DispatchQueue(label: "TCPServer:Accept")
    let readQueue : DispatchQueue = DispatchQueue(label: "TCPServer:Read")
    
    open func listen() {
        CServerSocketListen(&socketId, Int32(port))
        print("listening on port: \(port)")
        print("socket: \(socketId)")
        
        acceptQueue.async {
            while true {
                let clientSocketId = CServerSocketAccept(self.socketId)
                if clientSocketId >= 0 {
                    let socket = Socket(socketId: clientSocketId)
                    let connection = Connection(socket:socket)
                    self.connections.insert(connection)
                    self.events.clientConnected.emit(connection)
                    connection.startReading()
                }
            }
        }
    }
    
}

