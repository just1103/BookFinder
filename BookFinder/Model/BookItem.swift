//
//  BookItem.swift
//  BookFinder
//
//  Created by Hyoju Son on 2022/07/31.
//

import Foundation

final class BookItem: Hashable {
    let id: String
    
    // VolumeInformation
    let title: String
    let authors: [String]
    
    let publishedDate: String
    let averageRating: Double?
    let ratingsCount: Int?
    let smallThumbnailURL: String?
    let smallImageURL: String?
    let description: String
    
    init(
        id: String?,
        title: String?,
        authors: [String]?,
        publishedDate: String?,
        averageRating: Double?,
        ratingsCount: Int?,
        smallThumbnailURL: String?,
        smallImageURL: String?,
        description: String?
    ) {
        self.id = id ?? "id 정보 없음"
        self.title = title ?? "제목 없음"
        self.authors = authors ?? ["저자 정보 없음"]
        self.publishedDate = publishedDate ?? "출간일 정보 없음"
        self.averageRating = averageRating
        self.ratingsCount = ratingsCount
        self.smallThumbnailURL = smallThumbnailURL
        self.smallImageURL = smallImageURL
        self.description = description ?? "상세설명 정보 없음"
    }
    
    static func == (lhs: BookItem, rhs: BookItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

//struct BookItem: Hashable {
//    let id: String
//
//    // VolumeInformation
//    let title: String
//    let authors: [String]
//    let publisher: String
//    let publishedDate: String
//    let volumeDescription: String
//    let averageRating: Double?
//    let ratingsCount: Int?
//    let smallThumbnailURL: String  // ImageLinks
//    let thumbnailURL: String
//
//    init(
//        id: String?,
//        title: String?,
//        authors: [String]?,
//        publisher: String?,
//        publishedDate: String?,
//        volumeDescription: String?,
//        averageRating: Double?,
//        ratingsCount: Int?,
//        smallThumbnailURL: String?,
//        thumbnailURL: String?
//    ) {
//        self.id = id ?? "id 정보 없음"
//        self.title = title ?? "제목 없음"
//        self.authors = authors ?? ["저자 정보 없음"]
//        self.publisher = publisher ?? "출판사 정보 없음"
//        self.publishedDate = publishedDate ?? "출간일 정보 없음"
//        self.volumeDescription = volumeDescription ?? "상세정보 없음"
//        self.averageRating = averageRating
//        self.ratingsCount = ratingsCount
//        self.smallThumbnailURL = smallThumbnailURL ?? "" // TODO: 정보없음 이미지로 교체
//        self.thumbnailURL = thumbnailURL ?? ""
//    }
//}
