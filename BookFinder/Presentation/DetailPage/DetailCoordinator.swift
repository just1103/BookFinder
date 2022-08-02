//
//  DetailCoordinator.swift
//  BookFinder
//
//  Created by Hyoju Son on 2022/08/02.
//

import UIKit

protocol DetailCoordinatorDelegete: AnyObject {
    func removeFromChildCoordinators(coordinator: CoordinatorProtocol)
}

final class DetailCoordinator: CoordinatorProtocol {
    // MARK: - Properties
    
    weak var delegate: DetailCoordinatorDelegete!
    var navigationController: UINavigationController?
    var childCoordinators = [CoordinatorProtocol]()
    var type: CoordinatorType = .detail
    
    // MARK: - Initializers
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Methods
    func start(with bookItem: BookItem) {
        showDetailPage(with: bookItem)
    }

    private func showDetailPage(with bookItem: BookItem) {
        guard let navigationController = navigationController else { return }
        
        let detailViewModel = DetailViewModel(coordinator: self, bookItem: bookItem)
        let detailViewController = DetailViewController(viewModel: detailViewModel)
        
        navigationController.pushViewController(detailViewController, animated: true)
    }
    
    func finish() {
        delegate.removeFromChildCoordinators(coordinator: self)
    }
    
    func popCurrentPage() {
        navigationController?.popViewController(animated: true)
    }
}
