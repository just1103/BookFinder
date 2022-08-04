//
//  JSONParser.swift
//  BookFinder
//
//  Created by Hyoju Son on 2022/07/31.
//

import Foundation

enum JSONParserError: Error, LocalizedError {
    case decodingFail
    
    var errorDescription: String? {
        switch self {
        case .decodingFail:
            return "디코딩에 실패했습니다."
        }
    }
}

struct JSONParser<Item: Decodable> {
    func decode(from json: Data?) -> Item? {
        guard let data = json else {
            return nil
        }

        guard let decodedData = try? JSONDecoder().decode(Item.self, from: data) else {
            return nil
        }
        
        return decodedData
    }
}
