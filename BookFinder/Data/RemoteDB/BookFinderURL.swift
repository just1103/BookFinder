//
//  BookFinderURL.swift
//  BookFinder
//
//  Created by Hyoju Son on 2022/07/31.
//

import Foundation

struct BookFinderURL {
    static let baseURL: String = "http://3.39.155.132:8080/"
    
    struct SearchBookAPI: Gettable {
        let url: URL?
        let method: HttpMethod = .get
        
        init(baseURL: String = baseURL) {
            self.url = URL(string: "\(baseURL)22222222")
        }
    }
}
