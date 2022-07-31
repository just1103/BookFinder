//
//  Book.swift
//  BookFinder
//
//  Created by Hyoju Son on 2022/07/31.
//

import Foundation

struct BookItemDTO: Codable {
    let kind: String?
    let id: String?
    let etag: String?
    let selfLink: String?
    let volumeInfo: VolumeInfoDTO?
    let saleInfo: SaleInfoDTO?
    let accessInfo: AccessInfoDTO?
    let searchInfo: SearchInfoDTO?
}
