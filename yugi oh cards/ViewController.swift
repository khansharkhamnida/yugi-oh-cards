//
//  ViewController.swift
//  yugi oh cards
//
//  Created by Shofia Ghazali on 19/10/26.
//

import UIKit

//scenedelegate -> wraps in navigation controller -> viewcontroller -> tableview (card list) on home page -> push controller (when one of them in the list is tapped) ->tableview for details page -> present controller (inside a button) tableview for edit page
class ViewController: UIViewController,
                      UITableViewDataSource,
                      UITableViewDelegate  {

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
        
        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(
            CardTableViewCell.self,
            forCellReuseIdentifier: CardTableViewCell.identifier
        )
    }
    
    //cardsList
    var cards: [YugiohCard] = [
        YugiohCard(
            name: "Dark Magician",
            cardType: .monster,
            description: "The ultimate wizard in terms of attack and defense.",
            cardNumber: "LOB-005",
            imageURLString: "dark-magician",
            attribute: .dark,
            level: 7,
            monsterType: .aqua,
            atk: 2500,
            def: 2100
        ),
        YugiohCard(
            name: "Blue-Eyes White Dragon",
            cardType: .monster,
            description: "This legendary dragon is a powerful engine of destruction.",
            cardNumber: "LOB-001",
            attribute: .light,
            level: 8,
            monsterType: .dragon,
            atk: 3000,
            def: 2500
        ),
        YugiohCard(
            name: "Monster Reborn",
            cardType: .spell,
            description: "Special Summon 1 monster from either GY.",
            cardNumber: "LOB-118",
            property: .normal
        )
    ]
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
        setUpUI()
        setUpLayout()
    }
    
    //tableView for the card list
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return cards.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: CardTableViewCell.identifier,
            for: indexPath
        ) as! CardTableViewCell

        cell.configure(with: cards[indexPath.row])
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let selectedCard = cards[indexPath.row]

        let detailsVC = CardDetailsViewController(
            card: selectedCard
        )

        detailsVC.delegate = self
        
        navigationController?.pushViewController(
            detailsVC,
            animated: true
        )

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
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index] = card
            tableView.reloadData()
        }
    }
}

extension ViewController: CardEditViewControllerDelegate {
    func cardEditViewController(
        _ controller: CardEditViewController,
        didSave card: YugiohCard
    ) {
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            // Update an existing card
            cards[index] = card
        } else {
            // Add a new card
            cards.append(card)
        }

        tableView.reloadData()
    }
}

// UIKit Preview wrapper
#Preview {
    UINavigationController(rootViewController: ViewController())
}

