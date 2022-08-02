//
//  AlertFactory.swift
//  BookFinder
//
//  Created by Hyoju Son on 2022/07/31.
//

import UIKit

struct AlertFactory {
    func createAlert(
        style: UIAlertController.Style = .alert,
        title: String? = nil,
        message: String? = nil,
        actions: UIAlertAction...)
    -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        actions.forEach { alert.addAction($0) }
        
        return alert
    }
}
