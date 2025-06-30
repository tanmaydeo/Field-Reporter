//
//  MyGalleryViewController.swift
//  Field Reporter
//
//  Created by Tanmay Deo on 26/06/25.
//

import UIKit
import AVKit

class MyGalleryViewController: UIViewController {
    
    // MARK: - UI Components
    private let myGalleryTableView = UITableView()
    private lazy var emptyDataView = EmptyDataView(inputMessage: AppConstants.emptyTableViewMessageTitle.rawValue)
    private let searchController = UISearchController()
    
    // MARK: - Properties
    private let viewModel = MyGalleryViewModel()
    private var debounceWorkItem: DispatchWorkItem?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStyles()
        setupHierarchy()
        setupConstraints()
        configureTableView()
        configureSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        viewModel.loadVideos()
        updateViewVisibility()
    }
    
    // MARK: - Setup Methods
    private func setupNavigationBar() {
        navigationItem.title = AppConstants.myGalleryTableViewNavigationTitle.rawValue
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isHidden = false
        navigationItem.searchController = searchController
        
        let addButton = UIButton(type: .system)
        addButton.setImage(UIImage(named: "addIcon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        addButton.addTarget(self, action: #selector(captureVideo), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addButton.widthAnchor.constraint(equalToConstant: 30),
            addButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addButton)
    }
    
    private func setupStyles() {
        view.backgroundColor = .systemBackground
        myGalleryTableView.backgroundColor = .systemBackground
    }
    
    private func setupHierarchy() {
        view.addSubview(myGalleryTableView)
        view.addSubview(emptyDataView)
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
    
    private func configureTableView() {
        myGalleryTableView.dataSource = self
        myGalleryTableView.delegate = self
        myGalleryTableView.separatorStyle = .none
        myGalleryTableView.register(VideoTableViewCell.self, forCellReuseIdentifier: AppConstants.videoCellReusableIdentifier.rawValue)
    }
    
    private func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search for video title"
        searchController.obscuresBackgroundDuringPresentation = false
    }
    
    private func updateViewVisibility() {
        let hasData = viewModel.numberOfVideos() > 0
        myGalleryTableView.isHidden = !hasData
        emptyDataView.isHidden = hasData
        myGalleryTableView.reloadData()
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension MyGalleryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfVideos()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: AppConstants.videoCellReusableIdentifier.rawValue,
            for: indexPath
        ) as? VideoTableViewCell else {
            return UITableViewCell()
        }
        
        let video = viewModel.video(at: indexPath.row)
        cell.configureCell(video)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let video = viewModel.video(at: indexPath.row)
        let safeFileName = URL(string: video.fileName)?.lastPathComponent ?? video.fileName
        let fileURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent(safeFileName)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            
            let playerManager = VideoPlayerManager()
            playerManager.prepare(with: fileURL)
            
            guard let player = playerManager.player else {
                return
            }
            
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            present(playerViewController, animated: true) {
                player.play()
            }
            
        } else {
            let alert = UIAlertController(
                title: "File Not Found",
                message: "The video file could not be located.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let video = viewModel.video(at: indexPath.row)
            let fileURL = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first!
                .appendingPathComponent(video.fileName)
            try? FileManager.default.removeItem(at: fileURL)
            viewModel.deleteVideo(at: indexPath.row)
            updateViewVisibility()
        }
    }
}

// MARK: - UISearchResultsUpdating
extension MyGalleryViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text else {
            viewModel.loadVideos()
            updateViewVisibility()
            return
        }
        
        debounceWorkItem?.cancel()
        debounceWorkItem = DispatchWorkItem { [weak self] in
            self?.viewModel.search(for: query)
            DispatchQueue.main.async {
                self?.updateViewVisibility()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: debounceWorkItem!)
    }
}

// MARK: - Navigation
extension MyGalleryViewController {
    @objc private func captureVideo() {
        let cameraVC = CameraViewController()
        navigationController?.pushViewController(cameraVC, animated: true)
    }
}
