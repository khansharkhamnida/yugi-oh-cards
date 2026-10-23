
import UIKit

class CardTableViewCell: UITableViewCell {

    static let identifier = "CardTableViewCell"

    private let cardImageView = UIImageView()
    private let cardNameLabel = UILabel()
    private let cardTypeLabel = UILabel()
    private let attributeLabel = UILabel()
    private let atkLabel = UILabel()
    private let defLabel = UILabel()
    private let statsStack = UIStackView()
    private let detailsStack = UIStackView()
    private let cardContainer = UIView()

    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .default

        // Card container
        cardContainer.backgroundColor = UIColor.secondarySystemBackground
        cardContainer.layer.cornerRadius = 14
        cardContainer.layer.borderWidth = 1
        cardContainer.layer.borderColor = UIColor.separator
            .withAlphaComponent(0.25).cgColor
        cardContainer.translatesAutoresizingMaskIntoConstraints = false

        // Artwork
        cardImageView.contentMode = .scaleAspectFit
        cardImageView.clipsToBounds = true
        cardImageView.layer.cornerRadius = 7
        cardImageView.backgroundColor = .tertiarySystemBackground
        cardImageView.translatesAutoresizingMaskIntoConstraints = false

        // Name
        cardNameLabel.font = .systemFont(ofSize: 17, weight: .bold)
        cardNameLabel.textColor = .label
        cardNameLabel.numberOfLines = 2

        // Type
        cardTypeLabel.font = .systemFont(ofSize: 12, weight: .medium)
        cardTypeLabel.textColor = .secondaryLabel

        // Attribute
        attributeLabel.font = .systemFont(ofSize: 11, weight: .bold)
        attributeLabel.textAlignment = .center
        attributeLabel.layer.cornerRadius = 5
        attributeLabel.clipsToBounds = true
        attributeLabel.backgroundColor = .tertiarySystemBackground
        attributeLabel.textColor = .secondaryLabel

        // Stats
        atkLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        defLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        atkLabel.textColor = .label
        defLabel.textColor = .label

        let atkStack = UIStackView(arrangedSubviews: [
            makeCaption("ATK"),
            atkLabel
        ])
        atkStack.axis = .vertical
        atkStack.spacing = 3

        let defStack = UIStackView(arrangedSubviews: [
            makeCaption("DEF"),
            defLabel
        ])
        defStack.axis = .vertical
        defStack.spacing = 3

        statsStack.axis = .horizontal
        statsStack.alignment = .leading
        statsStack.distribution = .fillEqually
        statsStack.spacing = 12
        statsStack.addArrangedSubview(atkStack)
        statsStack.addArrangedSubview(defStack)

        // Labels stacked vertically
        detailsStack.axis = .vertical
        detailsStack.alignment = .fill
        detailsStack.spacing = 7

        detailsStack.addArrangedSubview(cardNameLabel)

        let tagsStack = UIStackView(arrangedSubviews: [
            cardTypeLabel,
            attributeLabel
        ])
        tagsStack.axis = .horizontal
        tagsStack.alignment = .center
        tagsStack.spacing = 8

        detailsStack.addArrangedSubview(tagsStack)
        detailsStack.addArrangedSubview(statsStack)
        detailsStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(cardContainer)
        cardContainer.addSubview(cardImageView)
        cardContainer.addSubview(detailsStack)

        NSLayoutConstraint.activate([
            cardContainer.topAnchor.constraint(
                equalTo: contentView.topAnchor, constant: 6
            ),
            cardContainer.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 16
            ),
            cardContainer.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -16
            ),
            cardContainer.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor, constant: -6
            ),

            cardImageView.leadingAnchor.constraint(
                equalTo: cardContainer.leadingAnchor, constant: 12
            ),
            cardImageView.topAnchor.constraint(
                equalTo: cardContainer.topAnchor, constant: 12
            ),
            cardImageView.bottomAnchor.constraint(
                lessThanOrEqualTo: cardContainer.bottomAnchor, constant: -12
            ),
            cardImageView.widthAnchor.constraint(equalToConstant: 76),
            cardImageView.heightAnchor.constraint(equalToConstant: 108),

            detailsStack.leadingAnchor.constraint(
                equalTo: cardImageView.trailingAnchor, constant: 14
            ),
            detailsStack.trailingAnchor.constraint(
                equalTo: cardContainer.trailingAnchor, constant: -12
            ),
            detailsStack.centerYAnchor.constraint(
                equalTo: cardContainer.centerYAnchor
            ),
            detailsStack.topAnchor.constraint(
                greaterThanOrEqualTo: cardContainer.topAnchor, constant: 10
            ),
            detailsStack.bottomAnchor.constraint(
                lessThanOrEqualTo: cardContainer.bottomAnchor, constant: -10
            )
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func makeCaption(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.textColor = .secondaryLabel
        return label
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cardImageView.image = nil
    }

    func configure(with card: YugiohCard) {
        cardNameLabel.text = card.name
        cardTypeLabel.text = card.cardType.rawValue.uppercased()

        // Attribute badge
        if let attribute = card.attribute,
           card.cardType == .monster {
            attributeLabel.text = "  \(attribute.rawValue)  "
            attributeLabel.isHidden = false
        } else {
            attributeLabel.text = nil
            attributeLabel.isHidden = true
        }

        // Show ATK/DEF only for monsters
        let isMonster = card.cardType == .monster
        statsStack.isHidden = !isMonster

        if isMonster {
            atkLabel.text = card.atk.map(String.init) ?? "?"
            defLabel.text = card.def.map(String.init) ?? "?"
        }
        
        // Load image from Assets.xcassets
        if let image = CardImageStore.load(card.imageURLString) {
            cardImageView.image = image
            cardImageView.isHidden = false
        } else {
            cardImageView.image = nil
            cardImageView.isHidden = true
        }

    }
}
