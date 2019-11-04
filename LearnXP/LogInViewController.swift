//
//  LogInViewController.swift
//  LearnXP
//
//  Created by Michael Dickerson on 7/26/19.
//  Copyright © 2019 Michael Dickerson. All rights reserved.
//

import UIKit
import Firebase

class LogInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var logInButton: UIButton!
    
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
        emailField.delegate = self
        passwordField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField
        {
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
    
    func validateFields() -> String?{
        if (emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""){
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
    
    func transitionToHome(type: String){
        if type == "teacher"{
            let homeViewController = (storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.teacherHomeViewController) as? TeacherHomeViewController)!
            self.navigationController!.pushViewController(homeViewController, animated: true)
        }
        else if type == "student"{
            let homeViewController = (storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.studentHomeViewController) as? StudentHomeViewController)!
            self.navigationController!.pushViewController(homeViewController, animated: true)
        }
        else if type == "parent"{
            let homeViewController = (storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.parentHomeViewController) as? ParentHomeViewController)!
           self.navigationController!.pushViewController(homeViewController, animated: true)
        }
        
    }
    
    @IBAction func logIn(_ sender: UIButton) {
        
        self.view.endEditing(true)
        let error = validateFields()
        
        if(error != nil){
            showError(error!)
            return
        }
        else{
            let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            Auth.auth().signIn(withEmail: email!, password: password!) { (result, error) in
                if error != nil{
                    self.showError("Email or password not recognized. Please try again.")
                }
                else{
                    let db = Firestore.firestore()
                    
                    let classRef = db.collection("users").document(result!.user.uid)
                    classRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            let type = document.data()!["type"]
                            self.transitionToHome(type: type as! String)
                        } else {
                            print("Document does not exist")
                        }
                    }
                }
            }
        }
    }
}
