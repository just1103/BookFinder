//
//  BookItem.swift
//  BookFinder
//
//  Created by Hyoju Son on 2022/07/31.
//

import Foundation

final class BookItem: Hashable {
    let id: String
    let title: String
    let subtitle: String
    let authors: [String]
    let publisher: String
    let publishedDate: String
    let averageRating: Double?
    let ratingsCount: Int?
    let smallThumbnailURL: String?
    let smallImageURL: String?
    let description: String
    
    init(
        id: String?,
        title: String?,
        subtitle: String?,
        authors: [String]?,
        publisher: String?,
        publishedDate: String?,
        averageRating: Double?,
        ratingsCount: Int?,
        smallThumbnailURL: String?,
        smallImageURL: String?,
        description: String?
    ) {
        self.id = id ?? "id 정보 없음"
        self.title = title ?? "제목 없음"
        self.subtitle = subtitle ?? "부제 없음"
        self.authors = authors ?? ["저자 정보 없음"]
        self.publisher = publisher ?? "출판사 정보 없음"
        self.publishedDate = publishedDate ?? "출간일 정보 없음"
        self.averageRating = averageRating
        self.ratingsCount = ratingsCount
        self.smallThumbnailURL = smallThumbnailURL
        self.smallImageURL = smallImageURL
        self.description = description ?? "상세설명 정보 없음"
    }
    
    static func convert(bookItemDTO: BookItemDTO) -> BookItem {
        return BookItem(
            id: bookItemDTO.id ?? "id 정보 없음",
            title: bookItemDTO.volumeInfo?.title ?? "제목 없음",
            subtitle: bookItemDTO.volumeInfo?.subtitle ?? "부제 없음",
            authors: bookItemDTO.volumeInfo?.authors ?? ["저자 정보 없음"],
            publisher: bookItemDTO.volumeInfo?.publisher ?? "출판사 정보 없음",
            publishedDate: bookItemDTO.volumeInfo?.publishedDate ?? "출간일 정보 없음",
            averageRating: bookItemDTO.volumeInfo?.averageRating,
            ratingsCount: bookItemDTO.volumeInfo?.ratingsCount,
            smallThumbnailURL: bookItemDTO.volumeInfo?.imageLinks?.smallThumbnail,
            smallImageURL: bookItemDTO.volumeInfo?.imageLinks?.small,
            description: bookItemDTO.volumeInfo?.volumeDescription ?? "상세설명 정보 없음"
        )
    }
    
    static func == (lhs: BookItem, rhs: BookItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
