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
    
    // 서버 DB 업데이트로 인해 테스트 fail 발생 가능
    func test_BookSearchAPI가_정상작동_하는지() {
        let expectation = XCTestExpectation(description: "BookSearchAPI 비동기 테스트")
        
        // URL : https://www.googleapis.com/books/v1/volumes?q=flowers
        let observable = sut.fetchData(
            api: BookFinderURL.BookSearchAPI(query: "flowers"),
            decodingType: SearchResultDTO.self
        )
        _ = observable.subscribe(onNext: { result in
            XCTAssertNotNil(result)
            XCTAssertEqual(result.kind, "books#volumes")
            XCTAssertEqual(result.totalItems, 634)
            XCTAssertEqual(result.items?[0].id, "VuVuDQAAQBAJ")
            XCTAssertEqual(result.items?[0].volumeInfo?.title, "Plants and Flowers")
            XCTAssertEqual(result.items?[0].volumeInfo?.authors, ["Alan E. Bessette", "William K. Chapman"])
            XCTAssertEqual(result.items?[0].accessInfo?.epub?.isAvailable, false)
            
            expectation.fulfill()
        })
        .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 10.0)
    }
}
