
//
//  CardEditViewController.swift
//  yugi oh cards
//
//  Created by Shofia Ghazali on 19/10/26.
//

import UIKit
import PhotosUI

protocol CardEditViewControllerDelegate: AnyObject {
    func cardEditViewController(
        _ controller: CardEditViewController,
        didSave card: YugiohCard
    )
}

class CardEditViewController: UITableViewController {
    
    var card: YugiohCard?
    weak var delegate: CardEditViewControllerDelegate?
    
    /*
     Card Number: LOB-005
     Attribute: DARK
     Level: 7
     Monster Type: Spellcaster
     ATK: 2500
     DEF: 2100
     */
    
    // MARK: UI THINGS
    
    // =========================================================
    // NUMBER PICKER — STEP 1: CREATE THE PICKER
    // =========================================================
    // UIPickerView() creates the wheel.
    // We will connect it to the Level text field later.
    private let levelPicker = UIPickerView()
    
    // Your other pickers
    private let attributePicker = UIPickerView()
    private let monsterTypePicker = UIPickerView()
    private let cardTypePicker = UIPickerView()
    private let propertyPicker = UIPickerView()
    
    
    // MARK: Text fields for picker
    
    private let attributeField = UITextField()
    private let levelField = UITextField()
    private let monsterTypeField = UITextField()
    private let cardTypeField = UITextField()
    private let propertyField = UITextField()
    
    
    // MARK: User Input
    
    private let nameField = UITextField()
    private let attackField = UITextField()
    private let defenseField = UITextField()
    private let cardNumberField = UITextField()
    private let descriptionView = UITextView()
    
    
    // MARK: Preselected attributes
    
    private var selectedCardType: CardType = .monster
    private var selectedAttribute: CardAttribute = .dark
    private var selectedProperty: SpellTrapProperty = .normal
    private var selectedMonsterType: MonsterType = .spellcaster
    private var selectedImageName: String?
    
    // NUMBER PICKER — STEP 2: STORE THE SELECTED NUMBER
    // This variable remembers the number selected by the user.
    private var selectedLevel = 1
    
    
    // MARK: Properties for the rows
    
    private let attributes = CardAttribute.allCases
    private let cardTypes = CardType.allCases
    private let monsterTypes = MonsterType.allCases
    
    // NUMBER PICKER — STEP 3: CREATE THE DATA
    // Array indices are 0...11, but the actual values are 1...12.
    // The picker will use this array to display the numbers.
    private let levels = Array(1...12)
    // Check if card type has spell/trap property
    private var availableProperties: [SpellTrapProperty] {
        switch selectedCardType {
        case .monster:
            return []
            
        case .spell:
            return SpellTrapProperty.allCases.filter {
                $0 != .counter
            }
            
        case .trap:
            return [.normal, .continuous, .counter]
        }
    }
    
    
    private enum Section: Int, CaseIterable {
        case basic
        case monster
        case stats
        case description
    }
    
    
    init(card: YugiohCard? = nil) {
        self.card = card
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTextFields()
        
        // =====================================================
        // NUMBER PICKER — STEP 5: SET DATA SOURCE AND DELEGATE
        // =====================================================
        // dataSource answers structural questions:
        // How many rows and columns does the picker have?
        //
        // delegate provides the row titles and handles selection.
        
        configurePickers()
        populateFields()
        chooseImageButton.addTarget(
            self,
            action: #selector(imageOptionsTapped),
            for: .touchUpInside
        )
        
        // Display the fields appropriate for the selected card type
        updateVisibleFields()
    }
    
    fileprivate func configurePickers() {
        
        // =====================================================
        // NUMBER PICKER — STEP 4: CONNECT PICKER TO TEXT FIELD
        // =====================================================
        // When levelField is tapped, iOS shows levelPicker
        // instead of the normal keyboard.
        //
        // inputView controls what appears when the field
        // becomes the active editing field.
        // MARK: Attach picker toolbars
        
        let pickerFieldPairs: [(UITextField, UIPickerView)] = [
            (cardTypeField, cardTypePicker),
            (attributeField, attributePicker),
            (levelField, levelPicker),
            (monsterTypeField, monsterTypePicker),
            (propertyField, propertyPicker)
        ]
        
        for (field, picker) in pickerFieldPairs {
            field.inputView = picker
            field.inputAccessoryView = createPickerToolbar()
            field.tintColor = .clear
            
            picker.dataSource = self
            picker.delegate = self
        }
    }
    
    
    
