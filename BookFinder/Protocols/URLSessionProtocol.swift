//
//  URLSessionProtocol.swift
//  BookFinder
//
//  Created by Hyoju Son on 2022/07/31.
//

import Foundation

protocol URLSessionProtocol {
    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask
}

extension URLSession: URLSessionProtocol { }
