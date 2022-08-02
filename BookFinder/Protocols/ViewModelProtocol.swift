//
//  ViewModelProtocol.swift
//  BookFinder
//
//  Created by Hyoju Son on 2022/08/02.
//

import Foundation

protocol ViewModelProtocol: AnyObject {
    associatedtype Input
    associatedtype Output
    
    func transform(_ input: Input) -> Output
}
