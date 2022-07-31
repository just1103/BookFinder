//
//  MockNetworkProviderTests.swift
//  BookFinderTests
//
//  Created by Hyoju Son on 2022/07/31.
//

import XCTest
import RxSwift
@testable import BookFinder

class MockNetworkProviderTests: XCTestCase {
    let mockSession: URLSessionProtocol! = MockURLSession()
    var sut: NetworkProvider!
    var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = NetworkProvider(session: mockSession)
        disposeBag = DisposeBag()
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        sut = nil
        disposeBag = nil
    }
    
    func test_fetchData가_정상작동_하는지() {
        let expectation = XCTestExpectation(description: "fetchData 비동기 테스트")
        
        let observable = sut.fetchData(
            api: BookFinderURL.BookSearchAPI(query: "flowers"),
            decodingType: SearchResultDTO.self
        )
        _ = observable.subscribe(onNext: { result in
            XCTAssertNotNil(result)
            XCTAssertEqual(result.kind, "books#volumes")
            XCTAssertEqual(result.totalItems, 2)
            expectation.fulfill()
        })
        .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 10.0)
    }
}
