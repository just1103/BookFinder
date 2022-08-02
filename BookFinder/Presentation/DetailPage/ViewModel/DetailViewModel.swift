//
//  DetailViewModel.swift
//  BookFinder
//
//  Created by Hyoju Son on 2022/08/02.
//

import Foundation
import RxSwift

final class DetailViewModel {
    // MARK: - Nested Types
    struct Input {
        let leftBarButtonDidTap: Observable<Void>
    }
    
    struct Output {
        let bookItem: Observable<BookItem>
    }
    
    // MARK: - Properties
    private weak var coordinator: DetailCoordinator!
    private let bookItem: BookItem!
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializers
    init(coordinator: DetailCoordinator, bookItem: BookItem) {
        self.coordinator = coordinator
        self.bookItem = bookItem
    }
    
    deinit {
        coordinator.finish()  
    }
    
    // MARK: - Methods
    func transform(_ input: Input) -> Output {
        let bookItem = configureBookItem()
        configureLeftBarButtonDidTapObserver(by: input.leftBarButtonDidTap)
        
        let output = Output(bookItem: bookItem)
        
        return output
    }
                            
    private func configureBookItem() -> Observable<BookItem> {
        return Observable.just(bookItem)
    }
    
    private func configureLeftBarButtonDidTapObserver(by inputObservable: Observable<Void>) {
        inputObservable
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.coordinator.popCurrentPage()
            })
            .disposed(by: disposeBag)
    }
}
