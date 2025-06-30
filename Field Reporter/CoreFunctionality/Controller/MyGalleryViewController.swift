//
//  ViewController.swift
//  Field Reporter
//
//  Created by Tanmay Deo on 26/06/25.
//

import UIKit

class MyGalleryViewController: UIViewController {
    
    private var myGalleryTableView: UITableView = UITableView()
    private lazy var emptyDataView = EmptyDataView(inputMessage: AppConstants.emptyTableViewMessageTitle.rawValue)
    
    private let viewModel = MyGalleryViewModel()
    private let searchController = UISearchController()
    private var debounceWorkItem: DispatchWorkItem?
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        viewModel.loadVideos()
        updateViewVisibility()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStyles()
        setupHierarchy()
        setupConstraints()
    }
    
    // MARK: - UI Setup
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    private func setupStyles() {
        view.backgroundColor = .systemBackground
        myGalleryTableView.backgroundColor = .systemBackground
    }
    
    private func setupHierarchy() {
        view.addSubview(myGalleryTableView)
        view.addSubview(emptyDataView)
        
        myGalleryTableView.dataSource = self
        myGalleryTableView.delegate = self
        myGalleryTableView.separatorStyle = .none
        myGalleryTableView.register(VideoTableViewCell.self, forCellReuseIdentifier: AppConstants.videoCellReusableIdentifier.rawValue)
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
        let hasData = viewModel.numberOfVideos() > 0
        myGalleryTableView.isHidden = !hasData
        emptyDataView.isHidden = hasData
        myGalleryTableView.reloadData()
    }
}

// MARK: - TableView DataSource & Delegate
extension MyGalleryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfVideos()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AppConstants.videoCellReusableIdentifier.rawValue, for: indexPath) as? VideoTableViewCell else {
            return UITableViewCell()
        }
        
        let video = viewModel.video(at: indexPath.row)
        cell.selectionStyle = .none
        cell.configureCell(video)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let video = viewModel.video(at: indexPath.row)
        print(video.path)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.deleteVideo(at: indexPath.row)
            updateViewVisibility()
        }
    }
}

// MARK: - Search
extension MyGalleryViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text else {
            viewModel.loadVideos()
            updateViewVisibility()
            return
        }
        
        debounceWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.viewModel.search(for: query)
            DispatchQueue.main.async {
                self?.updateViewVisibility()
            }
        }
        debounceWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }
}

// MARK: - Navigation
extension MyGalleryViewController {
    @objc func captureVideo() {
        let cameraVC = CameraViewController()
        navigationController?.pushViewController(cameraVC, animated: true)
    }
}
