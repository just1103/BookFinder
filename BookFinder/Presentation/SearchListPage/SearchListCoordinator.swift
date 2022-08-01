//
//  SearchCoordinator.swift
//  BookFinder
//
//  Created by Hyoju Son on 2022/07/31.
//

import UIKit

final class SearchListCoordinator: CoordinatorProtocol {
    // MARK: - Properties
    var navigationController: UINavigationController?
    var childCoordinators = [CoordinatorProtocol]()
    var type: CoordinatorType = .searchList
    
    // MARK: - Initializers
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Methods
    func start() {
        showSearchListPage()
    }
    
//    func finish() {}
    
    private func showSearchListPage() {
        guard let navigationController = navigationController else { return }
        let searchListViewModel = SearchListViewModel(coordinator: self)
        let searchListViewController = SearchListViewController(viewModel: searchListViewModel)
        
        navigationController.pushViewController(searchListViewController, animated: false)
    }
}
