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
    private let backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGreen2
        return view
    }()
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
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
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = .preferredFont(forTextStyle: .title2)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = .preferredFont(forTextStyle: .title2)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    private let publisherLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = .preferredFont(forTextStyle: .title3)
        label.textColor = .systemGray
        label.numberOfLines = 0
        return label
    }()
    private let publicationDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = .preferredFont(forTextStyle: .title3)
        label.textColor = .systemGray
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
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()
    private let underlineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray
        return view
    }()
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.dataDetectorTypes = .all
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.font = .preferredFont(forTextStyle: .body)
        textView.backgroundColor = .lightGreen1
        textView.layer.cornerRadius = 10
        textView.clipsToBounds = true
        return textView
    }()
    
    private var starViews = (0..<5).map { _ in StarImageView() }
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
            .foregroundColor: UIColor.lightGreen2,
            .font: UIFont.preferredFont(forTextStyle: .title3)
        ]
    }
    
    private func configureHierarchy() {
        view.addSubview(backgroundView)
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(subtitleLabel)
        scrollView.addSubview(authorLabel)
        scrollView.addSubview(publisherLabel)
        scrollView.addSubview(publicationDateLabel)
        scrollView.addSubview(ratingStackView)
        scrollView.addSubview(underlineView)
        scrollView.addSubview(descriptionTextView)
        
        starViews.forEach { ratingStackView.addArrangedSubview($0) }
        ratingStackView.addArrangedSubview(ratingCountLabel)
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 12),
            imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.5),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -12),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            subtitleLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 12),
            subtitleLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -12),
            authorLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 8),
            authorLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 12),
            authorLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -12),
            publisherLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 8),
            publisherLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 12),
            publisherLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -12),
            publicationDateLabel.topAnchor.constraint(equalTo: publisherLabel.bottomAnchor, constant: 8),
            publicationDateLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 12),
            publicationDateLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -12),
            ratingStackView.topAnchor.constraint(equalTo: publicationDateLabel.bottomAnchor, constant: 8),
            ratingStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 12),
            underlineView.topAnchor.constraint(equalTo: ratingStackView.bottomAnchor, constant: 8),
            underlineView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 12),
            underlineView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -12),
            underlineView.heightAnchor.constraint(equalToConstant: 0.5),
            descriptionTextView.topAnchor.constraint(equalTo: underlineView.bottomAnchor, constant: 15),
            descriptionTextView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 12),
            descriptionTextView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -12),
            descriptionTextView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -12),
        ])
        
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
            .subscribe(onNext: { (owner, bookItem) in
                owner.setUIContents(with: bookItem)
            })
            .disposed(by: disposeBag)
    }
    
    private func setUIContents(with bookItem: BookItem) {
        setNavigationTitle(bookItem.title)
        
        if let imageURL = bookItem.smallImageURL {
            imageView.loadCachedImage(of: imageURL)
        } else if let thumbnailImageURL = bookItem.smallThumbnailURL {
            imageView.loadCachedImage(of: thumbnailImageURL)
        } else {
            imageView.image = UIImage(systemName: Text.notFoundImageName)
            imageView.tintColor = .lightGreen1
        }
        
        titleLabel.text = bookItem.title
        subtitleLabel.text = "?????? : \(bookItem.subtitle)"
        
        let authors = bookItem.authors.joined(separator: ", ")
        authorLabel.text = "?????? : \(authors)"
        
        publisherLabel.text = "????????? : \(bookItem.publisher)"
        publicationDateLabel.text = "???????????? : \(bookItem.publishedDate)"
        
        setRatingStackView(with: bookItem.averageRating ?? 0)
        
        if let averageRating = bookItem.averageRating,
           let ratingsCount = bookItem.ratingsCount {
            ratingCountLabel.text = "\(averageRating)??? (\(ratingsCount)???)"
        } else {
            ratingCountLabel.text = "(0???)"
        }
        
        descriptionTextView.text = bookItem.description
    }
    
    private func setNavigationTitle(_ title: String) {
        navigationItem.title = title
    }
    
    private func setRatingStackView(with averageRating: Double) {
        let quotient = Int(averageRating)
        let remainder = averageRating.truncatingRemainder(dividingBy: 1)
        
        (0...quotient).forEach { number in
            starViews[safe: number - 1]?.image = UIImage(systemName: Text.filledStarImageName)
        }
        
        if remainder >= 0.5 {
            starViews[safe: quotient]?.image = UIImage(systemName: Text.halfFilledStarImageName)
        }
    }
}

// MARK: - NameSpaces
extension DetailViewController {
    private enum Text {
        static let notFoundImageName: String = "display.trianglebadge.exclamationmark"
        static let filledStarImageName: String = "star.fill"
        static let halfFilledStarImageName: String = "star.leadinghalf.filled"
    }
}
