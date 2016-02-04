import Foundation
import XCTest

class NetworkingIntegrationTests : XCTestCase {
    
    private var hydrogen: Hydrogen!
    
    override func setUp() {
        super.setUp()
        
        hydrogen = Hydrogen(config: NSURLSessionConfiguration.defaultSessionConfiguration(), urlRequestBuilder: URLRequestBuilder())
    }
    
    override func tearDown() {
        hydrogen.cancelAll()
        OHHTTPStubs.removeAllStubs()
        
        super.tearDown()
    }
    
    func testSuccessfulResponse() {
        stubWithResponse(OHHTTPStubsResponse(data: NSData(), statusCode: 200, headers: nil))
        
        let expectation = expectationWithDescription("")
        
        let completion: Result<String> -> Void = { result in
            switch result {
            case .Success(let value, _, let statusCode):
                XCTAssertEqual(value, "All good")
                XCTAssertEqual(statusCode!, 200)
            case .Error(_, let request):
                XCTFail("request: \(request)")
            }
            expectation.fulfill()
        }
        
        performRequest(nil, completion: completion, parsedString: "All good")
        
        self.waitForExpectationsWithTimeout(1) { error in
            
        }
    }
    
    func test404Response() {
        stubWithResponse(OHHTTPStubsResponse(data: NSData(), statusCode: 404, headers: nil))
        
        let expectation = expectationWithDescription("")
        
        let completion: Result<String> -> Void = { result in
            switch result {
            case .Success(_, let request, _):
                XCTFail("request: \(request)")
            case .Error(let error, _):
                XCTAssertEqual(error.code, 404)
            }
            expectation.fulfill()
        }
        
        performRequest(nil, completion: completion, parsedString: "not found")
        
        self.waitForExpectationsWithTimeout(1) { error in
            
        }
    }
    
    func testErrorResponse() {
        stubWithResponse(OHHTTPStubsResponse(error: NSError(domain: "ERROR!", code: 42, userInfo: nil)))
        
        let expectation = expectationWithDescription("")
        
        let completion: Result<String> -> Void = { result in
            switch result {
            case .Success(_, let request, _):
                XCTFail("request: \(request)")
            case .Error(let error, _):
                XCTAssertNotNil(error)
                XCTAssertEqual(error.code, 42)
            }
            expectation.fulfill()
        }
        
        performRequest(nil, completion: completion, parsedString: "not found")
        
        self.waitForExpectationsWithTimeout(1) { error in
            
        }
    }
    
    func testRequestCancelling() {
        stubWithResponse(OHHTTPStubsResponse(data: NSData(), statusCode: 200, headers: nil))
        
        let expectation = expectationWithDescription("")
        
        let completion: Result<String> -> Void = { result in
            switch result {
            case .Success(_, _, _):
                XCTFail("should not be called")
            case .Error(_, _):
                XCTFail("should not be called")
            }
        }
        
        let task = performRequest(nil, completion: completion, parsedString: "not found")
        task.cancel()
        
        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
        dispatch_after(delay, dispatch_get_main_queue()) {
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(1) { error in
        
        }
    }
    
    func testRequestCancellingWhenRunning() {
        let response = OHHTTPStubsResponse(data: NSData(), statusCode: 200, headers: nil).requestTime(0.2, responseTime: 0.2)
        
        stubWithResponse(response)
        
        let expectation = expectationWithDescription("")
        
        let completion: Result<String> -> Void = { result in
            switch result {
            case .Success(_, _, _):
                XCTFail("should not be called")
            case .Error(_, _):
                XCTAssertEqual(self.hydrogen.numberOfActiveTasks, 0)
            }
            expectation.fulfill()
        }
        
        let task = performRequest(nil, completion: completion, parsedString: "not found")
        
        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
        dispatch_after(delay, dispatch_get_main_queue()) {
            task.cancel()
        }
        
        self.waitForExpectationsWithTimeout(1) { error in
            
        }
    }
    
    //MARK: Helper methods
    
    private func stubWithResponse(response: OHHTTPStubsResponse) {
        OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
            return true
            }, withStubResponse: { (request) -> OHHTTPStubsResponse in
                return response
        })
    }
    
    private func performRequest(path:String?, completion: Result<String> -> Void, parsedString: String) -> Task {
        let resource = Resource<String>(
            path: path,
            method: Method.GET,
            parse: { data in
                return parsedString
            }
        )
        
        let task = hydrogen.request(
            NSURL(string: "http://httpbin.org")!,
            resource: resource,
            completion: completion
        )
        task.resume()
        
        return task
    }
    
}
