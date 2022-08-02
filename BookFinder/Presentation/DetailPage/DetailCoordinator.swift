//
//  DetailCoordinator.swift
//  BookFinder
//
//  Created by Hyoju Son on 2022/08/02.
//

import UIKit

final class DetailCoordinator: CoordinatorProtocol {
    // MARK: - Properties
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
    
    func finish() {
        // TODO: Delegate 호출
//        delegate.removeFromSuperview()
    }

    private func showDetailPage(with bookItem: BookItem) {
        guard let navigationController = navigationController else { return }
        
        let detailViewModel = DetailViewModel(coordinator: self, bookItem: bookItem)
        let detailViewController = DetailViewController(viewModel: detailViewModel)
        
        navigationController.pushViewController(detailViewController, animated: true)
    }
    
    func popCurrentPage() {
        navigationController?.popViewController(animated: true)
    }
}