    // MARK: SETTING UP THE UI
    fileprivate func configureNavigationBar() {
        title = card == nil ? "Add Card" : "Edit Card"
        tableView.backgroundColor = .systemGroupedBackground
        
        // Cancel button on the left
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        // Save button on the right
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(saveTapped)
        )
    }
    
    fileprivate func configureTextFields() {
        // MARK: Configure text fields
        
        configureField(nameField, placeholder: "Card name")
        configureField(cardNumberField, placeholder: "e.g. LOB-005")
        configureField(cardTypeField, placeholder: "Card type")
        configureField(attributeField, placeholder: "Attribute")
        configureField(levelField, placeholder: "Level")
        configureField(monsterTypeField, placeholder: "Monster type")
        configureField(propertyField, placeholder: "Spell / Trap property")
        
        configureField(
            attackField,
            placeholder: "ATK",
            keyboard: .numberPad
        )
        
        configureField(
            defenseField,
            placeholder: "DEF",
            keyboard: .numberPad
        )
        
        descriptionView.font = .systemFont(ofSize: 16)
        descriptionView.layer.cornerRadius = 8
        descriptionView.backgroundColor = .secondarySystemBackground
    }
    
    fileprivate func populateFields() {
        // MARK: Populate fields when editing an existing card
        
        if let card {
            
            selectedImageName = card.imageURLString

            nameField.text = card.name
            cardNumberField.text = card.cardNumber
            
            selectedCardType = card.cardType
            cardTypeField.text = card.cardType.rawValue
            
            selectedAttribute = card.attribute ?? .dark
            attributeField.text = card.attribute?.rawValue
            
            selectedLevel = card.level ?? 1
            levelField.text = card.level.map { "\($0)" }
            
            if let monsterType = card.monsterType {
                selectedMonsterType = monsterType
                monsterTypeField.text = monsterType.rawValue
            }
            selectedProperty = card.property ?? .normal
            propertyField.text = selectedProperty.rawValue
            attackField.text = card.atk.map { "\($0)" }
            defenseField.text = card.def.map { "\($0)" }
            
            descriptionView.text = card.description
        } else {
            levelField.text = "\(selectedLevel)"
        }
        
        let initialLevelRow = selectedLevel - 1
        
        levelPicker.selectRow(
            initialLevelRow,
            inComponent: 0,
            animated: false
        )
    }
    
    // MARK: Table view selection
    
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        print("Tapped row: \(indexPath)")
    }
    
    
    // MARK: Configure text fields
    
    private func configureField(
        _ field: UITextField,
        placeholder: String,
        keyboard: UIKeyboardType = .default
    ) {
        field.placeholder = placeholder
        field.borderStyle = .none
        field.textAlignment = .right
        field.keyboardType = keyboard
        field.clearButtonMode = .whileEditing
        field.translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    // MARK: Creating picker toolbar
    
    private func createPickerToolbar() -> UIToolbar {
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissPicker)
        )
        
        let flexibleSpace = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        
        toolbar.setItems(
            [flexibleSpace, doneButton],
            animated: false
        )
        
        return toolbar
    }
    
    
    // MARK: Update visible fields
    
    private func updateVisibleFields() {
        tableView.reloadData()
    }
    
    
    // MARK: Table view sections
    
    override func numberOfSections(
        in tableView: UITableView
    ) -> Int {
        return 4
    }
    
    
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        
        switch Section(rawValue: section) {
        case .basic:
            return 4
            
        case .monster:
            return selectedCardType == .monster ? 3 : 1
            
        case .stats:
            return selectedCardType == .monster ? 2 : 0
            
        case .description:
            return 1
            
        case nil:
            return 0
        }
    }
    
    
    // MARK: Title header for each section
    
    override func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        
        switch section {
            
        case 0:
            return "Card Information"
            
        case 1:
            return selectedCardType == .monster
            ? "Monster Details"
            : "Spell / Trap Details"
            
        case 2:
            return "Battle Stats"
            
        case 3:
            return "Description"
            
        default:
            return nil
        }
    }
    
    
    // MARK: Creating different sections
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        switch indexPath.section {
            
            // SECTION 0: Card Information
        case 0:
            
            switch indexPath.row {
                
            case 0:
                return makeFieldCell(
                    title: "Card Name",
                    field: nameField
                )
                
            case 1:
                return makeFieldCell(
                    title: "Card Number",
                    field: cardNumberField
                )
                
            case 3:
                let cell = UITableViewCell()
                cell.contentView.addSubview(chooseImageButton)

                chooseImageButton.translatesAutoresizingMaskIntoConstraints = false

                NSLayoutConstraint.activate([
                    chooseImageButton.leadingAnchor.constraint(
                        equalTo: cell.contentView.leadingAnchor,
                        constant: 16
                    ),
                    chooseImageButton.trailingAnchor.constraint(
                        equalTo: cell.contentView.trailingAnchor,
                        constant: -16
                    ),
                    chooseImageButton.topAnchor.constraint(
                        equalTo: cell.contentView.topAnchor,
                        constant: 8
                    ),
                    chooseImageButton.bottomAnchor.constraint(
                        equalTo: cell.contentView.bottomAnchor,
                        constant: -8
                    )
                ])

                return cell
                
            default:
                return makeFieldCell(
                    title: "Card Type",
                    field: cardTypeField
                )
            }
            
            
            // SECTION 1: Monster or Spell/Trap details
        case 1:
            
            if selectedCardType == .monster {
                
                switch indexPath.row {
                    
                case 0:
                    return makeFieldCell(
                        title: "Attribute",
                        field: attributeField
                    )
                    
                case 1:
                    return makeFieldCell(
                        title: "Level",
                        field: levelField
                    )
                    
                default:
                    return makeFieldCell(
                        title: "Monster Type",
                        field: monsterTypeField
                    )
                }
            }
            
            return makeFieldCell(
                title: "Property",
                field: propertyField
            )
            
            
            // SECTION 2: Battle stats
        case 2:
            
            return makeFieldCell(
                title: indexPath.row == 0 ? "ATK" : "DEF",
                field: indexPath.row == 0
                ? attackField
                : defenseField
            )
            
            
            // SECTION 3: Description
        case 3:
            
            let cell = UITableViewCell()
            
            descriptionView.translatesAutoresizingMaskIntoConstraints = false
            
            cell.contentView.addSubview(descriptionView)
            
            NSLayoutConstraint.activate([
                
                descriptionView.leadingAnchor.constraint(
                    equalTo: cell.contentView.leadingAnchor,
                    constant: 12
                ),
                
                descriptionView.trailingAnchor.constraint(
                    equalTo: cell.contentView.trailingAnchor,
                    constant: -12
                ),
                
                descriptionView.topAnchor.constraint(
                    equalTo: cell.contentView.topAnchor,
                    constant: 8
                ),
                
                descriptionView.bottomAnchor.constraint(
                    equalTo: cell.contentView.bottomAnchor,
                    constant: -8
                ),
                
                descriptionView.heightAnchor.constraint(
                    greaterThanOrEqualToConstant: 100
                )
            ])
            
            cell.selectionStyle = .none
            return cell
            
            
        default:
            return UITableViewCell()
        }
    }
    
    
    // MARK: Create a cell with a label and text field
    
    private func makeFieldCell(
        title: String,
        field: UITextField
    ) -> UITableViewCell {
        
        let cell = UITableViewCell(
            style: .default,
            reuseIdentifier: nil
        )
        
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 16)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        field.translatesAutoresizingMaskIntoConstraints = false
        
        cell.contentView.addSubview(label)
        cell.contentView.addSubview(field)
        
        NSLayoutConstraint.activate([
            
            label.leadingAnchor.constraint(
                equalTo: cell.contentView.leadingAnchor,
                constant: 16
            ),
            
            label.centerYAnchor.constraint(
                equalTo: cell.contentView.centerYAnchor
            ),
            
            field.leadingAnchor.constraint(
                greaterThanOrEqualTo: label.trailingAnchor,
                constant: 8
            ),
            
            field.trailingAnchor.constraint(
                equalTo: cell.contentView.trailingAnchor,
                constant: -16
            ),
            
            field.centerYAnchor.constraint(
                equalTo: cell.contentView.centerYAnchor
            ),
            
            field.widthAnchor.constraint(
                greaterThanOrEqualToConstant: 100
            )
        ])
        
        cell.selectionStyle = .none
        return cell
    }
    
    
    // MARK: Dismiss picker
    
    @objc private func dismissPicker() {
        view.endEditing(true)
    }
    
    
    // MARK: Cancel button
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    
    private let chooseImageButton: UIButton = {
        var config = UIButton.Configuration.tinted()
        config.title = "Choose Card Image"
        config.image = UIImage(systemName: "photo")
        config.imagePadding = 8

        let button = UIButton(configuration: config)
        return button
    }()
    
    // MARK: Save button
    
    
    @objc private func saveTapped() {
        let name = nameField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let cardNumber = cardNumberField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !name.isEmpty else {
            showValidationAlert(
                message: "Please enter a card name."
            )
            return
        }
        
        // MARK: 3. Created new instance with updated values
        let savedCard = YugiohCard(
            id: card?.id ?? UUID(),
            name: name,
            cardType: selectedCardType,
            description: descriptionView.text ?? "",
            cardNumber: cardNumber,
            imageURLString: selectedImageName,
            attribute: selectedCardType == .monster
                ? selectedAttribute
                : nil,
            level: selectedCardType == .monster
                ? selectedLevel
                : nil,
            monsterType: selectedCardType == .monster
                ? selectedMonsterType
                : nil,
            atk: selectedCardType == .monster
                ? Int(attackField.text ?? "")
                : nil,
            def: selectedCardType == .monster
                ? Int(defenseField.text ?? "")
                : nil,
            property: selectedCardType == .monster
                ? nil
                : availableProperties.first {
                    $0.rawValue == propertyField.text
                }
        )

        delegate?.cardEditViewController(
            self,
            didSave: savedCard
        )

        dismiss(animated: true)
    }

    
    private func showValidationAlert(message: String) {
        let alert = UIAlertController(
            title: "Missing Information",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(title: "OK", style: .default)
        )
        
        present(alert, animated: true)
    }
    
}


