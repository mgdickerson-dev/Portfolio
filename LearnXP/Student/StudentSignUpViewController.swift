//
//  SignUpViewController.swift
//  LearnXP
//
//  Created by Michael Dickerson on 7/26/19.
//  Copyright © 2019 Michael Dickerson. All rights reserved.
//

import UIKit
import Firebase


class StudentSignUpViewController: UIViewController, UITextFieldDelegate {
    
   
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var classCodeField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(sender:)))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(sender: Any) {
        view.endEditing(true)
    }
    
    func setUpElements(){
        errorLabel.alpha = 0
        firstNameField.delegate = self
        lastNameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        classCodeField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField
        {
        case firstNameField:
            lastNameField.becomeFirstResponder()
            break
        case lastNameField:
            classCodeField.becomeFirstResponder()
            break
        case classCodeField:
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
        if (emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || classCodeField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || firstNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || lastNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""){
            return "Please fill in all fields."
        }
        let passwordTest = NSPredicate(format: "SELF MATCHES %@","^(?=.*[0-9]+.*)(?=.*[a-zA-Z]+.*)[0-9a-zA-Z]{6,}$")
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
        let homeViewController = (storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.studentHomeViewController) as? StudentHomeViewController)!
        self.navigationController!.pushViewController(homeViewController, animated: true)
    }
    
    @IBAction func signUp(_ sender: UIButton) {
        
        self.view.endEditing(true)
        let error = validateFields()
        
        if(error != nil){
            showError(error!)
            return
        }
        else{
            let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let classCode = classCodeField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let first = firstNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let last = lastNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let db = Firestore.firestore()
            let classRef = db.collection("classes").document(classCode!)
            
            classRef.getDocument { (document, error) in
                if let document = document {
                    
                    
                    if !document.exists{
                        self.showError("Invalid class code. Please try again.")
                        return
                        
                    } else {
                        
            Auth.auth().createUser(withEmail: email!, password: password!) { authResult, error in
                if error != nil{
                    self.showError("Error creating user. Please try again.")
                }
                else{
                    let db = Firestore.firestore()
                   let uid = authResult?.user.uid
                    db.collection("users").document(uid!).setData([
                        "class_code": classCode ?? nil!,
                        "type": "student",
                        "parent_code": uid!,
                        "experience": 0,
                        "body": 0,
                        "face": 0,
                        "number_messages": 0,
                        "icon": "GreenNormie.png",
                        "first_name": first ?? nil!,
                        "last_name": last ?? nil!,
                        "assignments_completed": 0
                    
                    
                    ]){ err in
                            if err != nil {
                                self.showError("Error adding class code.")
                            }
                    };
                    
                    classRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            var students = document.get("students") as! [String]
                            students.append(uid!)
                            db.collection("classes").document((classCode)!).updateData([
                                "students": students]){ err in
                                    if err != nil {
                                        self.showError("Error adding class code.")
                                    }
                            };
                        } else {
                            print("Document does not exist")
                        }
                    }
                    
                                self.transitionToHome()
                            }
                        }
                    }
                }
            }
        }
    }
}
