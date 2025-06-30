//
//  SaveDetailsViewController.swift
//  Field Reporter
//
//  Created by Tanmay Deo on 30/06/25.
//

import UIKit

class SaveDetailsViewController: UIViewController {
    
    // MARK: - Callback
    var onSaveDetails: ((String, String) -> Void)?
    
    // MARK: - UI Components
    private let containerView = UIView()
    
    private let closeButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let titleField = UITextField()
    private let descriptionLabel = UILabel()
    private let descriptionField = UITextView()
    private let saveButton = RedCustomButton()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addTapGestureToDismissKeyboard()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        titleField.becomeFirstResponder()
    }
}

// MARK: - Setup Methods
private extension SaveDetailsViewController {
    
    func setupView() {
        setupHierarchy()
        setupStyles()
        setupConstraints()
    }
    
    func setupHierarchy() {
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        [closeButton, titleLabel, titleField, descriptionLabel, descriptionField, saveButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview($0)
        }
    }
    
    func setupStyles() {
        // View
        view.backgroundColor = UIColor.black.withAlphaComponent(0.1) // Lighten for performance
        
        // Container View
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 16
         containerView.layer.shadowColor = UIColor.black.cgColor
         containerView.layer.shadowOpacity = 0.05
         containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
         containerView.layer.shadowRadius = 8
        
        // Close Button
        closeButton.setImage(UIImage(named: "closeIcon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        closeButton.tintColor = .label
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        
        // Title Label
        titleLabel.text = "Title"
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textColor = .label
        
        // Title Field
        titleField.placeholder = "Enter title"
        titleField.borderStyle = .roundedRect
        titleField.delegate = self
        titleField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        // Description Label
        descriptionLabel.text = "Description"
        descriptionLabel.font = .boldSystemFont(ofSize: 16)
        descriptionLabel.textColor = .label
        
        // Description Field
        descriptionField.font = .systemFont(ofSize: 15)
        descriptionField.textColor = .label
        descriptionField.backgroundColor = .secondarySystemBackground
        descriptionField.layer.cornerRadius = 8
        descriptionField.delegate = self
        
        // Save Button
        saveButton.setTitle("Save", for: .normal)
        saveButton.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
        saveButton.isEnabled = false
        saveButton.alpha = 0.5
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 16),
            closeButton.heightAnchor.constraint(equalToConstant: 16),
            
            titleLabel.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            titleField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            titleField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            titleField.heightAnchor.constraint(equalToConstant: 40),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            descriptionField.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            descriptionField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            descriptionField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            descriptionField.heightAnchor.constraint(equalToConstant: 100),
            
            saveButton.topAnchor.constraint(equalTo: descriptionField.bottomAnchor, constant: 24),
            saveButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 44),
            saveButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
}

// MARK: - Text Field & Text View Delegates
extension SaveDetailsViewController: UITextFieldDelegate, UITextViewDelegate {
    
    @objc private func textFieldDidChange() {
        validateInputFields()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        validateInputFields()
    }
    
    private func validateInputFields() {
        let isTitleEmpty = titleField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
        let isDescriptionEmpty = descriptionField.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        saveButton.isEnabled = !isTitleEmpty && !isDescriptionEmpty
        saveButton.alpha = saveButton.isEnabled ? 1.0 : 0.5
    }
}

// MARK: - Actions
private extension SaveDetailsViewController {
    
    @objc func didTapSave() {
        let titleText = titleField.text ?? ""
        let descriptionText = descriptionField.text ?? ""
        dismiss(animated: true)
        onSaveDetails?(titleText, descriptionText)
    }
    
    @objc func didTapClose() {
        dismiss(animated: true)
    }
    
    func addTapGestureToDismissKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
