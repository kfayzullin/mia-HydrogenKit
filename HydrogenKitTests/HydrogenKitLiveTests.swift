import UIKit
import XCTest

class HydrogenKitLiveTests: XCTestCase {
    
    private var hydrogen: Hydrogen!
    
    override func setUp() {
        super.setUp()
        
        hydrogen = Hydrogen(config: nil, urlRequestBuilder: URLRequestBuilder())
    }
    
    override func tearDown() {
        hydrogen?.cancelAll()
        
        super.tearDown()
    }
    
    func testRequestWithSuccess() {
        let expectation = expectationWithDescription("Call completion with success")
        
        let completion: Result<String> -> Void = { result in
            switch result {
            case .Success(let value,  _, let statusCode):
                XCTAssertEqual(value!, "Hello World")
                XCTAssertEqual(statusCode!, 200)
                expectation.fulfill()
            case .Error(_,let request):
                XCTFail("request: \(request)")
                expectation.fulfill()
            }
        }
        
        let task = performRequest("get", completion: completion)
        task.resume()
        
        waitForExpectationsWithTimeout(5) { error in
            task.cancel()
        }
    }
    
    private func performRequest(path:String?, completion: Result<String> -> Void) -> Task {
        let resource = Resource(
            path: path,
            method: Method.GET,
            parse: { data in
                return "Hello World"
            }
        )
                
        return hydrogen!.request(
            NSURL(string: "http://httpbin.org")!,
            resource: resource,
            completion: completion
        )
    }
    
}
