//
//  Socket.swift
//  TCP
//
//  Created by Spencer Kohan on 9/18/17.
//

import Foundation
import CNetworkingUtils
import EventEmitter

public class Socket {
    
    let connectQueue = DispatchQueue(label: "TCPSocket:Connect")
    var socketId : Int32 = 0
    
    let host: String
    let port: Int
    
    init(host:String, port:Int) {
        self.host = host
        self.port = port
    }
    
    init(socketId: Int32) {
        self.host = ""
        self.port = 0
        self.socketId = socketId
    }
    
    func connect(onFinish: @escaping ()->()) {
        print("connecting...")
        connectQueue.async {
            print("Connecting to host")
            CClientSocketConnectToHost(&self.socketId, self.host, Int32(self.port))
            print("Socket id: \(self.socketId)")
            onFinish()
        }
    }
    
    func disconnect() {
        CSocketClose(socketId)
    }
    
    func read() -> Data? {
        let maxDataSize: Int = 1024
        var bytesReceived : Int32 = 0
        var buffer : [Int8] = (0..<maxDataSize).map { _ in
            return 0
        }
        CSocketRead(socketId, &buffer, Int32(maxDataSize), &bytesReceived)
        if bytesReceived > 0 {
            let subBuffer = buffer[0..<Int(bytesReceived)]
            let data = Data(bytes: subBuffer.map {
                return UInt8(exactly: $0) ?? 0
            })
            return data
        }
        return nil
    }
    
    func write(_ data: inout Data) {
        let buffer : [Int8] = data.map { return Int8(exactly:$0) ?? 0 }
        CSocketWrite(socketId, buffer, Int32(data.count))
    }
    
}
