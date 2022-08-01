//
//  AppCoordinator.swift
//  BookFinder
//
//  Created by Hyoju Son on 2022/07/31.
//

import UIKit

final class AppCoordinator: CoordinatorProtocol {
    // MARK: - Properties
    var navigationController: UINavigationController?
    var childCoordinators = [CoordinatorProtocol]()
    var type: CoordinatorType = .app
    
    // MARK: - Initializers
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Methods
    func start() {
        showSearchListPage()
    }
    
    private func showSearchListPage() {
        guard let navigationController = navigationController else { return }
        let searchListCoordinator = SearchListCoordinator(navigationController: navigationController)
        childCoordinators.append(searchListCoordinator)
        searchListCoordinator.start()
    }
}
