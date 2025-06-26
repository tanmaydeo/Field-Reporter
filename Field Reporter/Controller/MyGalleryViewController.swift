//
//  ViewController.swift
//  Field Reporter
//
//  Created by Tanmay Deo on 26/06/25.
//

import UIKit

class MyGalleryViewController: UIViewController {
    
    @IBOutlet weak var myGalleryTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStyles()
        setupTableView()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = AppConstants.myGalleryTableViewNavigationTitle.rawValue
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupTableView() {
        myGalleryTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func setupStyles() {
        myGalleryTableView.backgroundColor = .systemBackground
    }
}

extension MyGalleryViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let commonCell = myGalleryTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        commonCell.textLabel?.text = "Hello"
        return commonCell
    }
}

