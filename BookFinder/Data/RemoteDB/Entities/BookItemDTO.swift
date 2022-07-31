//
//  Book.swift
//  BookFinder
//
//  Created by Hyoju Son on 2022/07/31.
//

import Foundation

struct BookItemDTO: Codable {
    let kind: String
    let id: String
    let etag: String
    let selfLink: String
    let volumeInfo: VolumeInformation
    let saleInfo: SaleInformation
    let accessInfo: AccessInformation
    let searchInfo: SearchInformation
}

// MARK: - AccessInformation
struct AccessInformation: Codable {
    let country, viewability: String
    let embeddable, publicDomain: Bool
    let textToSpeechPermission: String
    let epub: Epub
    let pdf: PDF
    let webReaderLink: String
    let accessViewStatus: String
    let quoteSharingAllowed: Bool
}

// MARK: - Epub
struct Epub: Codable {
    let isAvailable: Bool
    let acsTokenLink: String
}

// MARK: - PDF
struct PDF: Codable {
    let isAvailable: Bool
}

// MARK: - SaleInformation
struct SaleInformation: Codable {
    let country, saleability: String
    let isEbook: Bool
    let listPrice, retailPrice: SaleInformationListPrice
    let buyLink: String
    let offers: [Offer]
}

// MARK: - SaleInfoListPrice
struct SaleInformationListPrice: Codable {
    let amount: Int
    let currencyCode: String
}

// MARK: - Offer
struct Offer: Codable {
    let finskyOfferType: Int
    let listPrice, retailPrice: OfferListPrice
}

// MARK: - OfferListPrice
struct OfferListPrice: Codable {
    let amountInMicros: Int
    let currencyCode: String
}

// MARK: - SearchInformation
struct SearchInformation: Codable {
    let textSnippet: String
}

// MARK: - VolumeInformation
struct VolumeInformation: Codable {
    let title: String
    let authors: [String]
    let publisher, publishedDate, volumeDescription: String
    let industryIdentifiers: [IndustryIdentifier]
    let readingModes: ReadingModes
    let pageCount: Int
    let printType: String
    let categories: [String]
    let averageRating, ratingsCount: Int
    let maturityRating: String
    let allowAnonLogging: Bool
    let contentVersion: String
    let panelizationSummary: PanelizationSummary
    let imageLinks: ImageLinks
    let language: String
    let previewLink: String
    let infoLink, canonicalVolumeLink: String

    enum CodingKeys: String, CodingKey {
        case title, authors, publisher, publishedDate
        case volumeDescription = "description"
        case industryIdentifiers, readingModes, pageCount, printType, categories, averageRating, ratingsCount,
             maturityRating, allowAnonLogging, contentVersion, panelizationSummary, imageLinks, language, 
             previewLink, infoLink, canonicalVolumeLink
    }
}

// MARK: - ImageLinks
struct ImageLinks: Codable {
    let smallThumbnail, thumbnail: String
}

// MARK: - IndustryIdentifier
struct IndustryIdentifier: Codable {
    let type, identifier: String
}

// MARK: - PanelizationSummary
struct PanelizationSummary: Codable {
    let containsEpubBubbles, containsImageBubbles: Bool
}

// MARK: - ReadingModes
struct ReadingModes: Codable {
    let text, image: Bool
}
