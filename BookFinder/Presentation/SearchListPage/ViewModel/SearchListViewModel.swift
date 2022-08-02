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
//        let invokedViewDidLoad: Observable<Void>
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
    private var currentSearchText: String = ""
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializers
    init(coordinator: SearchListCoordinator) {
        self.coordinator = coordinator
    }
    
    // MARK: - Methods
    func transform(_ input: Input) -> Output {
        // TODO: 메서드 이름이 반환값과 매치되도록 수정
        let searchResult = configureSearchTextDidChangedObserver(by: input.searchTextDidChanged)
        let nextPageItems = configureCollectionViewDidScrollObserver(by: input.collectionViewDidScroll)
        configureCellDidSelectObserver(by: input.cellDidSelect)
        
        let output = Output(
            searchCountAndItems: searchResult,
            nextPageItems: nextPageItems
        )
        
        return output
    }
    
    // FIXME: 가끔 searchText가 onNext로 전달되어도 flatMap이 실행되지 않는 문제 발생 (ex. 탭이 입력)
    private func configureSearchTextDidChangedObserver(by searchText: Observable<String>) -> Observable<(Int, [BookItem])> {
        return searchText
            .withUnretained(self)
            .filter { (self, searchText) in
                self.currentSearchText != searchText
            }
            .flatMap { (self, searchText) -> Observable<(Int, [BookItem])> in
                if searchText.isEmpty || searchText == " " {
                    self.currentSearchText = ""
                    self.currentPageNumber = 1
                    self.currentItemCount = 0

                    return Observable.just((0, []))  // 여기서 stream이 끊기는건가?
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
            BookItem(
                id: item.id,
                title: item.volumeInfo?.title,
                authors: item.volumeInfo?.authors,
                publisher: item.volumeInfo?.publisher,
                publishedDate: item.volumeInfo?.publishedDate,
                averageRating: item.volumeInfo?.averageRating,
                ratingsCount: item.volumeInfo?.ratingsCount,
                smallThumbnailURL: item.volumeInfo?.imageLinks?.smallThumbnail,
                smallImageURL: item.volumeInfo?.imageLinks?.small,
                description: item.volumeInfo?.volumeDescription
            )
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
            .flatMap { _ -> Observable<[BookItem]> in
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
