//
//  TeacherAssignmentViewController.swift
//  LearnXP
//
//  Created by Michael Dickerson on 8/2/19.
//  Copyright © 2019 Michael Dickerson. All rights reserved.
//

import UIKit
import Firebase

class TeacherAssignmentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "editCell", for: indexPath) as! EditTableViewCell
            
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell", for: indexPath) as! StudentAssignmentTableViewCell
    
            cell.completedImageView.image = UIImage(named: "Incomplete.png")
            if students.count > 0{
                let classRef = db.collection("users").document(students[indexPath.row - 1])
                classRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        cell.nameLabel.text = document.get("first_name") as? String
                    }
                }
                let assignmentRef = db.collection(assignmentType).document(currentAssignment)
                assignmentRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let studentsCompleted = document.get("students_completed") as? [String]
                        let studentsGraded = document.get("graded_student") as? [String] ?? []
                        if (studentsCompleted?.count)! > 0{
                            for item in studentsCompleted!{
                                if self.students[indexPath.row - 1] == item{
                                    cell.completedImageView.image = UIImage(named: "Complete.png")
                                }
                           
                            }
                        }
                        if studentsGraded.count > 0{
                            for item in studentsGraded{
                                if self.students[indexPath.row - 1] == item{
                                    cell.checkedImageView.alpha = 1
                                }
                            }
                        }
                    }
                }
                
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 0{
        currentStudent = students[indexPath.row - 1]
            let assignmentRef = db.collection(assignmentType).document(currentAssignment)
            assignmentRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let studentsCompleted = document.get("students_completed") as? [String] ?? []
                
                    if studentsCompleted.contains(self.currentStudent){
                        if self.type == "multi"{
                            self.performSegue(withIdentifier: "TeacherViewMultiAssignment", sender: tableView)
                        }
                        else{
                        self.performSegue(withIdentifier: "TeacherViewAssignment", sender: tableView)
                        }
                    }
                }
            }
        }
        else{
            currentStudent = "edit"
            if type == "multi"{
            performSegue(withIdentifier: "TeacherViewMultiAssignment", sender: tableView)
            }
            else{
            performSegue(withIdentifier: "TeacherViewAssignment", sender: tableView)
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var students:[String] = []
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser?.uid
    var classCode = ""
    var currentAssignment = ""
    var currentStudent = ""
    var assignmentType = ""
    var type = ""
    var numQuestions = 0
    
    override func viewWillAppear(_ animated: Bool) {
        if classCode != ""{
            loadClass()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    @objc func loadClass(){
        
        let classRef = db.collection("classes").document(classCode)
        classRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.students = document.get("students") as! [String]
                self.tableView.reloadData()
            }}
        self.tableView.reloadData()
    }
    
    @IBAction func close(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is AssignmentViewController
        {
            let vc = segue.destination as? AssignmentViewController
            vc?.currentAssignment = currentAssignment
            vc?.assignmentType = assignmentType
            vc?.classCode = classCode
            vc?.userType = "teacher"
            vc?.students = students
            if currentStudent != ""{
                vc?.currentStudent = currentStudent
            }
        }
        else if segue.destination is MultiAssignmentViewController
        {
            let vc = segue.destination as? MultiAssignmentViewController
            vc?.currentAssignment = currentAssignment
            vc?.assignmentType = assignmentType
            vc?.classCode = classCode
            vc?.userType = "teacher"
            vc?.students = students
            vc?.numQuestions = numQuestions
            if currentStudent != ""{
                vc?.currentStudent = currentStudent
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
