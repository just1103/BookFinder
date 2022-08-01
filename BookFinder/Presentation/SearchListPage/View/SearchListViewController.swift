//
//  SearchListViewController.swift
//  BookFinder
//
//  Created by Hyoju Son on 2022/07/31.
//

import UIKit
import RxSwift
import RxCocoa

final class SearchListViewController: UIViewController {
    // MARK: - Nested Types
    private enum SectionKind: Int {
        case main
    }
    
    // MARK: - Properties
//    private let containerStackView: UIStackView = {
//        let stackView = UIStackView()
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        stackView.axis = .vertical
//        stackView.alignment = .fill
//        stackView.distribution = .fill
//        stackView.spacing = 10
//        let verticalInset: CGFloat = 5
//        let horizontalInset: CGFloat = 12
//        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(
//            top: verticalInset,
//            leading: horizontalInset,
//            bottom: verticalInset,
//            trailing: horizontalInset
//        )
//        stackView.isLayoutMarginsRelativeArrangement = true
//        return stackView
//    }()
    private var searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.searchBar.placeholder = "책 제목, 저자 검색"
//        searchController.hidesNavigationBarDuringPresentation = true
//        searchController.automaticallyShowsCancelButton = true
        return searchController
    }()
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .background
        return collectionView
    }()
    private var dataSource: DiffableDataSource!
    private var snapshot: NSDiffableDataSourceSnapshot<SectionKind, BookItem>!
    
    private var viewModel: SearchListViewModel!
    private let invokedViewDidLoad = PublishSubject<Void>()
    private let cellDidScroll = PublishSubject<IndexPath>()
    private let disposeBag = DisposeBag()
    
    private typealias CellRegistration = UICollectionView.CellRegistration<BookItemCell, BookItem>
    private typealias DiffableDataSource = UICollectionViewDiffableDataSource<SectionKind, BookItem>
    private typealias SnapShot = NSDiffableDataSourceSnapshot<SectionKind, BookItem>

    // MARK: - Initializers
    convenience init(viewModel: SearchListViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIOSVersion()
        configureUI()
        configureDataSource()
        performQuery(with: nil)
    }

    // MARK: - Methods
    private func checkIOSVersion() {
        let versionNumbers = UIDevice.current.systemVersion.components(separatedBy: ".")
        let major = versionNumbers[0]
        let minor = versionNumbers[1]
        let version = major + "." + minor
        
        guard let systemVersion = Double(version) else { return }
        let errorVersion = 15.0..<15.4
        // 해당 버전만 is stuck in its update/layout loop. 에러가 발생하여 Alert로 업데이트 권고
        if  errorVersion ~= systemVersion {
            showErrorVersionAlert()
        }
    }
    
    private func showErrorVersionAlert() {
        let okAlertAction = UIAlertAction(title: Text.okAlertActionTitle, style: .default)
        let alert = AlertFactory().createAlert(title: Text.versionErrorTitle, actions: okAlertAction)
        present(alert, animated: true)
    }
    
    private func configureUI() {
        configureNavigationBar()
        configureSearchBar()
        configureCollectionView()
    }

    private func configureNavigationBar() {
        view.backgroundColor = .darkGreen
        navigationItem.title = Text.navigationTitle
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.background,
            .font: UIFont.preferredFont(forTextStyle: .title1)
        ]
        navigationItem.backButtonDisplayMode = .minimal
//        navigationItem.hidesSearchBarWhenScrolling = true
    }

    private func configureSearchBar() {
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
    }
    
    private func configureCollectionView() {
        collectionView.collectionViewLayout = createCollectionViewLayout()
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func createCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in
            let screenWidth = UIScreen.main.bounds.width
            let estimatedHeight = NSCollectionLayoutDimension.estimated(screenWidth * 0.3)
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: estimatedHeight)
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: estimatedHeight)
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 1)
            let section = NSCollectionLayoutSection(group: group)
            
            return section
        }
        return layout
    }
    
    private func configureDataSource() {
        let cellRegistration = CellRegistration { (cell, indexPath, bookItem) in
            cell.apply(bookItem: bookItem)
        }
        
        dataSource = DiffableDataSource(collectionView: collectionView) { collectionView, indexPath, bookItem in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: bookItem)
        }
    }
    
    // TODO: initial snapshot을 따로 그려야할까? 아니지 검색입력값이 없으니까
    private func performQuery(with searchText: String?) {
        guard let searchText = searchText else { return }
        // TODO: 데이터 새로 받고, 새로운 snapshot 적용
        
        snapshot = SnapShot()
        snapshot.appendSections([.main])
        snapshot.appendItems([BookItem(id: "123", title: "제목", authors: ["저자"], publisher: "123", publishedDate: "2022", volumeDescription: "123", pageCount: 1, categories: ["123"], averageRating: 3.7, ratingsCount: 20, language: "123", smallThumbnailURL: "http://books.google.com/books/content?id=vAlIAAAAYAAJ&printsec=frontcover&img=1&zoom=5&source=gbs_api", thumbnailURL: "123", isEbookAvailable: true, istextToSpeechAvailable: true)])
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension SearchListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        performQuery(with: searchText)  
    }
}

// MARK: - NameSpaces
extension SearchListViewController {
    private enum Text {
        static let navigationTitle = "Wanted Book Finder"
        static let versionErrorTitle = "기기를 iOS 15.4 이상으로 업데이트 해주세요"
        static let okAlertActionTitle = "OK"
    }
    
    private enum Design {
        static let listRefreshButtonTitleFont: UIFont = .preferredFont(forTextStyle: .body)
    }
}
