//
//  CoordinatorProtocol.swift
//  BookFinder
//
//  Created by Hyoju Son on 2022/07/31.
//

import UIKit

enum CoordinatorType {
    case app
    case searchList, detail
}

protocol CoordinatorProtocol: AnyObject {
    var navigationController: UINavigationController? { get set }
    var childCoordinators: [CoordinatorProtocol] { get set }
    var type: CoordinatorType { get }
    
    func start()
//    func removeFromChildCoordinators(coordinator: CoordinatorProtocol)
//    func popCurrentPage()
}
