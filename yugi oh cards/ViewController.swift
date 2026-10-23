//
//  ViewController.swift
//  yugi oh cards
//
//  Created by Shofia Ghazali on 19/10/26.
//

import UIKit

//scenedelegate -> wraps in navigation controller -> viewcontroller -> tableview (card list) on home page -> push controller (when one of them in the list is tapped) ->tableview for details page -> present controller (inside a button) tableview for edit page
// MARK: Diffable Data Source
// MARK: 2. Removed conformance to UITableViewDataSource
class ViewController: UIViewController,
                      UITableViewDelegate  { // UITableViewDataSource
    
    // MARK: Diffable Data Source
    // MARK: 3. Add new property of diffable data source
    private var dataSource: YugiohCardDataSource!

    var titleLabelText = "Yugi Oh Cards Collection"
    let addButton: UIButton = {
    let button = UIButton(type: .system)

    // Plus icon
    let image = UIImage(
        systemName: "plus",
        withConfiguration: UIImage.SymbolConfiguration(
            pointSize: 24,
            weight: .semibold
        )
    )
    button.setImage(image, for: .normal)

    // Appearance
    button.tintColor = .white
    button.backgroundColor = .systemBlue

    button.layer.cornerRadius = 25
    button.layer.borderWidth = 3
    button.layer.borderColor = UIColor.white.cgColor
    button.clipsToBounds = true

    // Circular shape
    button.layer.cornerRadius = 30
    button.clipsToBounds = true

    button.translatesAutoresizingMaskIntoConstraints = false

    return button
    }()
    
    // 1. Create the container header view to stretch edge-to-edge
    let headerBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let tableView = UITableView()

    // 2. Create the clean text label
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func setUpUI(){
        addButton.addTarget(
            self,
            action: #selector(addCardTapped),
            for: .touchUpInside
        )

        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140
        tableView.contentInset = UIEdgeInsets(
            top: 8,
            left: 0,
            bottom: 20,
            right: 0
        )
        
        // tableView.dataSource = self
        tableView.delegate = self

        tableView.register(
            CardTableViewCell.self,
            forCellReuseIdentifier: CardTableViewCell.identifier
        )
    }
    
    // MARK: cardsList will now populate from initial seed
    var cards: [YugiohCard] = []
    
    // MARK: 3. Add store property to main view controller
    private let store = YugiohCardDataStore.shared
    
    func setUpLayout(){
        view.backgroundColor = .systemBackground
        
        // Add components to the view hierarchy
        view.addSubview(headerBackgroundView)
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        headerBackgroundView.addSubview(titleLabel)
        headerBackgroundView.addSubview(addButton)
        
        titleLabel.text = titleLabelText
        
        // 3. Set layout constraints
        NSLayoutConstraint.activate([
            // Header background
                headerBackgroundView.topAnchor.constraint(
                    equalTo: view.topAnchor
                ),
                headerBackgroundView.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor
                ),
                headerBackgroundView.trailingAnchor.constraint(
                    equalTo: view.trailingAnchor
                ),

                // Add button
                addButton.widthAnchor.constraint(equalToConstant: 50),
                addButton.heightAnchor.constraint(equalToConstant: 50),
                addButton.trailingAnchor.constraint(
                    equalTo: headerBackgroundView.trailingAnchor,
                    constant: -20
                ),
                addButton.centerYAnchor.constraint(
                    equalTo: titleLabel.centerYAnchor
                ),

                // Title
                titleLabel.topAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.topAnchor,
                    constant: 10
                ),
                titleLabel.bottomAnchor.constraint(
                    equalTo: headerBackgroundView.bottomAnchor,
                    constant: -15
                ),
                titleLabel.leadingAnchor.constraint(
                    equalTo: headerBackgroundView.leadingAnchor,
                    constant: 20
                ),
                titleLabel.trailingAnchor.constraint(
                    equalTo: addButton.leadingAnchor,
                    constant: -10
                ),
                tableView.topAnchor.constraint(
                    equalTo: headerBackgroundView.bottomAnchor
                ),
                tableView.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor
                ),
                tableView.trailingAnchor.constraint(
                    equalTo: view.trailingAnchor
                ),
                tableView.bottomAnchor.constraint(
                    equalTo: view.bottomAnchor
                )
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cards = store.loadYugiohCards()
        
        setUpUI()
        setUpLayout()
        
        // MARK: Diffable Data Source
        // MARK: 4. Setup the data source
        // The closure replaces the cellForRowAt and we no longer have to handle indexPath ourselves -> every cell configured from YugiohCard lorh
        dataSource = YugiohCardDataSource(tableView: tableView) { tableView, indexPath, item in
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: CardTableViewCell.identifier,
                    for: indexPath
                ) as? CardTableViewCell else {
                    return UITableViewCell()
                }
                cell.configure(with: item)
                return cell
            }
        dataSource.defaultRowAnimation = .fade

        cards = store.loadYugiohCards()
        applySnapshot(animatingDifferences: false)   // initial display, no animation
        
        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: .main) { [weak self] _ in
            guard let self else { return }
            try? self.store.saveYugiohCards(self.cards)
        }
    }
    
    // MARK: Diffable Data Source
    // MARK: 2. Removed conformance to UITableViewDataSource
