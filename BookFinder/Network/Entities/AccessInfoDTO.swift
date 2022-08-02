//
//  AccessInfoDTO.swift
//  BookFinder
//
//  Created by Hyoju Son on 2022/07/31.
//

import Foundation

struct AccessInfoDTO: Decodable {
    let country, viewability: String?
    let embeddable, publicDomain: Bool?
    let textToSpeechPermission: String?
    let epub: Epub?
    let pdf: PDF?
    let webReaderLink: String?
    let accessViewStatus: String?
    let quoteSharingAllowed: Bool?
}

// MARK: - Epub
struct Epub: Codable {
    let isAvailable: Bool?
    let acsTokenLink: String?
}

// MARK: - PDF
struct PDF: Codable {
    let isAvailable: Bool?
    let acsTokenLink: String?
}
