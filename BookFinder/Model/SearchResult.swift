//
//  SearchResult.swift
//  BookFinder
//
//  Created by Hyoju Son on 2022/07/31.
//

import Foundation

struct SearchResult {
    let kind: String
    let totalItems: Int
    let items: [BookItem]
}
