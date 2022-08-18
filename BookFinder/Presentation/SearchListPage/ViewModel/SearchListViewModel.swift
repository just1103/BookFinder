//
//  SearchListViewModel.swift
//  BookFinder
//
//  Created by Hyoju Son on 2022/07/31.
//

import Foundation
import RxSwift

final class SearchListViewModel: ViewModelProtocol {
    // MARK: - Nested Types
    struct Input {
        let searchTextDidChanged: Observable<String>
        let collectionViewDidScroll: Observable<Int>
        let cellDidSelect: Observable<BookItem>
    }
    
    struct Output {
        let searchCountAndItems: Observable<(Int, [BookItem])>
        let nextPageItems: Observable<[BookItem]>
    }
    
    // MARK: - Properties
    weak var delegate: KeyboardAndActivityIndicatorSwitchable!
    private weak var coordinator: SearchListCoordinator!
    private let itemPerPage = 20
    private var currentPageNumber = 1
    private var currentItemCountOnList = 0
    private var currentSearchText = Text.emptyString
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializers
    init(coordinator: SearchListCoordinator) {
        self.coordinator = coordinator
    }
    
    // MARK: - Methods
    func transform(_ input: Input) -> Output {
        let searchCountAndItems = configureSearchTextDidChangedObserver(by: input.searchTextDidChanged)
        let nextPageItems = configureCollectionViewDidScrollObserver(by: input.collectionViewDidScroll)
        configureCellDidSelectObserver(by: input.cellDidSelect)
        
        let output = Output(
            searchCountAndItems: searchCountAndItems,
            nextPageItems: nextPageItems
        )
        
        return output
    }
    
    private func configureSearchTextDidChangedObserver(
        by searchText: Observable<String>
    ) -> Observable<(Int, [BookItem])> {
        return searchText
            .distinctUntilChanged()
            .debounce(.milliseconds(600), scheduler: ConcurrentDispatchQueueScheduler.init(qos: .default)) 
            .withUnretained(self)
            .flatMap { (owner, searchText) -> Observable<(Int, [BookItem])> in
                if owner.isEmptyOrWhiteSpace(searchText) {
                    owner.currentSearchText = Text.emptyString
                    owner.currentPageNumber = 1
                    owner.currentItemCountOnList = 0

                    return Observable.just((0, []))
                }
  
                // FIXME: 스크롤 내리면서 동시에 입력값을 지우면 (x 버튼), 목록이 남아있는 버그 발생
                owner.currentSearchText = searchText
                owner.currentPageNumber = 1
                
                return owner.fetchSearchResult(with: searchText, at: owner.currentPageNumber)
                    .map { searchResultDTO -> (Int, [BookItem]) in
                        owner.delegate.showActivityIndicator()
                        
                        let itemCount = searchResultDTO.totalItems ?? 0
                        let bookItemsDTO = searchResultDTO.items ?? []
                        let bookItems = owner.makeBookItems(with: bookItemsDTO)
                        
                        if itemCount >= owner.itemPerPage {
                            owner.currentItemCountOnList = owner.itemPerPage
                        } else {
                            owner.currentItemCountOnList = itemCount  // 검색결과 개수를 반영
                        }
                        
                        return (itemCount, bookItems)
                    }
            }
    }
    
    private func isEmptyOrWhiteSpace(_ text: String) -> Bool {
        let textWithoutSpace = text.replacingOccurrences(of: Text.whiteSpace, with: Text.emptyString)
        return textWithoutSpace.isEmpty
    }
    
    private func fetchSearchResult(with searchText: String, at pageNumber: Int) -> Observable<SearchResultDTO> {
        let searchResult = NetworkProvider().fetchData(
            api: BookFinderURL.BookSearchAPI(
                searchText: searchText,
                pageNumber: pageNumber,
                itemPerPage: self.itemPerPage
            ),
            decodingType: SearchResultDTO.self
        )
        
        return searchResult
    }
    
    private func makeBookItems(with bookItemsDTO: [BookItemDTO]) -> [BookItem] {
        let bookItems = bookItemsDTO.map { item in
            BookItem.convert(bookItemDTO: item)
        }
        
        return bookItems
    }
    
    private func configureCollectionViewDidScrollObserver(
        by inputObservable: Observable<Int>
    ) -> Observable<[BookItem]> {
        return inputObservable
            .withUnretained(self)
            .filter { (owner, row) in
                let itemCountOnScreen = 5  // FIXME: 검색결과가 5개 이하에서는 스크롤해도 키보드 안내려감, iPad에서는 입력값 수정하자마자 키보드가 내려감
                if row > itemCountOnScreen {
                    owner.delegate.hideKeyboard()
                }
                
                return row + 4 == owner.currentItemCountOnList
            }
            .flatMap { (owner, _) -> Observable<[BookItem]> in
                owner.delegate.showActivityIndicator()
                owner.delegate.hideKeyboard()
                
                owner.currentPageNumber += 1
                
                return owner.fetchSearchResult(with: owner.currentSearchText, at: owner.currentPageNumber)
                    .map { searchResultDTO -> [BookItem] in
                        let bookItems = owner.makeBookItems(with: searchResultDTO.items ?? [])
                        
                        if bookItems.count == owner.itemPerPage {
                            owner.currentItemCountOnList += owner.itemPerPage
                        } else {
                            owner.currentItemCountOnList += bookItems.count  // 검색결과 개수를 반영
                        }
                        
                        return bookItems
                    }
            }
    }
    
    private func configureCellDidSelectObserver(by inputObservable: Observable<BookItem>) {
        inputObservable
            .withUnretained(self)
            .subscribe(onNext: { (owner, bookItem) in
                owner.coordinator.showDetailPage(with: bookItem)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - NameSpaces
extension SearchListViewModel {
    private enum Text {
        static let emptyString: String = ""
        static let whiteSpace: String = " "
    }
}
