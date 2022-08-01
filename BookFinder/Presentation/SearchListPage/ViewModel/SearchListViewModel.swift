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
        let collectionViewDidScroll: Observable<IndexPath>
        let cellDidSelect: Observable<IndexPath>
    }
    
    struct Output {
        let searchCountAndItems: Observable<(Int, [BookItem])>  // TODO: 시간 남으면 DTO 없는 Model로 전환시키기
//        let nextPageItems: Observable<[BookItem]>
    }
    
    // MARK: - Properties
    private weak var coordinator: SearchListCoordinator!
    private var initialPageNumber = 1
    private var currentProductPage: Int = 1
    private var currentProductsCount: Int = 20
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializers
    init(coordinator: SearchListCoordinator) {
        self.coordinator = coordinator
    }
    
    // MARK: - Methods
    func transform(_ input: Input) -> Output {
        let searchResult = configureSearchTextDidChangedObserver(by: input.searchTextDidChanged)
//        let nextPageBookItems = configurecollectionViewDidScrollObserver(by: input.collectionViewDidScroll)
        configureCellDidSelectObserver(by: input.cellDidSelect)
        
        let output = Output(
            searchCountAndItems: searchResult
//            nextPageItems: nextPageBookItems
        )
        
        return output
    }
    
    private func configureSearchTextDidChangedObserver(by searchText: Observable<String>) -> Observable<(Int, [BookItem])> {
        return searchText
            .withUnretained(self)
            .flatMap { (self, searchText) -> Observable<(Int, [BookItem])> in
                if searchText.isEmpty || searchText == " " {
                    self.currentProductPage = 1
                    self.currentProductsCount = 0  // 검색어를 지웠으므로 재처리
                    
                    return Observable.just((0, []))
                }
                
                return self.fetchSearchResult(with: searchText, at: self.initialPageNumber)
                    .flatMap { searchResultDTO -> Observable<(Int, [BookItem])> in
                        self.currentProductPage = 1
                        self.currentProductsCount = 20
                        
                        let itemCount = searchResultDTO.totalItems ?? 0
                        let bookItemsDTO = searchResultDTO.items ?? []
                        let bookItems = self.makeBookItems(with: bookItemsDTO)
                        
                        return Observable.just((itemCount, bookItems))
                    }
            }
    }
    
    private func fetchSearchResult(with searchText: String, at pageNumber: Int) -> Observable<SearchResultDTO> {
        let searchResult = NetworkProvider().fetchData(
            api: BookFinderURL.BookSearchAPI(searchText: searchText, pageNumber: pageNumber),
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
                publishedDate: item.volumeInfo?.publishedDate,
                averageRating: item.volumeInfo?.averageRating,
                ratingsCount: item.volumeInfo?.ratingsCount,
                smallThumbnailURL: item.volumeInfo?.imageLinks?.smallThumbnail
            )
        }
        
        return bookItems
    }
    
//    private func configurecollectionViewDidScrollObserver(by inputObservable: Observable<IndexPath>) -> Observable<[BookItem]> {
    //    self.currentProductPage = 1    // TODO: Page +1
    //    self.currentProductsCount = 20
    
    
//        return inputObservable
//            .filter { [weak self] indexPath in
//                return indexPath.row + 4 == self?.currentProductsCount
//            }
//            .flatMap { [weak self] _ -> Observable<[BookItem]> in
//                guard let self = self else { return Observable.just([]) }
//                self.currentProductPage += 1
//                self.currentProductsCount += 20
//                return self.fetchProducts(at: self.currentProductPage, with: 20).map { productPage -> [UniqueProduct] in
//                    return self.makeHashable(from: productPage.products)
//                }
//            }
//    }
    
    private func configureCellDidSelectObserver(by inputObservable: Observable<IndexPath>) {
        inputObservable
            .withUnretained(self)
            .subscribe(onNext: { (self, productID) in
//                self?.coordinator.showBookItemDetail(productID)  // TODO: ID 또는 indexPath 활용
            })
            .disposed(by: disposeBag)
    }
}
