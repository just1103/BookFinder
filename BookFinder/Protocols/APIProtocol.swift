//
//  APIProtocol.swift
//  BookFinder
//
//  Created by Hyoju Son on 2022/07/31.
//

import Foundation

protocol APIProtocol {
    var url: URL? { get }
    var method: HttpMethod { get }
}

protocol Gettable: APIProtocol { }

enum HttpMethod {
    case get
//    case post
//    case delete
//    case put
    
    var description: String {
        switch self {
        case .get:
            return "GET"
//        case .post:
//            return "POST"
//        case .delete:
//            return "DELETE"
//        case .put:
//            return "PUT"
        }
    }
}

