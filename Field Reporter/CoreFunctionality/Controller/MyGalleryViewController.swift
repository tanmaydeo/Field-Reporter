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
    private var allGalleryItems: [VideoModel] = []
    
    private let searchController = UISearchController()
    private var debounceWorkItem: DispatchWorkItem?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        myGalleryItems = videoRecordManager.fetch()
        allGalleryItems = myGalleryItems
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
        
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search for video title"
        searchController.obscuresBackgroundDuringPresentation = false
        
        let button = UIButton(type: .system)
        let image = UIImage(named: "addIcon")?.withRenderingMode(.alwaysOriginal)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(captureVideo), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 30),
            button.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        let barButtonItem = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItem = barButtonItem
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(myGalleryItems[indexPath.row].path)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print(videoRecordManager.delete(id: myGalleryItems[indexPath.row].id))
            refreshTableView()
        }
    }
    
}

extension MyGalleryViewController : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !query.isEmpty else {
            myGalleryItems = allGalleryItems
            updateViewVisibility()
            return
        }
        debounceWorkItem?.cancel()
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.performSearch(query: query)
        }
        debounceWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }
    
    private func performSearch(query: String) {
        myGalleryItems = allGalleryItems.filter {
            $0.title.lowercased().contains(query.lowercased())
        }
        updateViewVisibility()
    }
    
}

// MARK: @objc functions
extension MyGalleryViewController {
    
    @objc func captureVideo() {
        let cameraVC = CameraViewController()
        self.navigationController?.pushViewController(cameraVC, animated: true)
    }
    
    private func refreshTableView() {
        DispatchQueue.main.async {
            self.allGalleryItems = self.videoRecordManager.fetch()
            self.myGalleryItems = self.allGalleryItems
            self.updateViewVisibility()
        }
    }
}
