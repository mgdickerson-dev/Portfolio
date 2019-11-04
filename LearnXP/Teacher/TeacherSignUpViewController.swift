//
//  SignUpViewController.swift
//  LearnXP
//
//  Created by Michael Dickerson on 7/26/19.
//  Copyright © 2019 Michael Dickerson. All rights reserved.
//

import UIKit
import Firebase


class TeacherSignUpViewController: UIViewController, UITextFieldDelegate{
    
    
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var schoolField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    
    var selectedSchool: Location? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
        
    }
    
    func didFinishSearch(controller: SearchViewController) {
        self.selectedSchool = controller.selectedSchool
       
        schoolField.text = selectedSchool?.name
        schoolField.isUserInteractionEnabled = false
        self.navigationItem.hidesBackButton = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let goNext = segue.destination as! SearchViewController
        goNext.delegate = self
    }
    
    @objc func dismissKeyboard(sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func searchSchool(_ sender: Any) {
        if Reachability.isConnectedToNetwork(){
        schoolField.resignFirstResponder()
        performSegue(withIdentifier: "searchSchool", sender: schoolField)
        }
        else{
            showError("Please Connect to the internet")
        }
    }
    
    func setUpElements(){
        errorLabel.alpha = 0
        firstNameField.delegate = self
        lastNameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        schoolField.delegate = self
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(sender:)))
        view.addGestureRecognizer(tap)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField
        {
        case firstNameField:
            lastNameField.becomeFirstResponder()
            break
        case lastNameField:
            schoolField.becomeFirstResponder()
            break
        case schoolField:
            emailField.becomeFirstResponder()
            break
        case emailField:
        passwordField.becomeFirstResponder()
            break
        case passwordField:
            textField.resignFirstResponder()
            break
        default:
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        if textField == firstNameField || textField == lastNameField {
        return count <= 36
        }
        else {
            return count <= 32
        }
    }
    
    func validateFields() -> String?{
        if (emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || schoolField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || firstNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || lastNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""){
            return "Please fill in all fields."
        }
        let passwordTest = NSPredicate(format: "SELF MATCHES %@","^([a-zA-Z0-9@*$_^&!?#]{6,20})$")
        if(!passwordTest.evaluate(with: passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines))){
            return "Password must contain at least one letter, at least one number, and be longer than six charaters."
        }
        let emailTest = NSPredicate(format: "SELF MATCHES %@", "^(\\D)+(\\w)*((\\.(\\w)+)?)+@(\\D)+(\\w)*((\\.(\\D)+(\\w)*)+)?(\\.)[a-z]{2,}$")
        if(!emailTest.evaluate(with: emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines))){
            return "Please enter a valid email address."
        }
        return nil
    }
    func showError(_ message: String){
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    func transitionToHome(){
        let homeViewController = (storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.teacherHomeViewController) as? TeacherHomeViewController)!
        self.navigationController!.pushViewController(homeViewController, animated: true)
    }
    
    @IBAction func signUp(_ sender: UIButton) {
        
        self.view.endEditing(true)
        if Reachability.isConnectedToNetwork(){
        let error = validateFields()
        
        if(error != nil){
            showError(error!)
            return
        }
        else{
            let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let first = firstNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let last = lastNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            Auth.auth().createUser(withEmail: email!, password: password!) { authResult, error in
                if error != nil{
                    self.showError("Error creating user. Please try again.")
                }
                else{
                    let db = Firestore.firestore()
                    
                    var schoolClean = self.selectedSchool?.name
                    schoolClean = schoolClean!.replacingOccurrences(of: "/", with: "")
                    schoolClean = schoolClean!.replacingOccurrences(of: "\\", with: "")
                    schoolClean = schoolClean!.replacingOccurrences(of: ".", with: "")
                    schoolClean = schoolClean!.replacingOccurrences(of: " ", with: "")
                    schoolClean = schoolClean!.replacingOccurrences(of: ",", with: "")
                    schoolClean = schoolClean!.replacingOccurrences(of: "'", with: "")
                    
                   let uid = authResult?.user.uid
                    db.collection("users").document(uid!).setData([
                        "school_name": self.selectedSchool?.name ?? nil!,
                        "type": "teacher",
                        "first_name": first ?? nil!,
                        "last_name": last ?? nil!,
                        "number_messages": 0,
                        "class_code": uid!,
                        "email": email ?? nil!]) { err in
                        if err != nil {
                            self.showError("Error adding teacher.")
                        }
                            let emptyStudents:[String] = []; db.collection("classes").document(uid!).setData(["students": emptyStudents]);
                            let emptyHomework:[String] = []; db.collection("classes").document(uid!).updateData(["homework": emptyHomework]);
                            let emptyQuizzes:[String] = []; db.collection("classes").document(uid!).updateData(["quizzes": emptyQuizzes]);
                            db.collection("classes").document(uid!).updateData(["syllabus": "Create a new syllabus."]);
                            db.collection("classes").document(uid!).updateData(["school_name": schoolClean ?? nil!]);
                            db.collection("classes").document(uid!).updateData(["total_assignments": 0]);
                            
                            db.collection("schools").document(schoolClean!).setData([
                                "school_name": self.selectedSchool?.name ?? nil!,
                                "address": self.selectedSchool?.address ?? nil!,
                                "phone": self.selectedSchool?.phoneNumber ?? nil!]) { err in
                                    if err != nil {
                                        self.showError("Error adding school.")
                                    }
                            }
                }
                self.transitionToHome()
                }
            }
        }
    }

else{
    showError("Please Connect to the internet")
        }}
}

