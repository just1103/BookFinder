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
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 10
        let verticalInset: CGFloat = 5
        let horizontalInset: CGFloat = 12
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: verticalInset,
            leading: horizontalInset,
            bottom: verticalInset,
            trailing: horizontalInset
        )
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.backgroundColor = .background
        return stackView
    }()
    private let itemCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = .preferredFont(forTextStyle: .title2)
        label.textColor = .label
        label.numberOfLines = 1
        label.text = "검색 결과"
        return label
    }()
    private var searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.searchBar.placeholder = "책 제목, 저자 검색"
        searchController.searchBar.setValue("취소", forKey: "cancelButtonText")
//        searchController.searchBar.searchTextField.backgroundColor = .clear
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
//    private let invokedViewDidLoad = PublishSubject<Void>()
    private let searchTextDidChanged = PublishSubject<String>()
    private let collectionViewDidScroll = PublishSubject<IndexPath>()
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
        bind()
//        performQuery(with: nil)  // 초기화면에서는 아무것도 안해도 될듯
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
        configureHierarchy()
        configureDataSource()
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
        
    private func configureHierarchy() {
        collectionView.collectionViewLayout = createCollectionViewLayout()
        view.addSubview(containerStackView)
        containerStackView.addArrangedSubview(itemCountLabel)
        containerStackView.addArrangedSubview(collectionView)
        
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
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
}

// MARK: - Rx Binding Methods
extension SearchListViewController {
    private func bind() {
        let input = SearchListViewModel.Input(
            searchTextDidChanged: searchTextDidChanged,
            collectionViewDidScroll: collectionViewDidScroll,
            cellDidSelect: collectionView.rx.itemSelected.asObservable()
        )
        
        let output = viewModel.transform(input)
        
        configureSearchCountAndItems(with: output.searchCountAndItems)
//        configureNextPageItems(with: output.nextPageItems)
    }
    
    private func configureSearchCountAndItems(with inputObservable: Observable<(Int, [BookItem])>) {
        inputObservable
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { (self, searchCountAndItems) in
                let (searchCount, bookItems) = searchCountAndItems
                self.snapshot = SnapShot()
                self.snapshot.appendSections([.main])
                self.snapshot.appendItems(bookItems)
                self.dataSource.apply(self.snapshot, animatingDifferences: true)
                
                self.updateLabel(with: searchCount)
            })
            .disposed(by: disposeBag)
    }
      
    private func updateLabel(with itemCount: Int) {
        itemCountLabel.text = "검색 결과 (\(itemCount))"
    }
            
    private func configureNextPageItems(with inputObservable: Observable<[BookItem]>) {
        
    }
}

// MARK: - CollectionView Delegate
extension SearchListViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        collectionViewDidScroll.onNext(indexPath)
    }
}

// MARK: - UISearchResultsUpdating
extension SearchListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {  // x버튼이나 취소버튼을 눌렀을 때도 호출됨
        guard let searchText = searchController.searchBar.text else { return }
        
        searchTextDidChanged.onNext(searchText)
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
