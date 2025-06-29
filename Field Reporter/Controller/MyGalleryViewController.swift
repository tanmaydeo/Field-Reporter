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
    
    private let videoRecordManager : VideoRecordManager = VideoRecordManager()
    
    private var myGalleryItems: [VideoModel] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        myGalleryItems = videoRecordManager.fetch()
        updateViewVisibility()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStyles()
        setupHierarchy()
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = AppConstants.myGalleryTableViewNavigationTitle.rawValue
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isHidden = false
        
        let rightBarButton = UIBarButtonItem(title: AppConstants.addNewVideoTitle.rawValue , style: .plain, target: self, action: #selector(captureVideo))
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
        myGalleryTableView.register(VideoTableViewCell.self, forCellReuseIdentifier: AppConstants.videoCellReusableIdentifier.rawValue)
        myGalleryTableView.separatorStyle = .none
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
        guard let commonCell = myGalleryTableView.dequeueReusableCell(withIdentifier: AppConstants.videoCellReusableIdentifier.rawValue, for: indexPath) as? VideoTableViewCell else {
            return UITableViewCell()
        }
        commonCell.selectionStyle = .none
        commonCell.configureCell(myGalleryItems[indexPath.row])
        return commonCell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print(videoRecordManager.delete(id: myGalleryItems[indexPath.row].id))
            refreshTableView()
        }
    }
    
}

// MARK: @objc functions
extension MyGalleryViewController {
    
    @objc func captureVideo() {
        let cameraVC = VideoPreviewViewController()
        self.navigationController?.pushViewController(cameraVC, animated: true)
    }
    
    private func refreshTableView() {
        DispatchQueue.main.async {
            self.myGalleryItems = self.videoRecordManager.fetch()
            self.myGalleryTableView.reloadData()
            self.updateViewVisibility()
        }
    }
}
