//
//  DownloadsViewController.swift
//  InterViewQuestionApp
//
//  Created by haoyuan tan on 2019/1/26.
//  Copyright © 2019 haoyuan tan. All rights reserved.
//

import UIKit

class DownloadsViewController: UIViewController {

    @IBOutlet weak var contantTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()

    }
    
    
    let cellID = "cellID"
    fileprivate func setupTableView(){
        let nib = UINib(nibName: "PrepareTableViewCell", bundle: nil)
        contantTableView.register(nib, forCellReuseIdentifier: cellID)
        contantTableView.delegate = self
        contantTableView.dataSource = self
        contantTableView.tableFooterView = UIView()
        contantTableView.separatorStyle = .none
    }
    @IBAction func handleBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}

extension DownloadsViewController: UITableViewDelegate , UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! PrepareTableViewCell
        cell.selectionStyle = .none
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 210
    }
}