// =============================================================
// NUMBER PICKER — STEP 7: IMPLEMENT PICKER DATA SOURCE/DELEGATE
// =============================================================

extension CardEditViewController:
    UIPickerViewDataSource,
    UIPickerViewDelegate {


    // STEP 7A: How many columns?
    // A column is a vertical wheel.
    // We only need one wheel of numbers.

    func numberOfComponents(
        in pickerView: UIPickerView
    ) -> Int {
        return 1
    }


    // STEP 7B: How many rows?
    // The number of rows matches the number of items in the array.
    //
    // levels.count is 12, so the picker has 12 rows.

    func pickerView(
        _ pickerView: UIPickerView,
        numberOfRowsInComponent component: Int
    ) -> Int {

        if pickerView == attributePicker {
            return attributes.count

        } else if pickerView == cardTypePicker {
            return cardTypes.count

        } else if pickerView == levelPicker {
            // NUMBER PICKER: return the number of available numbers.
            return levels.count

        } else if pickerView == monsterTypePicker {
            return monsterTypes.count

        } else if pickerView == propertyPicker {
            return availableProperties.count
        }

        return 0
    }


    // STEP 7C: What text appears in each row?
    // The row parameter is an array index.
    // Convert the number to String because the picker displays text.

    func pickerView(
        _ pickerView: UIPickerView,
        titleForRow row: Int,
        forComponent component: Int
    ) -> String? {

        if pickerView == attributePicker {
            return attributes[row].rawValue

        } else if pickerView == cardTypePicker {
            return cardTypes[row].rawValue

        } else if pickerView == levelPicker {
            // NUMBER PICKER: show the number at this array index.
            return "\(levels[row])"

        } else if pickerView == monsterTypePicker {
            return monsterTypes[row].rawValue

        } else if pickerView == propertyPicker {
            return availableProperties[row].rawValue
        }

        return nil
    }


    // STEP 7D: What happens when the user selects a row?
    // This method runs whenever the selected wheel row changes.

    func pickerView(
        _ pickerView: UIPickerView,
        didSelectRow row: Int,
        inComponent component: Int
    ) {

        if pickerView == attributePicker {

            let attribute = attributes[row]
            attributeField.text = attribute.rawValue
            selectedAttribute = attribute

        } else if pickerView == cardTypePicker {

            let cardType = cardTypes[row]

            cardTypeField.text = cardType.rawValue
            selectedCardType = cardType

            propertyPicker.reloadAllComponents()
            updateVisibleFields()

        } else if pickerView == levelPicker {

            // NUMBER PICKER — STEP 8: HANDLE THE SELECTED NUMBER

            // 1. Get the actual number from the array.
            let level = levels[row]

            // 2. Store it for later use when saving the card.
            selectedLevel = level

            // 3. Update the text field to show the selection.
            levelField.text = "\(level)"

        } else if pickerView == monsterTypePicker {

            let monsterType = monsterTypes[row]
            monsterTypeField.text = monsterType.rawValue
            selectedMonsterType = monsterType

        } else if pickerView == propertyPicker {

            let property = availableProperties[row]

            propertyField.text = property.rawValue
            selectedProperty = property
        }
    }
    
    @objc private func imageOptionsTapped() {
        let alert = UIAlertController(
            title: "Card Artwork",
            message: "Choose how you want to add an image.",
            preferredStyle: .actionSheet
        )

        alert.addAction(
            UIAlertAction(title: "Photo Library", style: .default) {
                [weak self] _ in
                self?.openPhotoLibrary()
            }
        )

        alert.addAction(
            UIAlertAction(title: "Take Photo", style: .default) {
                [weak self] _ in
                self?.openCamera()
            }
        )

        alert.addAction(
            UIAlertAction(title: "Search Google Images", style: .default) {
                [weak self] _ in
                self?.searchGoogleImages()
            }
        )

        alert.addAction(
            UIAlertAction(title: "Cancel", style: .cancel)
        )

        if let popover = alert.popoverPresentationController {
            popover.sourceView = chooseImageButton
            popover.sourceRect = chooseImageButton.bounds
        }

        present(alert, animated: true)
    }
    
    private func searchGoogleImages() {
        let query = nameField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty == false
            ? nameField.text!
            : "Yu-Gi-Oh card artwork"

        var components = URLComponents(
            string: "https://www.google.com/search"
        )

        components?.queryItems = [
            URLQueryItem(name: "tbm", value: "isch"),
            URLQueryItem(name: "q", value: query)
        ]

        guard let url = components?.url else { return }

        UIApplication.shared.open(url)
    }
}


