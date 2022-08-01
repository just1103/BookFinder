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
        
        init(
            searchText: String,
            pageNumber: Int = 1,
            baseURL: String = baseURL
        ) {
            let itemPerPage = 20  // TODO: ListViewModel이 들고있어야 하나?
            let startIndex = (pageNumber - 1) * itemPerPage
            
            var urlComponents = URLComponents(string: "\(baseURL)volumes?")
            let searchTextQuery = URLQueryItem(name: "q", value: "\(searchText)") // TODO: 검색 구체화 (제목, 저자로 항목 한정)
            let startIndexQuery = URLQueryItem(name: "startIndex", value: "\(startIndex)")
            let maxResultsQuery = URLQueryItem(name: "maxResults", value: "\(itemPerPage)")
            urlComponents?.queryItems?.append(
                contentsOf: [searchTextQuery, startIndexQuery, maxResultsQuery]
            )
            
            self.url = urlComponents?.url
        }
    }
}
