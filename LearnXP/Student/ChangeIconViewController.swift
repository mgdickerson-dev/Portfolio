//
//  ChangeIconViewController.swift
//  LearnXP
//
//  Created by Michael Dickerson on 8/2/19.
//  Copyright © 2019 Michael Dickerson. All rights reserved.
//

import UIKit
import Firebase

class ChangeIconViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return icons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "iconCell", for: indexPath) as! IconCollectionViewCell
        if icons.count > 0{
            cell.iconView.image = UIImage(named: icons[indexPath.row])
            }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentIcon = icons[indexPath.row]
        iconImage.image = UIImage(named: icons[indexPath.row])
    }
    

    
    var icons: [String] = []
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser?.uid
    var currentIcon = ""
    
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var iconCollection: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        let studentRef = db.collection("users").document(user!)
        studentRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.currentIcon = document.get("icon") as! String
                self.iconImage.image = UIImage(named: self.currentIcon)
            }}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        iconCollection.dataSource = self
        iconCollection.delegate = self
        loadIcons()
        
        // Do any additional setup after loading the view.
    }
    
    @objc func loadIcons(){
        
        let iconRef = db.collection("icons").document("icons_free")
        iconRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.icons = document.get("icons") as! [String]
                self.iconCollection.reloadData()
            }}
    }
    
    @IBAction func close(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func save(_ sender: Any) {
        if currentIcon != ""{ db.collection("users").document(user!).updateData(["icon" : currentIcon])}
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
