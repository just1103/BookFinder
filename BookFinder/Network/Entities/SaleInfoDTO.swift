//
//  SaleInfoDTO.swift
//  BookFinder
//
//  Created by Hyoju Son on 2022/07/31.
//

import Foundation

struct SaleInfoDTO: Decodable {
    let country, saleability: String?
    let isEbook: Bool?
    let listPrice, retailPrice: SaleInfoListPrice?
    let buyLink: String?
    let offers: [Offer]?
}

// MARK: - SaleInfoListPrice
struct SaleInfoListPrice: Decodable {
    let amount: Int?
    let currencyCode: String?
}

// MARK: - Offer
struct Offer: Decodable {
    let finskyOfferType: Int?
    let listPrice, retailPrice: OfferListPrice?
}

// MARK: - OfferListPrice
struct OfferListPrice: Decodable {
    let amountInMicros: Int?
    let currencyCode: String?
}
