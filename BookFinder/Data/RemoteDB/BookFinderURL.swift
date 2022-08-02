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
            itemPerPage: Int = 20,
            baseURL: String = baseURL
        ) {
            let startIndex = (pageNumber - 1) * itemPerPage
            
            var urlComponents = URLComponents(string: "\(baseURL)volumes?")
            let searchTextQuery = URLQueryItem(name: "q", value: "\(searchText)")
            let startIndexQuery = URLQueryItem(name: "startIndex", value: "\(startIndex)")
            let maxResultsQuery = URLQueryItem(name: "maxResults", value: "\(itemPerPage)")
            urlComponents?.queryItems?.append(
                contentsOf: [searchTextQuery, startIndexQuery, maxResultsQuery]
            )
            
            self.url = urlComponents?.url
        }
    }
}
