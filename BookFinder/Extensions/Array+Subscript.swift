//
//  Array+Subscript.swift
//  BookFinder
//
//  Created by Hyoju Son on 2022/07/31.
//

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}
