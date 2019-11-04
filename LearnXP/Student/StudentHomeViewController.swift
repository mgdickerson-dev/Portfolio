//
//  HomeViewController.swift
//  LearnXP
//
//  Created by Michael Dickerson on 7/26/19.
//  Copyright © 2019 Michael Dickerson. All rights reserved.
//

import UIKit
import Firebase

class StudentHomeViewController: UIViewController {

    @IBOutlet weak var assignmentLabel: UILabel!
    @IBOutlet weak var experienceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var experienceBar: UIProgressView!
    @IBOutlet weak var assignmentsBar: UIProgressView!
    @IBOutlet weak var syllabusButton: UIView!
    @IBOutlet weak var assignmentsButton: UIView!
    @IBOutlet weak var leaderboardButton: UIView!
    @IBOutlet weak var logOutButton: UIView!
    @IBOutlet weak var messageButton: UIView!
    @IBOutlet weak var navDrawer: UIView!
    @IBOutlet weak var menuOpenButton: UIView!
    @IBOutlet weak var menuCloseButton: UIView!
    @IBOutlet weak var studentIcon: UIButton!
    @IBOutlet weak var badge1: UIImageView!
    @IBOutlet weak var badge2: UIImageView!
    @IBOutlet weak var badge3: UIImageView!
    
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser
    var classCode = ""
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        hideMenus()
        populateUser()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setGestures()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let tag = touch?.view?.tag
        if tag == 1{return}
        else{
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [],
                           animations: {
                            self.navDrawer.alpha = 0
            },
                           completion: nil
            )
        }
    }
    
    func populateUser(){
        let studentRef = db.collection("users").document((user?.uid)!)
        studentRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.badge1.image = UIImage(named: "Add.png")
                self.badge2.image = UIImage(named: "Add.png")
                self.badge3.image = UIImage(named: "Add.png")
                let first: String = document.get("first_name") as! String
                let last: String = document.get("last_name") as! String
                let experience: Int = document.get("experience") as! Int
                let assignments: Int = document.get("assignments_completed") as! Int
                let icon = document.get("icon") as! String
                self.classCode = document.get("class_code") as! String
                self.studentIcon.setImage( UIImage(named: icon), for: .normal)
                self.nameLabel.text = "\(first) \(last)"
                let levelStruct = LevelStruct(experience: experience)
                self.levelLabel.text = "Level: \(levelStruct.setLevel())"
                self.experienceLabel.text = levelStruct.getExperienceToLevel()
                self.experienceBar.progress = Float(levelStruct.setExperience())
                let classRef = self.db.collection("classes").document(self.classCode)
                classRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let total: Int = document.get("total_assignments") as! Int
                        self.assignmentsBar.progress = Float(Double(assignments)/Double(total))
                        self.assignmentLabel.text = "Assignments Completed: \(assignments)/\(total)"
                        if assignments == total{
                            self.badge1.image = UIImage(named: "CompleteBadge.png")
                        }
                        if levelStruct.setLevel() >= 3{
                            self.badge2.image = UIImage(named: "PencilBadge.png")
                        }
                        if levelStruct.setLevel() >= 5{
                            self.badge3.image = UIImage(named: "RewardBadge.png")
                        }
                    }}
            }}
    }
    
    func setGestures(){
        let gestureOpen = UITapGestureRecognizer(target: self, action:  #selector(self.openMenu(sender:)))
        self.menuOpenButton.addGestureRecognizer(gestureOpen)
        let gestureClose = UITapGestureRecognizer(target: self, action:  #selector(self.closeMenu(sender:)))
        self.menuCloseButton.addGestureRecognizer(gestureClose)
        let gestureSyll = UITapGestureRecognizer(target: self, action:  #selector(self.goToSyllabus(sender:)))
        self.syllabusButton.addGestureRecognizer(gestureSyll)
        let gestureAssign = UITapGestureRecognizer(target: self, action:  #selector(self.goToAssignments(sender:)))
        self.assignmentsButton.addGestureRecognizer(gestureAssign)
        let gestureLead = UITapGestureRecognizer(target: self, action:  #selector(self.goToLeaderboard(sender:)))
        self.leaderboardButton.addGestureRecognizer(gestureLead)
        let gestureMess = UITapGestureRecognizer(target: self, action:  #selector(self.goToMessages(sender:)))
        self.messageButton.addGestureRecognizer(gestureMess)
        let gestureLogOut = UITapGestureRecognizer(target: self, action:  #selector(self.logOut(sender:)))
        self.logOutButton.addGestureRecognizer(gestureLogOut)
    }
    
    @IBAction func getParentCode(_ sender: UIButton) {
        let studentRef = db.collection("users").document((user?.uid)!)
        studentRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let parentCode: String = document.get("parent_code") as! String
                let alert = UIAlertController(title: "Parent Code", message: "Your parent code is: \(parentCode)", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "Copy", style: .default, handler: { (UIAlertAction) in
                    
                    UIPasteboard.general.string = parentCode
                }))
                self.present(alert, animated: true)
            }}
    }
    
    @objc func openMenu(sender : UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [],
                       animations: {
                        self.navDrawer.alpha = 1
        },
                       completion: nil
        )
    }
    
    @objc func closeMenu(sender : UITapGestureRecognizer) {
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [],
                       animations: {
                        self.navDrawer.alpha = 0
        },
                       completion: nil
        )
    }
    
    @objc func hideMenus() {
        navDrawer.alpha = 0
    }
    
    @objc func goToSyllabus(sender : UITapGestureRecognizer) {
        performSegue(withIdentifier: "studentToSyllabus", sender: syllabusButton)
    }
    
    @objc func goToAssignments(sender : UITapGestureRecognizer) {
        performSegue(withIdentifier: "studentToAssignments", sender: assignmentsButton)
    }
    
    @objc func goToLeaderboard(sender : UITapGestureRecognizer) {
        performSegue(withIdentifier: "studentToLeaderboard", sender: leaderboardButton)
    }
    
    @objc func goToMessages(sender : UITapGestureRecognizer) {
        performSegue(withIdentifier: "studentToMessages", sender: messageButton)
    }
    
    @objc func logOut(sender : UITapGestureRecognizer) {
        try! Auth.auth().signOut()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is LeaderboardViewController
        {
            let vc = segue.destination as? LeaderboardViewController
            vc?.classCode = classCode
        }
        else if segue.destination is TeacherProfileViewController
        {
            let vc = segue.destination as? TeacherProfileViewController
            vc?.classCode = classCode
        }
        else if segue.destination is MessagesViewController
        {
            let vc = segue.destination as? MessagesViewController
            vc?.classCode = classCode
            vc?.userType = "student"
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
