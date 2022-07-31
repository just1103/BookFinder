//
//  SearchResult.swift
//  BookFinder
//
//  Created by Hyoju Son on 2022/07/31.
//

import Foundation

struct SearchResultDTO: Codable {
    let kind: String?
    let totalItems: Int?
    let items: [BookItemDTO]?
}
