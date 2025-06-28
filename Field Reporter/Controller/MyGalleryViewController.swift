//
//  ViewController.swift
//  Field Reporter
//
//  Created by Tanmay Deo on 26/06/25.
//

import UIKit

class MyGalleryViewController: UIViewController {
    
    private var myGalleryTableView: UITableView = UITableView()
    private lazy var emptyDataView: EmptyDataView = EmptyDataView(inputMessage: AppConstants.emptyTableViewMessageTitle.rawValue)
    
    private var myGalleryItems: [String] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateViewVisibility()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupStyles()
        setupHierarchy()
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = AppConstants.myGalleryTableViewNavigationTitle.rawValue
        navigationController?.navigationBar.prefersLargeTitles = true
        
        //UIImage(systemName: "plus")
        let rightBarButton = UIBarButtonItem(title: "Add new" , style: .plain, target: self, action: #selector(captureVideo))
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    private func setupStyles() {
        myGalleryTableView.backgroundColor = .systemBackground
        view.backgroundColor = .systemBackground
    }
    
    private func setupHierarchy() {
        view.addSubview(myGalleryTableView)
        view.addSubview(emptyDataView)
        
        myGalleryTableView.dataSource = self
        myGalleryTableView.delegate = self
        myGalleryTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func setupConstraints() {
        myGalleryTableView.translatesAutoresizingMaskIntoConstraints = false
        emptyDataView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            myGalleryTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            myGalleryTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            myGalleryTableView.topAnchor.constraint(equalTo: view.topAnchor),
            myGalleryTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyDataView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyDataView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func updateViewVisibility() {
        let hasData = !myGalleryItems.isEmpty
        myGalleryTableView.isHidden = !hasData
        emptyDataView.isHidden = hasData
        myGalleryTableView.reloadData()
    }
}

extension MyGalleryViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myGalleryItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let commonCell = myGalleryTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        commonCell.textLabel?.text = myGalleryItems[indexPath.row]
        return commonCell
    }
}

// MARK: @objc functions
extension MyGalleryViewController {
    
    @objc func captureVideo() {
        let cameraVC = CameraViewController()
        cameraVC.delegate = self
        cameraVC.modalPresentationStyle = .fullScreen
        present(cameraVC, animated: true)
    }
}

extension MyGalleryViewController : CameraViewControllerDelegate {
    
    func cameraViewController(_ controller: CameraViewController, didFinishRecordingTo url: URL) {
        print("The video url is \(url)")
    }
    
}
