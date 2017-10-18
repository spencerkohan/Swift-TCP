//
//  Connection.swift
//  TCPPackageDescription
//
//  Created by Spencer Kohan on 9/18/17.
//

import Foundation
import EventEmitter

open class Connection : Hashable {
    
    open var hashValue: Int {
        return id.hashValue
    }
    
    public lazy var id = UUID().uuidString
    
    public static func == (lhs: Connection, rhs: Connection) -> Bool {
        return lhs.id == rhs.id
    }
    
    let socket : Socket
    
    public struct Events {
        public let dataReceived = Event<Data>()
        public let didOpen = Event<Void>()
        public let didClose = Event<Void>()
    }
    
    public let events = Events()
    
    let readQueue : DispatchQueue = DispatchQueue(label: "TCPConnection:Read")
    let sendQueue : DispatchQueue = DispatchQueue(label: "TCPConnection:Send")
    
    public init(host:String, port:Int) {
        socket = Socket(host:host, port:port)
    }
    
    init(socket: Socket) {
        self.socket = socket
    }
    
    public func open(onOpen:@escaping ()->()) {
        socket.connect {
            self.events.didOpen.emit(())
            onOpen()
            self.startReading()
        }
    }
    
    public func startReading() {
        self.readQueue.async {
            while true {
                guard let data = self.socket.read() else { continue }
                self.events.dataReceived.emit(data)
                // emit data event
            }
        }
    }
    
    public func send(data: Data) {
        sendQueue.async {
            var d = data
            self.socket.write(&d)
        }
    }
    
    public func close() {
        socket.disconnect()
        events.didClose.emit(())
    }
    
    
}
