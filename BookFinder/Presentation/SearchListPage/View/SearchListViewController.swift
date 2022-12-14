//
//  SearchListViewController.swift
//  BookFinder
//
//  Created by Hyoju Son on 2022/07/31.
//

import UIKit
import RxSwift
import RxCocoa

protocol KeyboardAndActivityIndicatorSwitchable: AnyObject {
    func hideKeyboard()
    func showActivityIndicator()
}

final class SearchListViewController: UIViewController {
    // MARK: - Nested Types
    private enum SectionKind: Int {
        case main
    }
    
    // MARK: - Properties
    private var searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.searchBar.placeholder = Text.searchBarPlaceHolder
        searchController.searchBar.setValue(
            Text.searchBarCancelButtonTitle,
            forKey: Text.searchBarCancelButtonTitleKey
        )
        return searchController
    }()
    private let backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGreen2
        return view
    }()
    private let itemCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = .preferredFont(forTextStyle: .title2)
        label.textColor = .black
        label.numberOfLines = 1
        label.text = Text.itemCountLabelDefaultText
        return label
    }()
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .lightGreen2
        return collectionView
    }()
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.style = .large
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    private var dataSource: DiffableDataSource!
    private var snapshot: NSDiffableDataSourceSnapshot<SectionKind, BookItem>!
    private var viewModel: SearchListViewModel!
    private let collectionViewDidScroll = PublishSubject<Int>()
    private let cellDidSelect = PublishSubject<BookItem>()
    private let disposeBag = DisposeBag()
    
    private typealias CellRegistration = UICollectionView.CellRegistration<BookItemCell, BookItem>
    private typealias DiffableDataSource = UICollectionViewDiffableDataSource<SectionKind, BookItem>
    private typealias SnapShot = NSDiffableDataSourceSnapshot<SectionKind, BookItem>

    // MARK: - Initializers
    convenience init(viewModel: SearchListViewModel) {
        self.init()
        self.viewModel = viewModel
        viewModel.delegate = self
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIOSVersion()
        configureUI()
        configureDataSource()
        bind()
    }

    // MARK: - Methods
    private func checkIOSVersion() {
        let versionNumbers = UIDevice.current.systemVersion.components(separatedBy: Text.dot)
        guard
            let major = versionNumbers[safe: 0],
            let minor = versionNumbers[safe: 1]
        else { return }
        let version = major + Text.dot + minor
        
        guard let systemVersion = Double(version) else { return }
        let errorVersion = 15.0..<15.4
        // estimatedHeight ?????? ??? ?????? ????????? ?????? (is stuck in its update/layout loop)??? ???????????? ???????????? ??????
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
        configureHierarchy()
        configureDataSource()
    }

    private func configureNavigationBar() {
        view.backgroundColor = .darkGreen
        navigationItem.title = Text.navigationTitle
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.lightGreen2,
            .font: UIFont.preferredFont(forTextStyle: .title1)
        ]
        navigationItem.backButtonDisplayMode = .minimal
    }

    private func configureSearchBar() {
        navigationItem.searchController = searchController
    }
    
    private func configureCollectionView() {
        collectionView.collectionViewLayout = createCollectionViewLayout()
        collectionView.delegate = self
    }
    
    private func createCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in
            let screenWidth = UIScreen.main.bounds.width
            let estimatedHeight = NSCollectionLayoutDimension.estimated(screenWidth * 0.35)
            
            let isWideMode = screenWidth > 1000
            let itemWidthRatio: CGFloat = isWideMode ? 0.5 : 1.0
            let columnCount = isWideMode ? 2 : 1
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(itemWidthRatio),
                heightDimension: estimatedHeight
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: estimatedHeight
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columnCount)
            let section = NSCollectionLayoutSection(group: group)
            
            return section
        }
        
        return layout
    }
        
    private func configureHierarchy() {
        view.addSubview(backgroundView)
        view.addSubview(itemCountLabel)
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            itemCountLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            itemCountLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 12),
            itemCountLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -12),
            collectionView.topAnchor.constraint(equalTo: itemCountLabel.bottomAnchor, constant: 12),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 12),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -12),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    private func configureDataSource() {
        let cellRegistration = CellRegistration { (cell, _, bookItem) in
            cell.setUIContents(with: bookItem)
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
            searchTextDidChanged: searchController.searchBar.searchTextField.rx.text.orEmpty.asObservable(),
            collectionViewDidScroll: collectionViewDidScroll.asObservable(),
            cellDidSelect: cellDidSelect.asObservable()
        )
        
        let output = viewModel.transform(input)
        
        configureSearchCountAndItems(with: output.searchCountAndItems)
        configureNextPageItems(with: output.nextPageItems)
    }
    
    private func configureSearchCountAndItems(with inputObservable: Observable<(Int, [BookItem])>) {
        inputObservable
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { (owner, searchCountAndItems) in
                let (searchCount, bookItems) = searchCountAndItems
                owner.setLabel(with: searchCount)
                owner.createAndApplySnapshot(with: bookItems)
                
                owner.showKeyboard()
                owner.collectionView.setContentOffset(.zero, animated: true)
                owner.hideActivityIndicator()
            })
            .disposed(by: disposeBag)
    }
      
    private func setLabel(with itemCount: Int) {
        itemCountLabel.text = "\(Text.itemCountLabelDefaultText) (\(itemCount))"
    }
    
    private func createAndApplySnapshot(with bookItems: [BookItem]) {
        if snapshot == nil {
            snapshot = SnapShot()
            snapshot.appendSections([.main])
        } else {
            let previousBookItems = snapshot.itemIdentifiers(inSection: .main)
            snapshot.deleteItems(previousBookItems)
        }
      
        snapshot.appendItems(bookItems)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
            
    private func configureNextPageItems(with inputObservable: Observable<[BookItem]>) {
        inputObservable
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { (owner, nextPageBookItems) in
                owner.appendAndApplySnapshot(with: nextPageBookItems)
                
                owner.hideActivityIndicator()
            })
            .disposed(by: disposeBag)
    }
    
    private func appendAndApplySnapshot(with bookItems: [BookItem]) {
        snapshot.appendItems(bookItems)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - CollectionView Delegate
extension SearchListViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        collectionViewDidScroll.onNext(indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedCell = collectionView.cellForItem(at: indexPath) as? BookItemCell else { return }
        let bookItem = selectedCell.retrieveBookItem()
        cellDidSelect.onNext(bookItem)
    }
}

// MARK: - Keyboard And ActivityIndicator Switchable
extension SearchListViewController: KeyboardAndActivityIndicatorSwitchable {
    private func showKeyboard() {
        searchController.searchBar.searchTextField.becomeFirstResponder()
    }
    
    func hideKeyboard() {
        searchController.searchBar.searchTextField.resignFirstResponder()
    }
    
    func showActivityIndicator() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.startAnimating()
        }
    }
    
    private func hideActivityIndicator() {
        activityIndicator.stopAnimating()
    }
}

// MARK: - NameSpaces
extension SearchListViewController {
    private enum Text {
        static let navigationTitle = "Wanted Book Finder"
        static let searchBarPlaceHolder = "??? ??????, ?????? ??????"
        static let searchBarCancelButtonTitle = "??????"
        static let searchBarCancelButtonTitleKey = "cancelButtonText"
        static let itemCountLabelDefaultText = "?????? ??????"
        static let dot = "."
        static let versionErrorTitle = "????????? iOS 15.4 ???????????? ???????????? ????????????"
        static let okAlertActionTitle = "OK"
    }
}