extension CardEditViewController: PHPickerViewControllerDelegate,
                                  UIImagePickerControllerDelegate,
                                  UINavigationControllerDelegate {

    private func saveSelectedImage(_ image: UIImage) {
        guard let filename = CardImageStore.save(image) else {
            showValidationAlert(message: "Could not save the selected image.")
            return
        }

        selectedImageName = filename
        chooseImageButton.setTitle("Change Card Image", for: .normal)
    }

    func openPhotoLibrary() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    func picker(
        _ picker: PHPickerViewController,
        didFinishPicking results: [PHPickerResult]
    ) {
        dismiss(animated: true)

        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else {
            return
        }

        provider.loadObject(ofClass: UIImage.self) {
            [weak self] image, error in

            guard let image = image as? UIImage else { return }

            DispatchQueue.main.async {
                self?.saveSelectedImage(image)
            }
        }
    }

    func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showValidationAlert(
                message: "A camera is not available on this device."
            )
            return
        }

        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        dismiss(animated: true)

        guard let image = info[.originalImage] as? UIImage else {
            return
        }

        saveSelectedImage(image)
    }

    func imagePickerControllerDidCancel(
        _ picker: UIImagePickerController
    ) {
        dismiss(animated: true)
    }
}

#Preview {
    UINavigationController(
        rootViewController: CardEditViewController()
    )
}

