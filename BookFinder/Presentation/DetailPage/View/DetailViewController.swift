//
//  DetailViewController.swift
//  BookFinder
//
//  Created by Hyoju Son on 2022/08/02.
//

import UIKit
import RxSwift
import RxCocoa

final class DetailViewController: UIViewController {
    // MARK: - Properties
    
    private var viewModel: DetailViewModel!
    private let leftBarButtonDidTap = PublishSubject<Void>()
    private let disposeBag = DisposeBag()

    // MARK: - Initializers
    convenience init(viewModel: DetailViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bind()
    }

    private func configureUI() {
        configureNavigationBar() // TODO: Navi title 수정
        configureHierarchy()
    }

    private func configureNavigationBar() {
    }
    
    private func configureHierarchy() {
    }
}

// MARK: - Rx Binding Methods
extension DetailViewController {
    private func bind() {
        let input = DetailViewModel.Input(
            leftBarButtonDidTap: leftBarButtonDidTap.asObservable())
        
        let output = viewModel.transform(input)
        
        configureBookItem(with: output.bookItem)
    }
    
    private func configureBookItem(with inputObservable: Observable<BookItem>) {
        inputObservable
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { (self, bookItem) in
//                self.updateLabels(with: bookItem)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - NameSpaces
extension DetailViewController {
    private enum Text {
    }
    
    private enum Design {
    }
}
