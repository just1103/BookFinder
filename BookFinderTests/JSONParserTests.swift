//
//  JSONParserTests.swift
//  BookFinderTests
//
//  Created by Hyoju Son on 2022/07/31.
//

import XCTest
@testable import BookFinder

class JSONParserTests: XCTestCase {
    func test_SearchResultDTO타입_decode했을때_Nil이_아닌지_테스트() {
        guard let path = Bundle(for: type(of: self)).path(forResource: "MockSearchResult", ofType: "json"),
              let jsonString = try? String(contentsOfFile: path) else {
            XCTFail()
            return
        }
        
        let data = jsonString.data(using: .utf8)
        guard let result = JSONParser<SearchResultDTO>().decode(from: data) else {
            XCTFail()
            return
        }
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result.kind, "books#volumes")
        XCTAssertEqual(result.totalItems, 2)
    }
    
    func test_BookItemDTO타입_decode했을때_Nil이_아닌지_테스트() {
        guard let path = Bundle(for: type(of: self)).path(forResource: "MockBookItem", ofType: "json"),
              let jsonString = try? String(contentsOfFile: path) else {
            XCTFail()
            return
        }
        
        let data = jsonString.data(using: .utf8)
        guard let result = JSONParser<BookItemDTO>().decode(from: data) else {
            XCTFail()
            return
        }
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result.id, "_oG_iTxP1pIC")
        XCTAssertEqual(result.volumeInfo?.title, "Flowers For Algernon")
        XCTAssertEqual(result.volumeInfo?.authors, ["Daniel Keyes"])
        XCTAssertEqual(result.accessInfo?.epub?.isAvailable, true)
    }
}
