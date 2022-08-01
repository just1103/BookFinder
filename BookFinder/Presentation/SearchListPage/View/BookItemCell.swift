//
//  BookItemCell.swift
//  BookFinder
//
//  Created by Hyoju Son on 2022/07/31.
//

import UIKit

final class BookItemCell: UICollectionViewCell {
    // MARK: - Properties
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 10
        let verticalInset: CGFloat = 5
        let horizontalInset: CGFloat = 10
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: verticalInset,
            leading: horizontalInset,
            bottom: verticalInset,
            trailing: horizontalInset
        )
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 6
        imageView.clipsToBounds = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
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
        label.textColor = .label
        label.numberOfLines = 0
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .label
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
        label.textColor = .label
        label.numberOfLines = 1
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    private let ratingStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .leading
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
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    private let accessoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: Design.accessoryImageName)
        imageView.tintColor = Design.accessoryImageViewColor
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private var starViews = [StarImageView(), StarImageView(), StarImageView(), StarImageView(), StarImageView()]
//    private var starViews = [StarImageView](repeating: StarImageView(), count: 5)
    
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
        starViews.forEach { $0.image = nil }
        ratingCountLabel.text = nil
    }
    
    // MARK: - Methods
    func apply(bookItem: BookItem) {
        if let imageURL = bookItem.smallThumbnailURL {
            imageView.loadCachedImage(of: imageURL)
        } else {
            imageView.image = UIImage(systemName: "display.trianglebadge.exclamationmark")
            imageView.tintColor = .lightGreen
        }
        
        titleLabel.text = bookItem.title
        configureAuthorLabel(with: bookItem.authors)
        publicationYearLabel.text = String(bookItem.publishedDate.prefix(4))
        configureRatingStackView(with: bookItem.averageRating ?? 0)
        
        if let ratingsCount = bookItem.ratingsCount {
            ratingCountLabel.text = "(\(ratingsCount))"
        } else {
            ratingCountLabel.text = "(0)"
        }
    }
    
    private func configureAuthorLabel(with authors: [String]) {
        guard let firstAuthor = authors.first else { return }
        
        if authors.count == 1 {
            authorLabel.text = firstAuthor
        } else {
            authorLabel.text = "\(firstAuthor) 외 \(authors.count - 1)"
        }
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
    
    private func configureUI() {
        backgroundColor = .background
        
        addSubview(containerStackView)
        containerStackView.addArrangedSubview(imageView)
        containerStackView.addArrangedSubview(volumeInfoStackView)
        containerStackView.addArrangedSubview(accessoryImageView)
        
        volumeInfoStackView.addArrangedSubview(titleLabel)
        volumeInfoStackView.addArrangedSubview(authorLabel)
        volumeInfoStackView.addArrangedSubview(publicationYearLabel)
        volumeInfoStackView.addArrangedSubview(ratingStackView)
        
        starViews.forEach { ratingStackView.addArrangedSubview($0) }
        ratingStackView.addArrangedSubview(ratingCountLabel)

        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: self.topAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: containerStackView.widthAnchor, multiplier: 0.3),
            accessoryImageView.widthAnchor.constraint(equalTo: containerStackView.widthAnchor, multiplier: 0.03)
        ])
        
        starViews.forEach { $0.heightAnchor.constraint(equalTo: ratingCountLabel.heightAnchor).isActive = true }
    }
}

// MARK: - NameSpaces
extension BookItemCell {
    private enum Design {
        static let accessoryImageName: String = "chevron.right"
//        static let emptyStarName: String = "star"
        static let filledStarName: String = "star.fill"
        static let halfFilledStarName: String = "star.leadinghalf.filled"
        
        static let accessoryImageViewColor: UIColor = .darkGreen
    }
}
