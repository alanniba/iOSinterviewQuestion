//
//  PreparePageViewController.swift
//  InterViewQuestionApp
//
//  Created by haoyuan tan on 2019/1/20.
//  Copyright © 2019 haoyuan tan. All rights reserved.
//

import UIKit
import Firebase
class PreparePageViewController: UIViewController, PlayerDetailViewDelegate {

    @IBOutlet weak var contentTable: UITableView!
    @IBOutlet weak var backBut: UIButton!
    var maximizedTopAnchorConstraint : NSLayoutConstraint!
    var minimizedTopAnchorConstraint : NSLayoutConstraint!
    var zeroBotAnchorConstraint : NSLayoutConstraint!
    var zeroTopAnchorConstraint : NSLayoutConstraint!
    var questionCards = [Question]()
    @IBOutlet weak var searchTextF: UITextField!
    let playerDetailView = PlayerDetailView.initFromNib()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpContentTable()
        fetchQuestionCardFromFirestore()
        
        layoutPlayerView()
        

    }

    
    fileprivate func layoutPlayerView(){
        view.addSubview(playerDetailView)
        playerDetailView.delegate = self
        playerDetailView.backgroundColor = .white
        playerDetailView.translatesAutoresizingMaskIntoConstraints = false
        maximizedTopAnchorConstraint = playerDetailView.topAnchor.constraint(equalTo: view.topAnchor)
        playerDetailView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
        
        minimizedTopAnchorConstraint = playerDetailView.topAnchor.constraint(equalTo: view.bottomAnchor, constant: -140)

        playerDetailView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        zeroBotAnchorConstraint = playerDetailView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height)
        zeroBotAnchorConstraint.isActive = true
        playerDetailView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    func handleMinimizeView(){

        handleMiniPlayer()
    }
    func handleMixMiazeView(){
        handleMaxPlayer()
    }
    
    @objc func handleMiniPlayer(){
        maximizedTopAnchorConstraint.isActive = false
        minimizedTopAnchorConstraint.isActive = true
        zeroBotAnchorConstraint.constant = view.frame.height
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
    }
    @objc func handleMaxPlayer(){
        minimizedTopAnchorConstraint.isActive = false
        maximizedTopAnchorConstraint.isActive = true
        maximizedTopAnchorConstraint.constant = 0
        zeroBotAnchorConstraint.constant = 0
        playerDetailView.miniPlayer.alpha = 0
        playerDetailView.maxPlayer.alpha = 1
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    


    fileprivate func fetchQuestionCardFromFirestore(){
        Firestore.firestore().collection("user").getDocuments { (snapshot, err) in
            if let err = err{
                print("unable to fetch user from firestore:" ,err)
            }
            snapshot?.documents.forEach({ (documentSnapshot) in
                let questionDictionary = documentSnapshot.data()
                print(questionDictionary)
                let questionCard = Question(dictionary: questionDictionary)
                self.questionCards.append(questionCard)
            })
            self.contentTable.reloadData()
        }
    }
    
    func didClickBut(currentIndex : Int , tappingBut : Int , isSelect : Bool){
        let index = IndexPath(row: currentIndex, section: 0)
        let cell = contentTable.cellForRow(at: index) as! PrepareTableViewCell
        if isSelect {
            switch tappingBut {
            case 0:
                cell.importanceMark.alpha = 1
            case 1:
                cell.flagMark.alpha = 1
            default:
                cell.tooeasyMark.alpha = 1
            }
        } else {
            switch tappingBut {
            case 0:
                cell.importanceMark.alpha = 0.5
            case 1:
                cell.flagMark.alpha = 0.5
            default:
                cell.tooeasyMark.alpha = 0.5
            }
        }

    }
    

    
    //MARK:- setup Functions
    let cellID = "cellID"
    fileprivate func setUpContentTable(){
        contentTable.delegate = self
        contentTable.dataSource = self
        let nib = UINib(nibName: "PrepareTableViewCell", bundle: nil)
        contentTable.register(nib, forCellReuseIdentifier: cellID)
        contentTable.tableFooterView = UIView()
        contentTable.separatorStyle = .none
    }

    
    //MARK:- actions from xib

    @IBAction func backAction(_ sender: Any) {
        playerDetailView.removeFromSuperview()
        playerDetailView.player.pause()
        navigationController?.popViewController(animated: true)
        
    }

    
    

    

}


//varK:- table view delegate
extension PreparePageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! PrepareTableViewCell
        cell.selectionStyle = .none
        cell.question = questionCards[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionCards.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 210
    }
    
    
    
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        playerDetailView.question = questionCards[indexPath.row]
        playerDetailView.playlistQuestions = questionCards
        playerDetailView.currentIndex = indexPath.row
        handleMaxPlayer()
        
        
    }
}
