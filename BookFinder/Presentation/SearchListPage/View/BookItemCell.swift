//
//  BookItemCell.swift
//  BookFinder
//
//  Created by Hyoju Son on 2022/07/31.
//

import UIKit

final class BookItemCell: UICollectionViewCell {
    // MARK: - Properties
//    private let containerStackView: UIStackView = {
//        let stackView = UIStackView()
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        stackView.axis = .horizontal
//        stackView.alignment = .fill
//        stackView.distribution = .fillEqually
//        stackView.spacing = 10
//        let verticalInset: CGFloat = 12
//        let horizontalInset: CGFloat = 12
//        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(
//            top: verticalInset,
//            leading: horizontalInset,
//            bottom: verticalInset,
//            trailing: horizontalInset
//        )
//        stackView.isLayoutMarginsRelativeArrangement = true
//        return stackView
//    }()
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let volumeInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = .preferredFont(forTextStyle: .title3)
        label.textColor = .black
        label.numberOfLines = 1  
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .black
        label.numberOfLines = 1
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    private let publicationYearLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .black
        label.numberOfLines = 1
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    private let ratingStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = 5
        stackView.setContentHuggingPriority(.required, for: .vertical)
        stackView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return stackView
    }()
    private let ratingCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()
    private let accessoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: Text.accessoryImageName)
        imageView.tintColor = .darkGreen
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private var starViews = (0..<5).map { _ in StarImageView() }
    private var bookItem: BookItem!
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = nil
        authorLabel.text = nil
        publicationYearLabel.text = nil
        starViews.forEach { $0.image = UIImage(systemName: Text.emptyStarImageName) }
        ratingCountLabel.text = nil
    }
    
    // MARK: - Methods
    func setUIContents(with bookItem: BookItem) {
        self.bookItem = bookItem
        
        if let imageURL = bookItem.smallThumbnailURL {
            imageView.loadCachedImage(of: imageURL)
        } else {
            imageView.image = UIImage(systemName: Text.notFoundImageName)
            imageView.tintColor = .lightGreen1
        }
        
        titleLabel.text = bookItem.title
        setAuthorLabel(with: bookItem.authors)
        publicationYearLabel.text = String(bookItem.publishedDate.prefix(4))
        setRatingStackView(with: bookItem.averageRating ?? 0)
        
        if let averageRating = bookItem.averageRating,
           let ratingsCount = bookItem.ratingsCount {
            ratingCountLabel.text = "\(averageRating) (\(ratingsCount)건)"
        } else {
            ratingCountLabel.text = "(0건)"
        }
    }
    
    func retrieveBookItem() -> BookItem {
        return bookItem
    }
    
    private func setAuthorLabel(with authors: [String]) {
        guard let firstAuthor = authors.first else { return }
        
        if authors.count == 1 {
            authorLabel.text = firstAuthor
        } else {
            authorLabel.text = "\(firstAuthor) 외 \(authors.count - 1)인"
        }
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
    
    private func configureUI() {
        backgroundColor = .lightGreen2

        addSubview(imageView)
        addSubview(volumeInfoStackView)
        addSubview(accessoryImageView)
        
        volumeInfoStackView.addArrangedSubview(titleLabel)
        volumeInfoStackView.addArrangedSubview(authorLabel)
        volumeInfoStackView.addArrangedSubview(publicationYearLabel)
        volumeInfoStackView.addArrangedSubview(ratingStackView)
        
        starViews.forEach { ratingStackView.addArrangedSubview($0) }
        ratingStackView.addArrangedSubview(ratingCountLabel)

        let screenWidth = UIScreen.main.bounds.width
        let isWideMode = screenWidth > 1000
        let imageViewWidthRatio: CGFloat = isWideMode ? 0.4 : 0.2
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            imageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: imageViewWidthRatio),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.5),

            volumeInfoStackView.topAnchor.constraint(equalTo: imageView.topAnchor),
            volumeInfoStackView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
            volumeInfoStackView.trailingAnchor.constraint(equalTo: accessoryImageView.leadingAnchor, constant: -10),
            volumeInfoStackView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            
            accessoryImageView.topAnchor.constraint(equalTo: imageView.topAnchor),
            accessoryImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            accessoryImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.03),
            accessoryImageView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
        ])
    }
}

// MARK: - NameSpaces
extension BookItemCell {
    private enum Text {
        static let notFoundImageName: String = "display.trianglebadge.exclamationmark"
        static let emptyStarImageName: String = "star"
        static let filledStarImageName: String = "star.fill"
        static let halfFilledStarImageName: String = "star.leadinghalf.filled"
        static let accessoryImageName: String = "chevron.right"
    }
}
