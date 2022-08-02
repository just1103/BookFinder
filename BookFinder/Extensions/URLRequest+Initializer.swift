//
//  URLRequest+Initializer.swift
//  BookFinder
//
//  Created by Hyoju Son on 2022/07/31.
//

import Foundation

extension URLRequest {
    init?(api: APIProtocol) {
        guard let url = api.url else {
            return nil
        }
        
        self.init(url: url)
        self.httpMethod = "\(api.method)"
    }
}
