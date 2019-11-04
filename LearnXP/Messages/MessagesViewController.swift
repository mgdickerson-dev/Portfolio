//
//  MessagesViewController.swift
//  LearnXP
//
//  Created by Michael Dickerson on 7/29/19.
//  Copyright © 2019 Michael Dickerson. All rights reserved.
//

import UIKit
import Firebase

class MessagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && userType == "teacher"{
            return 1
        }
        else if messages.count > 0{
            return messages[section] + 1
        }
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return students.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView()
        let studentRef = db.collection("users").document(students[section])
        studentRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let first: String = document.get("first_name") as! String
                let last: String = document.get("last_name") as! String
                if self.userType == "teacher"{
                    if section == 0 {
                        let image = UIImageView(image: UIImage(named: "Chat.png"))
                        image.frame = CGRect(x: 5, y: 5, width: 35, height: 35)
                        view.addSubview(image)
                    }
                    else{
                        let icon = document.get("icon") as! String
                        let image = UIImageView(image: UIImage(named: icon))
                        image.frame = CGRect(x: 5, y: 5, width: 35, height: 35)
                        view.addSubview(image)
                    }
                }
                else{
                    let image = UIImageView(image: UIImage(named: "Chat.png"))
                    image.frame = CGRect(x: 5, y: 5, width: 35, height: 35)
                    view.addSubview(image)
                }
        view.backgroundColor = .init(red: 63.0/255.0, green: 66.0/255.0, blue: 141.0/255.0, alpha: 1.0)
        let label = UILabel()
        label.text = "\(first) \(last)"
        label.frame = CGRect(x: 45, y: 5, width: 200, height: 35)
        label.textColor = .white
        view.addSubview(label)
            }}
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && userType == "teacher"{
            let cell = tableView.dequeueReusableCell(withIdentifier: "sendAllCell", for: indexPath)
            
            return cell
        }
        else if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "editCell", for: indexPath)
            
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! MessageTableViewCell
            let studentRef = self.db.collection("users").document(user!)
            
            studentRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let array:[String] = document.get(self.students[indexPath.section]) as! [String]
                    cell.messageLabel.text = array[indexPath.row - 1].replacingOccurrences(of: "\\s?\\^[^)]*\\^", with: "", options: .regularExpression)
                }}
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 0{
            let studentRef = self.db.collection("users").document(user!)
            
            studentRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let array:[String] = document.get(self.students[indexPath.section]) as! [String]
                    self.subject = array[indexPath.row - 1]
                    self.message = document.get(self.subject) as! String
                    self.target = self.students[indexPath.section]
                    self.numMessage = self.messages[indexPath.section]
                    self.performSegue(withIdentifier: "toMessage", sender: self)
                }}
        }
        else{
            let alert = UIAlertController(title: "Create Message", message: "What is the message subject?", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { (_) in
                guard let textFields = alert.textFields,
                    textFields.count > 0 else {
                        // Could not find textfield
                        return
                }
                
                let subjectField = alert.textFields![0]
                if subjectField.text != ""{
                    self.subject = subjectField.text!
                    if indexPath.section == 0 && self.userType == "teacher"{
                        self.target = "all"
                        self.numMessage = -1
                    }
                    else{
                    self.target = self.students[indexPath.section]
                        self.numMessage = self.messages[indexPath.section]
                    }
                    self.performSegue(withIdentifier: "toMessage", sender: self)
                }
            }
            alert.addTextField { (textField) in
                textField.placeholder = "Subject"
            }
            alert.addAction(action)
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        }
    }
    
    var message = ""
    var subject = ""
    var target = ""
    var students:[String] = []
    var messages:[Int] = []
    let db = Firestore.firestore()
    var user = Auth.auth().currentUser?.uid
    var classCode = ""
    var userType = ""
    var parentCode = ""
    var numMessage = 0
    var numMessages:[Int] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var exitButton: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        if classCode != ""{
            if userType == "parent"{
                user = parentCode
            }
            students = []
            messages = []
            message = ""
            loadClass()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        let gestureExit = UITapGestureRecognizer(target: self, action:  #selector(self.popBack(sender:)))
        self.exitButton.addGestureRecognizer(gestureExit)
        
    }
    
    @objc func loadClass(){
        if userType == "student"{
            let classRef = db.collection("users").document(user!)
            classRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let number: Int = document.get("number_messages") as! Int
                    self.messages.append(number)
                    self.tableView.reloadData()
                }}
        }
        if userType == "parent"{
            let classRef = db.collection("users").document(parentCode)
            classRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let number: Int = document.get("number_messages") as! Int
                    self.messages.append(number)
                    self.tableView.reloadData()
                }}
        }
        if userType == "teacher"{
        let classRef = db.collection("classes").document(classCode)
        classRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.students = document.get("students") as! [String]
                
                self.students.insert(self.classCode, at: 0)
                let dispatchGroup = DispatchGroup()
                let dispatchQueue = DispatchQueue(label: "message")
                let dispatchSemaphore = DispatchSemaphore(value: 0)
                
                dispatchQueue.async {
                    for item in self.students{
                        let studentRef = self.db.collection("users").document(item)
                        
                        studentRef.getDocument { (document, error) in
                            if let document = document, document.exists {
                                let number: Int = document.get("number_messages") as! Int
                                self.numMessages.append(number)
                                
                            }}
                        let userRef = self.db.collection("users").document(self.user!)
                        
                        userRef.getDocument { (document, error) in
                            if let document = document, document.exists {
                                dispatchGroup.enter()
                                let array:[String] = document.get(item) as? [String] ?? []
                                self.messages.append(array.count)
                                
                            }
                            dispatchSemaphore.signal()
                            dispatchGroup.leave()
                        }
                        
                        dispatchSemaphore.wait()
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
            }}}
        }
        else{
            
            students.append(classCode)
            self.tableView.reloadData()
        }
    }
    
    @objc func popBack(sender : UITapGestureRecognizer) {
       self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is MessageViewController
        {
            let vc = segue.destination as? MessageViewController
            vc?.students = students
            vc?.message = message
            vc?.subject = subject.replacingOccurrences(of: "\\s?\\^[^)]*\\^", with: "", options: .regularExpression)
            vc?.target = target
            vc?.messages = numMessages
            vc?.numMessage = numMessage
            if userType == "parent"{
                vc?.user = parentCode
            }
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