//    //tableView for the card list
//    func tableView(
//        _ tableView: UITableView,
//        numberOfRowsInSection section: Int
//    ) -> Int {
//        return cards.count
//    }

    // MARK: Diffable Data Source
    // MARK: 2. Removed conformance to UITableViewDataSource
//    func tableView(
//        _ tableView: UITableView,
//        cellForRowAt indexPath: IndexPath
//    ) -> UITableViewCell {
//
//        let cell = tableView.dequeueReusableCell(
//            withIdentifier: CardTableViewCell.identifier,
//            for: indexPath
//        ) as! CardTableViewCell
//
//        cell.configure(with: cards[indexPath.row])
//        return cell
//    }
    
    // MARK: Diffable Data Source
    // MARK: 5. Define the snapshot function -> we replace tableView.reloadData with this applySnapshot function...
    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<CardType, YugiohCard>()
        
        // Group items by type (1)
        let grouped = Dictionary(grouping: cards, by: { $0.cardType })
        
        // Sort types alphabetically
        let sortedTypes = grouped.keys.sorted(by: { $0.rawValue < $1.rawValue } )
        
        // Build snapshot
        snapshot.appendSections(sortedTypes)
//        for type in sortedTypes {
//            // Force unwrap!
//            snapshot.appendItems(grouped[type]!, toSection: type)
//        }
        for type in sortedTypes {
            snapshot.appendItems(grouped[type] ?? [], toSection: type)
        }
        
        // Apply to data source
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
//    func tableView(
//        _ tableView: UITableView,
//        didSelectRowAt indexPath: IndexPath
//    ) {
//        let selectedCard = cards[indexPath.row]
//
//        let detailsVC = CardDetailsViewController(
//            card: selectedCard
//        )
//
//        detailsVC.delegate = self
//        
//        navigationController?.pushViewController(
//            detailsVC,
//            animated: true
//        )
//
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
    
    // MARK: Diffable Data Source
    // MARK: 8. Replace tableView didSelectRowAt to use the data source
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedCard = dataSource.itemIdentifier(for: indexPath) else { return }
        let detailsVC = CardDetailsViewController(card: selectedCard)
        detailsVC.delegate = self
        navigationController?.pushViewController(detailsVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func addCardTapped() {
        let editor = CardEditViewController()
        editor.delegate = self

        let navigationController = UINavigationController(
            rootViewController: editor
        )

        present(navigationController, animated: true)
    }
    
}

extension ViewController: CardDetailsViewControllerDelegate {
    func cardDetailsViewController(
        _ controller: CardDetailsViewController,
        didUpdate card: YugiohCard
    ) {
        // MARK: 4. Update item by finding by ID and replace it in the array
//        if let index = cards.firstIndex(where: { $0.id == card.id }) {
//            cards[index] = card
//            tableView.reloadData()
//        }
        do {
            try store.updateYugiohCard(card)
        } catch {
            showError(error)
        }
        cards = store.loadYugiohCards()
        //tableView.reloadData()
        // MARK: Diffable Data Source
        // MARK: 7. Replace all tableView.reloadData with applySnapshot
        applySnapshot()
    }
}

extension ViewController: CardEditViewControllerDelegate {
    func cardEditViewController(
        _ controller: CardEditViewController,
        didSave card: YugiohCard
    ) {
//        if let index = cards.firstIndex(where: { $0.id == card.id }) {
//            // Update an existing card
//            // cards[index] = card
//            // MARK: 4. Use the store's functions to update the yugioh card
//            store.updateYugiohCard(card)
//        } else {
//            // Add a new card
//            //cards.append(card)
//            // MARK: 4. Use the store's functions to update the yugioh card
//            store.addYugiohCard(card)
//        }
        
        // MARK: 4. Use the store's functions to do any actions on the cards
        do {
            if cards.contains(where: { $0.id == card.id }) {
                try store.updateYugiohCard(card)
            } else {
                try store.addYugiohCard(card)
            }
        } catch {
            showError(error)
        }
        cards = store.loadYugiohCards()
//        tableView.reloadData()
        // MARK: Diffable Data Source
        // MARK: 7. Replace all tableView.reloadData with applySnapshot
        applySnapshot()
    }
    
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Couldn't save",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))

        // The edit sheet may still be on screen, so present from the topmost controller
        var top: UIViewController = self
        while let presented = top.presentedViewController { top = presented }
        top.present(alert, animated: true)
    }
}

// MARK: Diffable Data Source
// MARK: 6. We need to subclass UITableViewDiffableDataSource to make sure the section headers are there
class YugiohCardDataSource: UITableViewDiffableDataSource<CardType, YugiohCard> {
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        snapshot().sectionIdentifiers[section].rawValue
    }
}

#Preview {
    UINavigationController(rootViewController: ViewController())
}
