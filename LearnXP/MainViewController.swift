//
//  ViewController.swift
//  LearnXP
//
//  Created by Michael Dickerson on 7/24/19.
//  Copyright © 2019 Michael Dickerson. All rights reserved.
//

import UIKit
import Firebase

class MainViewController: UIViewController {

    @IBOutlet weak var logIn: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.checkAction))
        self.logIn.addGestureRecognizer(gesture)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @objc func checkAction(sender : UITapGestureRecognizer) {
        performSegue(withIdentifier: "logIn", sender: logIn)
    }

}
