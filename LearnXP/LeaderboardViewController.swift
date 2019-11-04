//
//  LeaderboardViewController.swift
//  LearnXP
//
//  Created by Michael Dickerson on 7/29/19.
//  Copyright © 2019 Michael Dickerson. All rights reserved.
//

import UIKit
import Firebase

class LeaderboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if greatestOrder.count < 10{
            return greatestOrder.count
        }
        else{
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "classCell", for: indexPath) as! StudentTableViewCell
        if greatestOrder.count > 0{
            let classRef = db.collection("users").document(students[greatestOrder[indexPath.row]])
            classRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    cell.nameLabel.text = document.get("first_name") as? String
                    let icon = document.get("icon") as! String
                    cell.icon.image = UIImage(named: icon)
                    cell.rankLabel.text = "\(indexPath.row + 1)."
                }
                
            }}
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let studentRef = db.collection("users").document(students[greatestOrder[indexPath.row]])
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
                    self.studentView.alpha = 1
                    
                    UIView.animate(withDuration: 0.25, delay: 0.0
                        , options: [],
                          animations: {
                            var studentViewFrame = self.studentView.frame
                            studentViewFrame.origin.y  -= studentViewFrame.size.height
                            self.studentView.frame = studentViewFrame
                    },
                          completion: nil
                    )}
            }}
    }
    
    var classCode = ""
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser?.uid
    var students:[String] = []
    var experience:[Int] = []
    var greatestOrder: [Int] = []
    
    @IBOutlet weak var exitButton: UIView!
    @IBOutlet weak var classTableView: UITableView!
    @IBOutlet weak var assignmentLabel: UILabel!
    @IBOutlet weak var experienceLabel: UILabel!
    @IBOutlet weak var studentView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var experienceBar: UIProgressView!
    @IBOutlet weak var assignmentsBar: UIProgressView!
    @IBOutlet weak var closeButton: UIView!
    @IBOutlet weak var studentIcon: UIImageView!
    @IBOutlet weak var badge1: UIImageView!
    @IBOutlet weak var badge2: UIImageView!
    @IBOutlet weak var badge3: UIImageView!
    @IBOutlet weak var empty: UIView!
    
    @objc func hideMenus() {
        
        studentView.alpha = 0
        
        var studentViewFrame = studentView.frame
        studentViewFrame.origin.y  -= studentViewFrame.size.height
        studentView.frame = studentViewFrame
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hideMenus()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        classTableView.delegate = self
        classTableView.dataSource = self
        loadClass()
        let gestureExit = UITapGestureRecognizer(target: self, action:  #selector(self.popBack(sender:)))
        self.exitButton.addGestureRecognizer(gestureExit)
        let gestureClose = UITapGestureRecognizer(target: self, action:  #selector(self.closeStudent(sender:)))
        self.closeButton.addGestureRecognizer(gestureClose)
    }
    
    @objc func closeStudent(sender : UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [],
                       animations: {
                        
                        var studentViewFrame = self.studentView.frame
                        studentViewFrame.origin.y  += studentViewFrame.size.height
                        self.studentView.frame = studentViewFrame
                        
                        
                        self.studentView.alpha = 0
        },
                       completion: nil
        )
    }
    
    @objc func loadClass(){
        
        let classRef = db.collection("classes").document(classCode)
        classRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.students = document.get("students") as! [String]
                
                if self.students.count > 0{
                    self.empty.alpha = 0
                }
                self.classTableView.reloadData()
            
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "experience")
        let dispatchSemaphore = DispatchSemaphore(value: 0)
        
        dispatchQueue.async {
            for item in self.students{
                let studentRef = self.db.collection("users").document(item)
       
        studentRef.getDocument { (document, error) in
            if let document = document, document.exists {
                dispatchGroup.enter()
                self.experience.append(document.get("experience") as! Int)
                
                            }
                            dispatchSemaphore.signal()
                            dispatchGroup.leave()
                        }
                        
                        dispatchSemaphore.wait()
            }
            if self.experience.count > 0{
                let loops = self.experience.count
        for _ in 1...loops{
            var i = 0
            var greatestXP = 0
            var greatestI = 0
            for item in self.experience{
                if item >= greatestXP && !self.greatestOrder.contains(i){
                    greatestXP = item
                    greatestI = i
                }
                if i < self.experience.count - 1{i += 1}
            }
            self.greatestOrder.append(greatestI)
            
            }
            DispatchQueue.main.async {
                self.classTableView.reloadData()
            }
                }
                
                }}}
    }
    
    @objc func popBack(sender : UITapGestureRecognizer) {
        self.navigationController?.popViewController(animated: true)
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
