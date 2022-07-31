//
//  BookFinderURL.swift
//  BookFinder
//
//  Created by Hyoju Son on 2022/07/31.
//

import Foundation

struct BookFinderURL {
    static let baseURL: String = "https://www.googleapis.com/books/v1/"
    
    struct BookSearchAPI: Gettable {
        let url: URL?
        let method: HttpMethod = .get
        
        init(query: String, baseURL: String = baseURL) {
            var urlComponents = URLComponents(string: "\(baseURL)volumes?")
            let titleOrAuthorsQuery = URLQueryItem(name: "q", value: "\(query)")
            urlComponents?.queryItems?.append(titleOrAuthorsQuery)
            self.url = urlComponents?.url
            
//            self.url = URL(string: "\(baseURL)volumes?q=\(query)")  // TODO: 검색 구체화 (제목, 저자로 항목 한정)
        }
    }
}
