//
//  CardDetailsViewController.swift
//  yugi oh cards
//
//  Created by Shofia Ghazali on 19/10/26.
//
import UIKit

protocol CardDetailsViewControllerDelegate: AnyObject {
    func cardDetailsViewController(
        _ controller: CardDetailsViewController,
        didUpdate card: YugiohCard
    )
}

class CardDetailsViewController: UITableViewController {
    
    var card: YugiohCard
    weak var delegate: CardDetailsViewControllerDelegate?
    
    private let cardImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    
    init(card: YugiohCard) {
        self.card = card
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBlue
        title = card.name
        
        setUpUI()
        setUpLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let header = tableView.tableHeaderView else {
            return
        }

        if header.frame.width != tableView.bounds.width {
            header.frame.size.width = tableView.bounds.width
            tableView.tableHeaderView = header
        }
    }
    
    @objc func setUpUI(){
        title = card.name
        tableView.backgroundColor = .systemGroupedBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .edit,
            target: self,
            action: #selector(editButtonTapped)
        )
        
        setupCardImage()
        
        //top blue navigation bar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBlue
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .white

        // Make the status bar text white
        navigationController?.navigationBar.barStyle = .black
    }
    
    @objc func setUpLayout(){
        
    }
    
    private func setupCardImage() {
        guard let image = CardImageStore.load(card.imageURLString) else { tableView.tableHeaderView = nil
            return
        }
 
        let headerView = UIView()
        headerView.backgroundColor = .systemBackground

        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        headerView.addSubview(imageView)

        let headerWidth = tableView.bounds.width
        let headerHeight: CGFloat = 320

        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(
                equalTo: headerView.centerXAnchor
            ),
            imageView.centerYAnchor.constraint(
                equalTo: headerView.centerYAnchor
            ),
            imageView.widthAnchor.constraint(
                equalToConstant: 200
            ),
            imageView.heightAnchor.constraint(
                equalToConstant: 290
            )
        ])

        headerView.frame = CGRect(
            x: 0,
            y: 0,
            width: headerWidth,
            height: headerHeight
        )

        tableView.tableHeaderView = headerView
    }
    
    // MARK: - Table Sections
    override func numberOfSections(
        in tableView: UITableView
    ) -> Int {
        return card.cardType == .monster ? 3 : 2
    }

    override func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        switch section {
        case 0:
            return "Card Information"
        case 1 where card.cardType == .monster:
            return "Monster Stats"
        case 1:
            return "Description"
        case 2:
            return "Description"
        default:
            return nil
        }
    }

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        switch (card.cardType, section) {
        case (_, 0):
            return 2
        case (.monster, 1):
            return 4
        case (.monster, 2), (.spell, 1), (.trap, 1):
            return 1
        default:
            return 0
        }
    }

    // MARK: - Table Cells

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = UITableViewCell(
            style: .value1,
            reuseIdentifier: nil
        )

        cell.selectionStyle = .none

        switch (card.cardType, indexPath.section, indexPath.row) {

        case (_, 0, 0):
            cell.textLabel?.text = "Card Name"
            cell.detailTextLabel?.text = card.name

        case (_, 0, 1):
            cell.textLabel?.text = "Card Number"
            cell.detailTextLabel?.text = card.cardNumber.isEmpty
                ? "Not set"
                : card.cardNumber

        case (.monster, 1, 0):
            cell.textLabel?.text = "Attribute"
            cell.detailTextLabel?.text = card.attribute?.rawValue ?? "—"

        case (.monster, 1, 1):
            cell.textLabel?.text = "Level"
            cell.detailTextLabel?.text = card.level.map { "\($0)" } ?? "—"

        case (.monster, 1, 2):
            cell.textLabel?.text = "Monster Type"
            cell.detailTextLabel?.text = card.monsterType?.rawValue ?? "-"

        case (.monster, 1, 3):
            cell.textLabel?.text = "ATK / DEF"
            let atk = card.atk.map { "\($0)" } ?? "—"
            let def = card.def.map { "\($0)" } ?? "—"
            cell.detailTextLabel?.text = "\(atk) / \(def)"

        case (_, let section, 0)
            where section == (card.cardType == .monster ? 2 : 1):
            cell.textLabel?.text = "Description"
            cell.detailTextLabel?.text = card.description.isEmpty
                ? "No description"
                : card.description
            cell.detailTextLabel?.numberOfLines = 0

        default:
            break
        }

        return cell
    }

    // MARK: - Edit Button

    @objc func editButtonTapped() {
        let editVC = CardEditViewController(card: card)
        editVC.delegate = self
    
        let navController = UINavigationController(
            rootViewController: editVC
        )

        if #available(iOS 15.0, *) {
            if let sheet = navController.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 24
            }
        }

        present(navController, animated: true)
    }
}

extension CardDetailsViewController: CardEditViewControllerDelegate {

    func cardEditViewController(
        _ controller: CardEditViewController,
        didSave card: YugiohCard
    ) {
        
        self.card = card

        title = card.name
        
        tableView.reloadData()

        setupCardImage()
        
        // Notify ViewController that the card changed
        delegate?.cardDetailsViewController(
            self,
            didUpdate: card
        )
    }
}
