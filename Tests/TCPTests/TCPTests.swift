import XCTest
@testable import EventEmitter
@testable import TCP

class TCPTests: XCTestCase {

    func testEvents() {

        let expectation = self.expectation(description: "Event")

        let event = Event<String>()

        _ = event.on { string in 
            print("Event received: \(string)")
            expectation.fulfill()
        }

        event.emit("hola")

        waitForExpectations(timeout: 1) {_ in}

    }

    
    func testClientServer() {
        
        
        let expectation = self.expectation(description: "Server")

        
        let server = Server(port: 3000)
        
        _ = server.events.clientConnected.on { client in
            print("Client connected: \(client.id)")
            guard let data = "Pasta".data(using: .utf8) else { return }
            client.send(data: data)
            _ = client.events.dataReceived.on { data in
                let string = String(data:data, encoding: .utf8)
                print("Server: Data received: \(string ?? "")")
                client.send(data: data)
                expectation.fulfill()
            }

        }
        
        server.listen()
        
        let client = Connection(host: "localhost", port: 3000)
        _ = client.events.didOpen.on {
            print("Connection did open")
            guard let data = "Hola".data(using: .utf8) else { return }
            client.send(data: data)
        }
        
        _ = client.events.dataReceived.on { data in
            let string = String(data:data, encoding: .utf8)
            print("Client: Data received: \(string ?? "")")
        }
        
        client.open {
            print("did open...")
        }
        
        waitForExpectations(timeout: 100) {_ in}

        
        
        
    }


    static var allTests = [
        ("testEvents", testEvents),
        ("testClientServer", testClientServer),
    ]
}
