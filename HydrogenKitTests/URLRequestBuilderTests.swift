import Foundation
import XCTest


class URLRequestBuilderTests: XCTestCase {
    
    func testSimpleGETResource() {
        
        let method = Method.GET
        let parseSuccess: NSData? -> String? = { data in
            return "All good"
        }

        let resource = Resource(path: nil, method: method, params: nil, parse: parseSuccess)
        
        let requestBuilder = URLRequestBuilder()
        let urlString = "http://www.google.de"
        let request = requestBuilder.createURLRequestFromResource(NSURL(string: urlString)!, resource: resource, modifyRequest: nil)!
        
        XCTAssertEqual(request.URL!.absoluteString, urlString)
        XCTAssertEqual(request.HTTPMethod!, "GET")
        XCTAssertNil(request.HTTPBody)
    }
    
    func testSimplePOSTResource() {
        
        let method = Method.POST(NSData())
        let parseSuccess: NSData? -> String? = { data in
            return "All good"
        }

        let resource = Resource(path: nil, method: method, params: nil, parse: parseSuccess)
        
        let requestBuilder = URLRequestBuilder()
        let urlString = "http://www.google.de"
        let request = requestBuilder.createURLRequestFromResource(NSURL(string: urlString)!, resource: resource, modifyRequest: nil)!
        
        XCTAssertEqual(request.URL!.absoluteString, urlString)
        XCTAssertEqual(request.HTTPMethod!, "POST")
        XCTAssertNotNil(request.HTTPBody)
    }
    
    func testSimplePUTResource() {
        
        let method = Method.PUT(NSData())
        let parseSuccess: NSData? -> String? = { data in
            return "All good"
        }

        let resource = Resource(path: nil, method: method, params: nil, parse: parseSuccess)
        
        let requestBuilder = URLRequestBuilder()
        let urlString = "http://www.google.de"
        let request = requestBuilder.createURLRequestFromResource(NSURL(string: urlString)!, resource: resource, modifyRequest: nil)!
        
        XCTAssertEqual(request.URL!.absoluteString, urlString)
        XCTAssertEqual(request.HTTPMethod!, "PUT")
        XCTAssertNotNil(request.HTTPBody)
    }
    
    func testResourceWithParameters() {
        
        let method = Method.GET
        let parseSuccess: NSData? -> String? = { data in
            return "All good"
        }

        let resource = Resource(path: nil, method: method, params: ["hello":"world"], parse: parseSuccess)
        
        let requestBuilder = URLRequestBuilder()
        let urlString = "http://www.google.de"
        let request = requestBuilder.createURLRequestFromResource(NSURL(string: urlString)!, resource: resource, modifyRequest: nil)!
        
        XCTAssertEqual(request.URL!.absoluteString, "\(urlString)?hello=world")
        XCTAssertEqual(request.HTTPMethod!, "GET", "Methode should be GET")
        XCTAssertNil(request.HTTPBody)
    }
    
    func testResourceWithMoreParameters() {
        
        let method = Method.GET
        let parseSuccess: NSData? -> String? = { data in
            return "All good"
        }

        let resource = Resource(path: nil, method: method, params: ["hello":"world","hell":"world","hel":"world","he":"world","h":"world"], parse: parseSuccess)
        
        let requestBuilder = URLRequestBuilder()
        let urlString = "http://www.google.de"
        let request = requestBuilder.createURLRequestFromResource(NSURL(string: urlString)!, resource: resource, modifyRequest: nil)!
        
        XCTAssertEqual(request.URL!.absoluteString, "\(urlString)?h=world&he=world&hel=world&hell=world&hello=world")
        XCTAssertEqual(request.HTTPMethod!, "GET")
        XCTAssertNil(request.HTTPBody)
    }
    
    func testResourceWithHeaders() {
        
        let parseSuccess: NSData? -> String? = { data in
            return "All good"
        }

        let headers = ["content-type":"json"]
        let resource = Resource(path: nil, method: .GET, params: nil, pathReplacements: nil, headers: headers, parse: parseSuccess)
        
        let requestBuilder = URLRequestBuilder()
        let urlString = "http://www.google.de"
        let request = requestBuilder.createURLRequestFromResource(NSURL(string: urlString)!, resource: resource, modifyRequest: nil)!
        
        XCTAssertEqual(request.URL!.absoluteString, urlString)
        XCTAssertEqual(request.HTTPMethod!, "GET")
        XCTAssertNil(request.HTTPBody)
    }
    
    func testResourceWithURLReplacements() {
        
        let parseSuccess: NSData? -> String? = { data in
            return "All good"
        }
        
        let replacements = [":id":"1234",":test":"wuuuus"]
        let resource = Resource(path: "/:id/:test", method: .GET, params: nil, pathReplacements: replacements, headers: nil, parse: parseSuccess)
        
        let requestBuilder = URLRequestBuilder()
        let urlString = "http://www.google.de"
        let request = requestBuilder.createURLRequestFromResource(NSURL(string: urlString)!, resource: resource, modifyRequest: nil)!
        
        XCTAssertEqual(request.URL!.absoluteString, "\(urlString)/1234/wuuuus")
        XCTAssertEqual(request.HTTPMethod!, "GET")
        XCTAssertNil(request.HTTPBody)
    }
    
    func testResourceWithPathAndNoReplacements() {
        
        let parseSuccess: NSData? -> String? = { data in
            return "All good"
        }
        
        let resource = Resource(path: "get", method: .GET, params: nil, pathReplacements: nil, headers: nil, parse: parseSuccess)
        
        let requestBuilder = URLRequestBuilder()
        let urlString = "http://httpbin.org"
        let request = requestBuilder.createURLRequestFromResource(NSURL(string: urlString)!, resource: resource, modifyRequest: nil)!
        
        XCTAssertEqual(request.URL!.absoluteString, "\(urlString)/get")
    }
    
    func testResourceWithEncodedPath() {
        let parseSuccess: NSData? -> String? = { data in
            return "All good"
        }
        
        let resource = Resource(path: "get/&/:/?/#/test=#/[=]", method: .GET, params: nil, pathReplacements: nil, headers: nil, parse: parseSuccess)
        
        let requestBuilder = URLRequestBuilder()
        let urlString = "http://httpbin.org"
        let request = requestBuilder.createURLRequestFromResource(NSURL(string: urlString)!, resource: resource, modifyRequest: nil)!
        
        XCTAssertEqual(request.URL!.absoluteString, "\(urlString)/get/&/:/%3F/%23/test=%23/%5B=%5D")
    }
}