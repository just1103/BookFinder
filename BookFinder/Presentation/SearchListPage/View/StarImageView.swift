//
//  StarImageView.swift
//  BookFinder
//
//  Created by Hyoju Son on 2022/08/01.
//

import UIKit

final class StarImageView: UIImageView {
    convenience init() {
        self.init(image: UIImage(systemName: Design.emptyStarName))
        translatesAutoresizingMaskIntoConstraints = false
        contentMode = .scaleAspectFit
        heightAnchor.constraint(equalTo: widthAnchor).isActive = true
    }
}

// MARK: - NameSpaces
extension StarImageView {
    private enum Design {
        static let emptyStarName: String = "star"
    }
}
