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
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.isDirectionalLockEnabled = true
//        scrollView.isPagingEnabled = false
        scrollView.backgroundColor = .background
        return scrollView
    }()
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = .preferredFont(forTextStyle: .title1)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = .preferredFont(forTextStyle: .title2)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    private let publicationDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = .preferredFont(forTextStyle: .title3)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    private let ratingStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        stackView.spacing = 5
        return stackView
    }()
    private let ratingCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = .preferredFont(forTextStyle: .title3)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.dataDetectorTypes = .all
        textView.backgroundColor = .lightGreen
        textView.textContainerInset = Design.textViewContentInsets
        textView.isEditable = false
        textView.isScrollEnabled = false
        return textView
    }()
    private var starViews = [StarImageView(), StarImageView(), StarImageView(), StarImageView(), StarImageView()]
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
        scrollToTop()
    }

    private func configureUI() {
        configureNavigationBar()
        configureHierarchy()
    }

    private func configureNavigationBar() {
        view.backgroundColor = .darkGreen
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.background,
            .font: UIFont.preferredFont(forTextStyle: .title3)
        ]
    }
    
    private func configureHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(authorLabel)
        scrollView.addSubview(publicationDateLabel)
        scrollView.addSubview(ratingStackView)
        scrollView.addSubview(descriptionTextView)
        
        starViews.forEach { ratingStackView.addArrangedSubview($0) }
        ratingStackView.addArrangedSubview(ratingCountLabel)
        
        
        
        NSLayoutConstraint.activate([
            // FIXME: scrollView trailing 고정이 안되어 Horizontal Scroll되는 문제 발생
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
//            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 12),
            imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.5),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -12),
            
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            authorLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 12),
            authorLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -12),
            
            publicationDateLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 8),
            publicationDateLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 12),
            publicationDateLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -12),
            
            ratingStackView.topAnchor.constraint(equalTo: publicationDateLabel.bottomAnchor, constant: 8),
            ratingStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 12),
            ratingStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -12),
            
            descriptionTextView.topAnchor.constraint(equalTo: ratingStackView.bottomAnchor, constant: 15),
            descriptionTextView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 12),
            descriptionTextView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -12),
            descriptionTextView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -12),
        ])
        
        scrollView.contentSize.width = UIScreen.main.bounds.width
        starViews.forEach { $0.heightAnchor.constraint(equalTo: ratingCountLabel.heightAnchor).isActive = true }
    }
    
    private func scrollToTop() {
        descriptionTextView.setContentOffset(.zero, animated: false)
        descriptionTextView.layoutIfNeeded()
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
                self.apply(bookItem)
            })
            .disposed(by: disposeBag)
    }
    
    func apply(_ bookItem: BookItem) {
        setNavigationTitle(bookItem.title)
        
        if let imageURL = bookItem.smallImageURL {
            imageView.loadCachedImage(of: imageURL)
        } else if let thumbnailImageURL = bookItem.smallThumbnailURL {
            imageView.loadCachedImage(of: thumbnailImageURL)
        } else {
            imageView.image = UIImage(systemName: "display.trianglebadge.exclamationmark")
            imageView.tintColor = .lightGreen
        }
        
        titleLabel.text = bookItem.title
        
        let authors = bookItem.authors.joined(separator: ", ")
        authorLabel.text = "저자 : \(authors)"
        
        publicationDateLabel.text = "출간일자 : \(bookItem.publishedDate)"
        
        configureRatingStackView(with: bookItem.averageRating ?? 0)
        
        if let averageRating = bookItem.averageRating,
           let ratingsCount = bookItem.ratingsCount {
            ratingCountLabel.text = "\(averageRating)점 (\(ratingsCount)건)"
        } else {
            ratingCountLabel.text = "(0건)"
        }
        
        descriptionTextView.text = bookItem.description
    }
    
    private func setNavigationTitle(_ title: String) {
        navigationItem.title = title
    }
    
    private func configureRatingStackView(with averageRating: Double) {
        let quotient = Int(averageRating)
        let remainder = averageRating.truncatingRemainder(dividingBy: 1)
        
        (0...quotient).forEach { number in
            starViews[safe: number - 1]?.image = UIImage(systemName: Design.filledStarName)
        }
        
        if remainder >= 0.5 {
            starViews[safe: quotient]?.image = UIImage(systemName: Design.halfFilledStarName)
        }
    }
}

// MARK: - NameSpaces
extension DetailViewController {
    private enum Text {
    }
    
    private enum Design {
        static let filledStarName: String = "star.fill"
        static let halfFilledStarName: String = "star.leadinghalf.filled"
        static let textViewContentInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
}
