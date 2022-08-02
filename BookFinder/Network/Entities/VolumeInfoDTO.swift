//
//  VolumeInfoDTO.swift
//  BookFinder
//
//  Created by Hyoju Son on 2022/07/31.
//

import Foundation

struct VolumeInfoDTO: Decodable {
    let title: String?
    let subtitle: String?
    let authors: [String]?
    let publisher, publishedDate, volumeDescription: String?
    let industryIdentifiers: [IndustryIdentifier]?
    let readingModes: ReadingModes?
    let pageCount: Int?
    let printType: String?
    let categories: [String]?
    let averageRating: Double?
    let ratingsCount: Int?
    let maturityRating: String?
    let allowAnonLogging: Bool?
    let contentVersion: String?
    let panelizationSummary: PanelizationSummary?
    let imageLinks: ImageLinks?
    let language: String?
    let previewLink: String?
    let infoLink, canonicalVolumeLink: String?
    
    enum CodingKeys: String, CodingKey {
        case title, subtitle, authors, publisher, publishedDate
        case volumeDescription = "description"
        case industryIdentifiers, readingModes, pageCount, printType, categories, averageRating, ratingsCount,
             maturityRating, allowAnonLogging, contentVersion, panelizationSummary, imageLinks, language,
             previewLink, infoLink, canonicalVolumeLink
    }
}

// MARK: - ImageLinks
struct ImageLinks: Decodable {
    let smallThumbnail, thumbnail, small, medium, large, extraLarge: String?
}

// MARK: - IndustryIdentifier
struct IndustryIdentifier: Decodable {
    let type, identifier: String?
}

// MARK: - PanelizationSummary
struct PanelizationSummary: Decodable {
    let containsEpubBubbles, containsImageBubbles: Bool?
}

// MARK: - ReadingModes
struct ReadingModes: Decodable {
    let text, image: Bool?
}
