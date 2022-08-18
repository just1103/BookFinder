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
    weak var delegate: ActivityIndicatorSwitchDelegate!
    private weak var coordinator: SearchListCoordinator!
    private let initialPageNumber = 1
    private let itemPerPage = 20
    private var currentPageNumber: Int = 1
    private var currentItemCount: Int = 0
    private var currentSearchText: String = Text.emptyString
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
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)  // TODO: main 스레드 아니어도 가능
            .withUnretained(self)
            .flatMap { (self, searchText) -> Observable<(Int, [BookItem])> in
                if self.isEmptyOrSpace(searchText) {
                    self.currentSearchText = Text.emptyString
                    self.currentPageNumber = 1
                    self.currentItemCount = 0

                    return Observable.just((0, []))
                }
                
                return self.fetchSearchResult(with: searchText, at: self.initialPageNumber)
                    .map { searchResultDTO -> (Int, [BookItem]) in
                        self.delegate.showActivityIndicator()
                        
                        self.currentSearchText = searchText
                        self.currentPageNumber = 1
                        self.currentItemCount = self.itemPerPage * self.currentPageNumber
                        
                        let itemCount = searchResultDTO.totalItems ?? 0
                        let bookItemsDTO = searchResultDTO.items ?? []
                        let bookItems = self.makeBookItems(with: bookItemsDTO)
                        
                        return (itemCount, bookItems)
                    }
            }
    }
    
    private func isEmptyOrSpace(_ text: String) -> Bool {
        let textWithoutSpace = text.replacingOccurrences(of: Text.space, with: Text.emptyString)
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
            .filter { (self, row) in
                return row + 4 == self.currentItemCount
            }
            .flatMap { (self, _) -> Observable<[BookItem]> in
                self.delegate.showActivityIndicator()
                
                self.currentPageNumber += 1
                self.currentItemCount = self.itemPerPage * self.currentPageNumber
                
                return self.fetchSearchResult(with: self.currentSearchText, at: self.currentPageNumber)
                    .map { searchResultDTO -> [BookItem] in
                        let bookItems = self.makeBookItems(with: searchResultDTO.items ?? [])
                        
                        return bookItems
                    }
            }
    }
    
    private func configureCellDidSelectObserver(by inputObservable: Observable<BookItem>) {
        inputObservable
            .withUnretained(self)
            .subscribe(onNext: { (self, bookItem) in
                self.coordinator.showDetailPage(with: bookItem)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - NameSpaces
extension SearchListViewModel {
    private enum Text {
        static let emptyString: String = ""
        static let space: String = " "
    }
}
