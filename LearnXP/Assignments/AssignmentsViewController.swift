//
//  AssignmentsViewController.swift
//  
//
//  Created by Michael Dickerson on 7/29/19.
//

import UIKit
import Firebase

class AssignmentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == homeworkTableView{
            return homework.count
        }
        else if tableView == quizTableView{
            return quizzes.count
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == homeworkTableView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeworkCell", for: indexPath) as! AssignmentTableViewCell
            if userType == "teacher"{
                cell.completedImageView.alpha = 0
            }
            if homework.count > 0{
                cell.assignmentLabel.text = homework[indexPath.row].title
                cell.rewardLabel.text = "Reward: \(homework[indexPath.row].reward)XP"
                
                    
                    let assignmentRef = self.db.collection("homework").document(self.homeworkArray[indexPath.row])
                    
                    assignmentRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            
                            let completed:[String] = document.get("students_completed") as? [String] ?? []
                            if completed.contains(self.user!) || completed.contains(self.currentStudent){
                                cell.completedImageView.image = UIImage(named: "Complete.png")
                            }
                    }}
            return cell
            }
        }
            let cell = tableView.dequeueReusableCell(withIdentifier: "QuizCell", for: indexPath) as! AssignmentTableViewCell
        if userType == "teacher"{
            cell.completedImageView.alpha = 0
        }
            if quizzes.count > 0{
                cell.assignmentLabel.text = quizzes[indexPath.row].title
                cell.rewardLabel.text = "Reward: \(quizzes[indexPath.row].reward)XP"
        }
            
            let assignmentRef = self.db.collection("quizzes").document(self.quizzesArray[indexPath.row])
        
        assignmentRef.getDocument { (document, error) in
            if let document = document, document.exists {
                
                let completed:[String] = document.get("students_completed") as? [String] ?? []
                if completed.contains(self.user!) || completed.contains(self.currentStudent){
                    cell.completedImageView.image = UIImage(named: "Complete.png")
                }
            }}
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == homeworkTableView{
        currentAssignment = homeworkArray[indexPath.row]
            assignmentType = "homework"
        }
        else if tableView == quizTableView{
            currentAssignment = quizzesArray[indexPath.row]
            assignmentType = "quizzes"
        }
            let assignmentRef = self.db.collection(assignmentType).document(currentAssignment)
            assignmentRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    self.type = document.get("type") as! String
                    if self.type == "multi"{
                    self.numQuestions = document.get("number_questions") as! Int
                    }
                    if self.userType == "teacher"{
                        self.performSegue(withIdentifier: "TeacherToAssignment", sender: tableView)
                    }
                    else{
                        if self.type == "multi"{
                            self.performSegue(withIdentifier: "toMultiAssignment", sender: tableView)
                        }
                        else{
                            self.performSegue(withIdentifier: "toAssignment", sender: tableView)
                        }
                }
            }
        }
    }
    
    @IBOutlet weak var exitButton: UIView!
    @IBOutlet weak var homeworkTableView: UITableView!
    @IBOutlet weak var quizTableView: UITableView!
    @IBOutlet weak var quizAddButton: UIButton!
    @IBOutlet weak var homeworkAddButton: UIButton!
    
    
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser?.uid
    var currentStudent = ""
    var homework: [Assignment] = []
    var quizzes: [Assignment] = []
    var homeworkArray: [String] = []
    var quizzesArray: [String] = []
    var classCode = ""
    var userType = ""
    var currentAssignment = ""
    var assignmentType = ""
    var type = ""
    var numQuestions = 0
    
    override func viewWillAppear(_ animated: Bool) {
        quizzes = []
        quizzesArray = []
        homework = []
        homeworkArray = []
        getUserType()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        quizTableView.delegate = self
        quizTableView.dataSource = self
        homeworkTableView.delegate = self
        homeworkTableView.dataSource = self
        let gestureExit = UITapGestureRecognizer(target: self, action:  #selector(self.popBack(sender:)))
        self.exitButton.addGestureRecognizer(gestureExit)
        
    }
    
    func getUserType(){
        let userRef = db.collection("users").document(user!)
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.classCode = document.get("class_code") as! String
                
                self.userType = document.get("type") as! String
                if self.userType == "student"{
                    self.currentStudent = self.user!
                }
                else if self.userType == "parent"{
                    self.currentStudent = document.get("parent_code") as! String
                }
                if self.userType != "teacher"{
                    self.quizAddButton.alpha = 0
                    self.homeworkAddButton.alpha = 0
                }
                self.loadAssignments()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is AssignmentViewController
        {
            if currentStudent != "edit"{
            let vc = segue.destination as? AssignmentViewController
            vc?.currentAssignment = currentAssignment
            vc?.assignmentType = assignmentType
            vc?.userType = userType
            vc?.classCode = classCode
            if userType == "parent"{
            vc?.currentStudent = currentStudent
            }
            }
            else{
                let vc = segue.destination as? AssignmentViewController
                vc?.currentAssignment = currentAssignment
                vc?.assignmentType = assignmentType
                vc?.userType = userType
                vc?.classCode = classCode
                vc?.currentStudent = currentStudent
            }
        }
        else if segue.destination is TeacherAssignmentViewController
        {
            let vc = segue.destination as? TeacherAssignmentViewController
            vc?.type = type
            vc?.classCode = classCode
            vc?.assignmentType = assignmentType
            vc?.currentAssignment = currentAssignment
            vc?.numQuestions = numQuestions
        }
        else if segue.destination is MultiAssignmentViewController{
            let vc = segue.destination as? MultiAssignmentViewController
            vc?.currentAssignment = currentAssignment
            vc?.assignmentType = assignmentType
            vc?.userType = userType
            vc?.classCode = classCode
            vc?.currentStudent = currentStudent
        }
    }
    
     @IBAction func myUnwindAction(segue: UIStoryboardSegue) {}
    
    func loadAssignments(){
        
        
        let assignmentsRef = db.collection("classes").document(classCode)
        
        assignmentsRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.quizzesArray = document.get("quizzes") as! [String]
                let dispatchGroup = DispatchGroup()
                let dispatchQueue = DispatchQueue(label: "quizzes")
                let dispatchSemaphore = DispatchSemaphore(value: 0)
                
                dispatchQueue.async {
                for item in self.quizzesArray{
                    
                    dispatchGroup.enter()
                    let assignmentRef = self.db.collection("quizzes").document(item)
                    assignmentRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            self.quizzes.append(Assignment(title: document.get("title") as! String, reward: document.get("reward") as! Int, prompt: document.get("body") as! String))
                            
                            self.quizTableView.reloadData()
                        }
                        
                dispatchSemaphore.signal()
                    dispatchGroup.leave()
                }
                
                dispatchSemaphore.wait()
                    }
                }
            }
            self.quizTableView.reloadData()
        assignmentsRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.homeworkArray = document.get("homework") as! [String]
                
                let dispatchGroup = DispatchGroup()
                let dispatchQueue = DispatchQueue(label: "homework")
                let dispatchSemaphore = DispatchSemaphore(value: 0)
                dispatchQueue.async {
                for item in self.homeworkArray{
                    dispatchGroup.enter()
                    
                    let assignmentRef = self.db.collection("homework").document(item)
                    assignmentRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            self.homework.append(Assignment(title: document.get("title") as! String, reward: document.get("reward") as! Int, prompt: document.get("body") as! String))
                            
                            self.homeworkTableView.reloadData()
                        }
                            dispatchSemaphore.signal()
                            dispatchGroup.leave()
                        }
                        
                        dispatchSemaphore.wait()
                    }
                }
            }
            self.homeworkTableView.reloadData()
            }
        }
    }
    
    @objc func popBack(sender : UITapGestureRecognizer) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        if textField.keyboardType == UIKeyboardType.numberPad{
            return count <= 3
        }
        else{
            return count <= 20
        }
    }
    
    @IBAction func addHomework(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Create Homework", message: "Please fill out the fields below, then select the type of assignment:", preferredStyle: .alert)
        
        let essayAction = UIAlertAction(title: "Essay", style: .default) { (_) in
            guard let textFields = alertController.textFields,
                textFields.count > 0 else {
                    // Could not find textfield
                    return
            }
            let title = textFields[0]
            let reward = textFields[1]
            if title.text != "" && reward.text != ""{
                
                self.homework.append(Assignment(title: title.text!, reward: Int(reward.text!)!, prompt: ""))
                self.homeworkTableView.reloadData()
                var assignment = "\(title.text!)\(NSDate().timeIntervalSince1970)"
                assignment = assignment.replacingOccurrences(of: "/", with: "")
                assignment = assignment.replacingOccurrences(of: "\\", with: "")
                assignment = assignment.replacingOccurrences(of: ".", with: "")
                assignment = assignment.replacingOccurrences(of: " ", with: "")
                self.homeworkArray.append(assignment)
                let emptyStudentArray: [String] = []
                self.db.collection("homework").document(assignment).setData([
                    "title": title.text!,
                    "reward": Int(reward.text!)!,
                    "body": "",
                    "assignment_type": "homework",
                    "type": "essay",
                    "students_completed": emptyStudentArray,
                    "graded_students": emptyStudentArray
                    ])
                self.db.collection("classes").document(self.classCode).updateData(["homework" : self.homeworkArray])
                self.db.collection("classes").document(self.classCode).updateData(["total_assignments" : self.quizzesArray.count + self.homeworkArray.count])
                
                self.currentAssignment = assignment
                self.assignmentType = "homework"
                self.currentStudent = "edit"
                self.performSegue(withIdentifier: "toAssignment", sender: self)
            }
                
                
            else{
                return
            }
        }
        let multiAction = UIAlertAction(title: "Multiple Choice", style: .default) { (_) in
            guard let textFields = alertController.textFields,
                textFields.count > 0 else {
                    // Could not find textfield
                    return
            }
            let title = textFields[0]
            let reward = textFields[1]
            if title.text != "" && reward.text != ""{
                let alert = UIAlertController(title: "Number of Questions", message: "How many questions do you want to make? (Max 3)", preferredStyle: .alert)
                let numAction = UIAlertAction(title: "OK", style: .default) { (_) in
                    guard let textFields = alertController.textFields,
                        textFields.count > 0 else {
                            // Could not find textfield
                            return
                    }
                    
                    let number = alert.textFields![0]
                    if number.text != ""{
                    self.homework.append(Assignment(title: title.text!, reward: Int(reward.text!)!, prompt: ""))
                    self.homeworkTableView.reloadData()
                    var assignment = "\(title.text!)\(NSDate().timeIntervalSince1970)"
                    assignment = assignment.replacingOccurrences(of: "/", with: "")
                    assignment = assignment.replacingOccurrences(of: "\\", with: "")
                    assignment = assignment.replacingOccurrences(of: ".", with: "")
                    assignment = assignment.replacingOccurrences(of: " ", with: "")
                    self.homeworkArray.append(assignment)
                    let emptyStringArray: [String] = []
                    self.db.collection("homework").document(assignment).setData([
                        "title": title.text!,
                        "reward": Int(reward.text!)!,
                        "body": "",
                        "number_questions": Int(number.text!) ?? 0,
                        "assignment_type": "homework",
                        "type": "multi",
                        "questions": emptyStringArray,
                        "question_name": emptyStringArray,
                        "students_completed": emptyStringArray,
                        "graded_students": emptyStringArray
                        ])
                    self.db.collection("classes").document(self.classCode).updateData(["homework" : self.homeworkArray])
                    self.db.collection("classes").document(self.classCode).updateData(["total_assignments" : self.quizzesArray.count + self.homeworkArray.count])
                    
                    self.currentAssignment = assignment
                    self.assignmentType = "homework"
                    self.currentStudent = "edit"
                    self.performSegue(withIdentifier: "toMultiAssignment", sender: self)
                }
                }
                alert.addTextField { (textField) in
                    textField.placeholder = "Number"
                    textField.keyboardType = .numberPad
                    textField.addTarget(alert, action: #selector(alert.textDidChangeInNumberAlert), for: .editingChanged)
                    
                }
                numAction.isEnabled = false
                alert.addAction(numAction)
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                
                self.present(alert, animated: true)
            }
                
            
            else{
                return
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        alertController.addTextField { (textField) in
            textField.placeholder = "Title"
            textField.delegate = self
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Reward"
            textField.keyboardType = .numberPad
            textField.delegate = self
        }
        
        alertController.addAction(essayAction)
        alertController.addAction(multiAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }

    @IBAction func addQuiz(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Create a Quiz", message: "Please fill out the fields below:", preferredStyle: .alert)
        
        let essayAction = UIAlertAction(title: "Essay", style: .default) { (_) in
            guard let textFields = alertController.textFields,
                textFields.count > 0 else {
                    // Could not find textfield
                    return
            }
            let title = textFields[0]
            let reward = textFields[1]
            if title.text != "" && reward.text != ""{
                
                self.quizzes.append(Assignment(title: title.text!, reward: Int(reward.text!)!, prompt: ""))
                self.quizTableView.reloadData()
                var assignment = "\(title.text!)\(NSDate().timeIntervalSince1970)"
                assignment = assignment.replacingOccurrences(of: "/", with: "")
                assignment = assignment.replacingOccurrences(of: "\\", with: "")
                assignment = assignment.replacingOccurrences(of: ".", with: "")
                assignment = assignment.replacingOccurrences(of: " ", with: "")
                self.quizzesArray.append(assignment)
                let emptyStudentArray: [String] = []
                self.db.collection("quizzes").document(assignment).setData([
                    "title": title.text!,
                    "reward": Int(reward.text!)!,
                    "body": "",
                    "assignment_type": "quizzes",
                    "students_completed": emptyStudentArray,
                    "graded_students": emptyStudentArray
                    ])
                self.db.collection("classes").document(self.classCode).updateData(["quizzes" : self.quizzesArray])
                 self.db.collection("classes").document(self.classCode).updateData(["total_assignments" : self.quizzesArray.count + self.homeworkArray.count])
            
                self.currentAssignment = assignment
                self.assignmentType = "quizzes"
                self.currentStudent = "edit"
                self.performSegue(withIdentifier: "toAssignment", sender: self)
            }
            else{
                return
            }
        }
        let multiAction = UIAlertAction(title: "Multiple Choice", style: .default) { (_) in
            guard let textFields = alertController.textFields,
                textFields.count > 0 else {
                    // Could not find textfield
                    return
            }
            let title = textFields[0]
            let reward = textFields[1]
            if title.text != "" && reward.text != ""{
                let alert = UIAlertController(title: "Number of Questions", message: "How many questions do you want to make? (Max 3)", preferredStyle: .alert)
                let numAction = UIAlertAction(title: "OK", style: .default) { (_) in
                    guard let textFields = alertController.textFields,
                        textFields.count > 0 else {
                            // Could not find textfield
                            return
                    }
                    
                    let number = alert.textFields![0]
                    if number.text != ""{
                        self.quizzes.append(Assignment(title: title.text!, reward: Int(reward.text!)!, prompt: ""))
                        self.quizTableView.reloadData()
                        var assignment = "\(title.text!)\(NSDate().timeIntervalSince1970)"
                        assignment = assignment.replacingOccurrences(of: "/", with: "")
                        assignment = assignment.replacingOccurrences(of: "\\", with: "")
                        assignment = assignment.replacingOccurrences(of: ".", with: "")
                        assignment = assignment.replacingOccurrences(of: " ", with: "")
                        self.quizzesArray.append(assignment)
                        let emptyStringArray: [String] = []
                        self.db.collection("quizzes").document(assignment).setData([
                            "title": title.text!,
                            "reward": Int(reward.text!)!,
                            "body": "",
                            "number_questions": Int(number.text!) ?? 0,
                            "assignment_type": "quizzes",
                            "type": "multi",
                            "questions": emptyStringArray,
                            "question_name": emptyStringArray,
                            "students_completed": emptyStringArray,
                            "graded_students": emptyStringArray
                            ])
                        self.db.collection("classes").document(self.classCode).updateData(["quizzes" : self.quizzesArray])
                        self.db.collection("classes").document(self.classCode).updateData(["total_assignments" : self.quizzesArray.count + self.homeworkArray.count])
                        
                        self.currentAssignment = assignment
                        self.assignmentType = "quizzes"
                        self.currentStudent = "edit"
                        self.performSegue(withIdentifier: "toMultiAssignment", sender: self)
                    }
                }
                alert.addTextField { (textField) in
                    textField.placeholder = "Number"
                    textField.keyboardType = .numberPad
                    textField.addTarget(alert, action: #selector(alert.textDidChangeInNumberAlert), for: .editingChanged)
                    
                }
                numAction.isEnabled = false
                alert.addAction(numAction)
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                
                self.present(alert, animated: true)
            }
                
                
            else{
                return
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Title"
            textField.delegate = self
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Reward"
            textField.keyboardType = .numberPad
            textField.delegate = self
        }
        
        alertController.addAction(essayAction)
        alertController.addAction(multiAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
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
extension UIAlertController {
    
    @objc func textDidChangeInNumberAlert() {
        if let number = textFields?[0].text,
            let action = actions.first {
            action.isEnabled = number != "" && Int(number)! <= 3
        }
    }
}
