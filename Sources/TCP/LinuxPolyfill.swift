//
//  LinuxPolyfill.swift
//  TCPPackageDescription
//
//  Created by Spencer Kohan on 9/20/17.
//

import Foundation

// TODO: move this to a separate module
public class LinuxDispatchQueue {
    
    let opQueue : OperationQueue = OperationQueue()
    
    public init(label: String) {
        print("creating queue: \(label)")
        opQueue.name = label
    }
    
    public func async(execute work: @escaping () -> Swift.Void) {
        print("executing async...")
        opQueue.addOperation(work)
    }
    
    
}

#if os(Linux)
    
    public typealias DispatchQueue = LinuxDispatchQueue
    
    
#endif
