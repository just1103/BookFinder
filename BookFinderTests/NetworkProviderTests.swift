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
    
    func test_BookSearchAPI가_정상작동_하는지() {
        let expectation = XCTestExpectation(description: "BookSearchAPI 비동기 테스트")
        
        let observable = sut.fetchData(
            api: BookFinderURL.BookSearchAPI(searchText: "flowers"),
            decodingType: SearchResultDTO.self
        )
        _ = observable.subscribe(onNext: { result in
            XCTAssertNotNil(result)
            XCTAssertEqual(result.items?.count, 20)
            
            XCTAssertEqual(result.kind, "books#volumes")
            XCTAssertEqual(result.items?[0].id, "VuVuDQAAQBAJ")
            XCTAssertEqual(result.items?[0].volumeInfo?.title, "Plants and Flowers")
            XCTAssertEqual(result.items?[0].volumeInfo?.authors, ["Alan E. Bessette", "William K. Chapman"])
            XCTAssertEqual(result.items?[0].accessInfo?.epub?.isAvailable, false)
            
            expectation.fulfill()
        })
        .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func test_BookSearchAPI에_2페이지_요청시_index20항목부터_전달되는지() {
        let expectation = XCTestExpectation(description: "BookSearchAPI 비동기 테스트")
        
        let observable = sut.fetchData(
            api: BookFinderURL.BookSearchAPI(searchText: "flowers", pageNumber: 2),
            decodingType: SearchResultDTO.self
        )
        _ = observable.subscribe(onNext: { result in
            XCTAssertNotNil(result)
            XCTAssertEqual(result.items?.count, 20)

            XCTAssertEqual(result.kind, "books#volumes")
            XCTAssertEqual(result.items?[0].id, "8LIifmGfMc4C")
            XCTAssertEqual(result.items?[0].volumeInfo?.title, "Tropical Flowers of the World Coloring Book")
            XCTAssertEqual(result.items?[0].volumeInfo?.authors, ["Lynda E. Chandler"])
            XCTAssertEqual(result.items?[0].accessInfo?.epub?.isAvailable, false)
            
            expectation.fulfill()
        })
        .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 10.0)
    }
}
