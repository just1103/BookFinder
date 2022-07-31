//
//  BookItem.swift
//  BookFinder
//
//  Created by Hyoju Son on 2022/07/31.
//

import Foundation

struct BookItem {
    let id: String
    
    // VolumeInformation
    let title: String
    let authors: [String]
    let publisher: String
    let publishedDate: String
    let volumeDescription: String
    let pageCount: Int
    let categories: [String]
    let averageRating: Int
    let ratingsCount: Int
    let language: String
    let smallThumbnailURL: String  // ImageLinks
    let thumbnailURL: String
    
    // TODO: 상세화면 부가기능
    // AccessInformation
    let isEbookAvailable: Bool  // Epub.isAvailable
    let istextToSpeechAvailable: Bool  // textToSpeechPermission == "ALLOWED"
}
