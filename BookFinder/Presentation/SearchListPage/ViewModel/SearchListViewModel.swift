//
//  SearchListViewModel.swift
//  BookFinder
//
//  Created by Hyoju Son on 2022/07/31.
//

import Foundation
import RxSwift

final class SearchListViewModel {
    // MARK: - Nested Types
    struct Input {
        let invokedViewDidLoad: Observable<Void>
        let cellDidScroll: Observable<IndexPath>
        let cellDidSelect: Observable<Int>
    }
    
    struct Output {
        let bookItems: Observable<([BookItem])>
        let nextPageBookItems: Observable<[BookItem]>
    }
    
    // MARK: - Properties
    private weak var coordinator: SearchListCoordinator!
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializers
    init(coordinator: SearchListCoordinator) {
        self.coordinator = coordinator
    }
}
