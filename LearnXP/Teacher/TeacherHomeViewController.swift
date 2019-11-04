//
//  TeacherHomeViewController.swift
//  LearnXP
//
//  Created by Michael Dickerson on 7/28/19.
//  Copyright © 2019 Michael Dickerson. All rights reserved.
//

import UIKit
import Firebase

class TeacherHomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return students.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "studentCell", for: indexPath) as! StudentCollectionViewCell
        if students.count > 0{
        let classRef = db.collection("users").document(students[indexPath.row])
        classRef.getDocument { (document, error) in
            if let document = document, document.exists {
                cell.nameLabel.text = document.get("first_name") as? String
                let icon = document.get("icon") as! String
                cell.profilePicture.image = UIImage(named: icon)
            }
                
            }}
            return cell
        }
    

    @IBOutlet weak var studentView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var experienceBar: UIProgressView!
    @IBOutlet weak var assignmentsBar: UIProgressView!
    @IBOutlet weak var rewardButton: UIView!
    @IBOutlet weak var penaltyButton: UIView!
    @IBOutlet weak var exitButton: UIView!
    @IBOutlet weak var studentIcon: UIImageView!
    @IBOutlet weak var experienceLabel: UILabel!
    @IBOutlet weak var assignmentLabel: UILabel!
    @IBOutlet weak var badge1: UIImageView!
    @IBOutlet weak var badge2: UIImageView!
    @IBOutlet weak var badge3: UIImageView!
    @IBOutlet weak var navDrawer: UIView!
    @IBOutlet weak var menuOpenButton: UIView!
    @IBOutlet weak var menuCloseButton: UIView!
    @IBOutlet weak var studentCollection: UICollectionView!
    @IBOutlet weak var syllabusButton: UIView!
    @IBOutlet weak var assignmentsButton: UIView!
    @IBOutlet weak var leaderboardButton: UIView!
    @IBOutlet weak var logOutButton: UIView!
    @IBOutlet weak var messageButton: UIView!
    @IBOutlet weak var touchableView: UIView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    var students: [String] = []
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser?.uid
    var classCode = ""
    var selectedStudent = ""
    
    @objc func hideMenus() {
        
        studentView.alpha = 0
        
        
        navDrawer.alpha = 0
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        hideMenus()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        studentCollection.dataSource = self
        studentCollection.delegate = self
        loadClass()
        setGestures()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedStudent = students[indexPath.row]
        let studentRef = db.collection("users").document(students[indexPath.row])
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
                self.studentIcon.image = UIImage(named: icon)
                self.nameLabel.text = "\(first) \(last)"
                let levelStruct = LevelStruct(experience: experience)
                self.experienceLabel.text = levelStruct.getExperienceToLevel()
                self.levelLabel.text = "Level: \(levelStruct.setLevel())"
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
                if self.studentView.alpha != 1{
                UIView.animate(withDuration: 0.25, delay: 0.0
                    , options: [],
                               animations: {
                                
                                self.studentView.alpha = 1
                },
                               completion: nil
                    )}
            }}
    }
    
    @objc func loadClass(){
        let userRef = db.collection("users").document(user!)
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.classCode = document.get("class_code") as! String
            }}
        let classRef = db.collection("classes").document(user!)
        classRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.students = document.get("students") as! [String]
                if self.students.count > 0{
                    self.touchableView.backgroundColor = .clear
                    self.emptyLabel.alpha = 0
                }
                self.studentCollection.reloadData()
            }}
    }
    
    @objc func setGestures(){
        let gestureOpen = UITapGestureRecognizer(target: self, action:  #selector(self.openMenu(sender:)))
        self.menuOpenButton.addGestureRecognizer(gestureOpen)
        let gestureClose = UITapGestureRecognizer(target: self, action:  #selector(self.closeMenu(sender:)))
        self.menuCloseButton.addGestureRecognizer(gestureClose)
        let gestureExit = UITapGestureRecognizer(target: self, action:  #selector(self.closeStudent(sender:)))
        self.exitButton.addGestureRecognizer(gestureExit)
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
        let gesturePunish = UITapGestureRecognizer(target: self, action:  #selector(self.punish(sender:)))
        self.penaltyButton.addGestureRecognizer(gesturePunish)
        let gestureReward = UITapGestureRecognizer(target: self, action:  #selector(self.reward(sender:)))
        self.rewardButton.addGestureRecognizer(gestureReward)
      
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let tag = touch?.view?.tag
        if tag == 1{return}
        else{
            if students.count > 0{
            touchableView.alpha = 0
            }
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [],
                       animations: {
                        self.navDrawer.alpha = 0
        },
                       completion: nil
        )
        }
    }
    
    @IBAction func getClassCode(_ sender: UIButton) {
        let teacherRef = db.collection("users").document(user!)
        teacherRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let classCode: String = document.get("class_code") as! String
                let alert = UIAlertController(title: "Class Code", message: "Your class code is: \(classCode)", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "Copy", style: .default, handler: { (UIAlertAction) in
                    
                    UIPasteboard.general.string = classCode
                }))
                self.present(alert, animated: true)
            }}
    }
    
    @objc func openMenu(sender : UITapGestureRecognizer) {
        
        touchableView.alpha = 1
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [],
                       animations: {
                        self.navDrawer.alpha = 1
                        
                        
        },
                       completion: nil
        )
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        
        return count <= 3
        
    }
    
    @objc func punish(sender : UITapGestureRecognizer) {
        let alertController = UIAlertController(title: "Penalty", message: "How much would you like to deduct?", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            guard let textFields = alertController.textFields,
                textFields.count > 0 else {
                    // Could not find textfield
                    return
            }
            let penalty = textFields[0]
            if penalty.text != ""{
                
                let penaltyInt = Int(penalty.text ?? "0")
                let studentRef = self.db.collection("users").document(self.selectedStudent)
                studentRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        var experience: Int = document.get("experience") as! Int
                        experience -= penaltyInt!
                        if experience >= 0{ self.db.collection("users").document(self.selectedStudent).updateData(["experience" : experience])
                        }
                        else{
                            self.db.collection("users").document(self.selectedStudent).updateData(["experience" : 0])
                        }
                        
                        let levelStruct = LevelStruct(experience: experience)
                        self.levelLabel.text = "Level: \(levelStruct.setLevel())"
                        self.experienceBar.progress = Float(levelStruct.setExperience())
                        self.experienceLabel.text = levelStruct.getExperienceToLevel()
                    }}}
            else{
                return
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Penalty"
            textField.keyboardType = .numberPad
            textField.delegate = self
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    
    }
    
    @objc func reward(sender : UITapGestureRecognizer) {
        
        let alertController = UIAlertController(title: "Reward", message: "How much would you like to reward?", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            guard let textFields = alertController.textFields,
                textFields.count > 0 else {
                    // Could not find textfield
                    return
            }
            let reward = textFields[0]
            if reward.text != ""{
                
                let rewardInt = Int(reward.text ?? "0")
                let studentRef = self.db.collection("users").document(self.selectedStudent)
                studentRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        var experience: Int = document.get("experience") as! Int
                        experience += rewardInt!
                        if experience >= 0{ self.db.collection("users").document(self.selectedStudent).updateData(["experience" : experience])
                        }
                        else{
                            self.db.collection("users").document(self.selectedStudent).updateData(["experience" : 0])
                        }
                        
                        let levelStruct = LevelStruct(experience: experience)
                        self.levelLabel.text = "Level: \(levelStruct.setLevel())"
                        self.experienceBar.progress = Float(levelStruct.setExperience())
                        self.experienceLabel.text = levelStruct.getExperienceToLevel()
                    }}}
            else{
                return
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Reward"
            textField.keyboardType = .numberPad
            textField.delegate = self
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @objc func closeMenu(sender : UITapGestureRecognizer) {
        if students.count > 0{
        touchableView.alpha = 0
        }
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [],
                       animations: {
                        self.navDrawer.alpha = 0
        },
                       completion: nil
        )
    }
    
    @objc func closeStudent(sender : UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [],
                       animations: {
                        
                        self.studentView.alpha = 0
        },
                       completion: nil
        )
    }
    
    @objc func goToSyllabus(sender : UITapGestureRecognizer) {
        performSegue(withIdentifier: "teacherToSyllabus", sender: syllabusButton)
    }
    
    @objc func goToAssignments(sender : UITapGestureRecognizer) {
        performSegue(withIdentifier: "teacherToAssignments", sender: assignmentsButton)
    }
    
    @objc func goToLeaderboard(sender : UITapGestureRecognizer) {
        performSegue(withIdentifier: "teacherToLeaderboard", sender: leaderboardButton)
    }
    
    @objc func goToMessages(sender : UITapGestureRecognizer) {
        performSegue(withIdentifier: "teacherToMessages", sender: messageButton)
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
            vc?.userType = "teacher"
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
