//
//  NetworkProviderTests.swift
//  BookFinderTests
//
//  Created by Hyoju Son on 2022/07/31.
//

import XCTest
import RxSwift
@testable import BookFinder

class NetworkProviderTests: XCTestCase {
    var sut: NetworkProvider!
    var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = NetworkProvider()
        disposeBag = DisposeBag()
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        sut = nil
        disposeBag = nil
    }
    
    // 서버 DB 업데이트 시 테스트 fail 발생 가능
    func test_BookSearchAPI가_정상작동_하는지() {
        let expectation = XCTestExpectation(description: "BookSearchAPI 비동기 테스트")
        
        // URL : https://www.googleapis.com/books/v1/volumes?q=flowers&startIndex=0&maxResults=10
        let observable = sut.fetchData(
            api: BookFinderURL.BookSearchAPI(keywords: "flowers"),
            decodingType: SearchResultDTO.self
        )
        _ = observable.subscribe(onNext: { result in
            XCTAssertNotNil(result)
            XCTAssertEqual(result.items?.count, 10)
            
            XCTAssertEqual(result.kind, "books#volumes")
            XCTAssertEqual(result.totalItems, 623)
            XCTAssertEqual(result.items?[0].id, "VuVuDQAAQBAJ")
            XCTAssertEqual(result.items?[0].volumeInfo?.title, "Plants and Flowers")
            XCTAssertEqual(result.items?[0].volumeInfo?.authors, ["Alan E. Bessette", "William K. Chapman"])
            XCTAssertEqual(result.items?[0].accessInfo?.epub?.isAvailable, false)
            
            expectation.fulfill()
        })
        .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func test_BookSearchAPI에_2페이지_요청시_index10항목부터_전달되는지() {
        let expectation = XCTestExpectation(description: "BookSearchAPI 비동기 테스트")
        
        // URL : https://www.googleapis.com/books/v1/volumes?q=flowers&startIndex=10&maxResults=10
        let observable = sut.fetchData(
            api: BookFinderURL.BookSearchAPI(keywords: "flowers", pageNumber: 2),
            decodingType: SearchResultDTO.self
        )
        _ = observable.subscribe(onNext: { result in
            XCTAssertNotNil(result)
            XCTAssertEqual(result.items?.count, 10)

            XCTAssertEqual(result.kind, "books#volumes")
            XCTAssertEqual(result.totalItems, 1000)  // 주의 - 623이 아님 (maxResult == 10일 때 서버 데이터)
            XCTAssertEqual(result.items?[0].id, "vAlIAAAAYAAJ")
            XCTAssertEqual(result.items?[0].volumeInfo?.title, "Commercial Field Production of Cut and Dried Flowers")
            XCTAssertEqual(result.items?[0].volumeInfo?.authors, nil)
            XCTAssertEqual(result.items?[0].accessInfo?.epub?.isAvailable, false)
            
            expectation.fulfill()
        })
        .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 10.0)
    }
}
