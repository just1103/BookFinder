//
//  JSONParserTests.swift
//  BookFinderTests
//
//  Created by Hyoju Son on 2022/07/31.
//

import XCTest

class JSONParserTests: XCTestCase {
    func test_SearchResult타입_decode했을때_Nil이_아닌지_테스트() {
        guard let path = Bundle(for: type(of: self)).path(forResource: "MockProduct", ofType: "json"),
              let jsonString = try? String(contentsOfFile: path) else {
            XCTFail()
            return
        }
        
        let data = jsonString.data(using: .utf8)
        guard let result = JSONParser<Product>().decode(from: data) else {
            XCTFail()
            return
        }
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result.id, 15)
    }
    
//    func test_ProductPage타입_decode했을때_Nil이_아닌지_테스트() {
//        guard let path = Bundle(for: type(of: self)).path(forResource: "MockProductPage", ofType: "json"),
//              let jsonString = try? String(contentsOfFile: path) else {
//            XCTFail()
//            return
//        }
//        
//        let data = jsonString.data(using: .utf8)
//        guard let result = JSONParser<ProductPage>().decode(from: data) else {
//            XCTFail()
//            return
//        }
//        
//        XCTAssertNotNil(result)
//        XCTAssertEqual(result.pageNumber, 1)
//    }
}
