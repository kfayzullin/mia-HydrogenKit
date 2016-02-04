import Foundation
import XCTest

class MethodTests: XCTestCase {

    func testRequestMethodString() {
        XCTAssertEqual(Method.GET.requestMethod(), "GET")
        XCTAssertEqual(Method.POST(NSData()).requestMethod(), "POST")
        XCTAssertEqual(Method.PUT(NSData()).requestMethod(), "PUT")
        XCTAssertEqual(Method.DELETE.requestMethod(), "DELETE")
    }
    
    func testRequestMethodBody() {
        XCTAssertNil(Method.GET.requestBody())
        XCTAssertNotNil(Method.POST(NSData()).requestBody())
        XCTAssertNotNil(Method.PUT(NSData()).requestBody())
        XCTAssertNil(Method.DELETE.requestBody())
    }

}
