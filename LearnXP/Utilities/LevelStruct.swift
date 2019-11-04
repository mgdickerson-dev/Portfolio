//
//  LevelStruct.swift
//  LearnXP
//
//  Created by Michael Dickerson on 8/10/19.
//  Copyright © 2019 Michael Dickerson. All rights reserved.
//

import Foundation
import Firebase

let db = Firestore.firestore()

struct LevelStruct {
    var experience = 0
    
    func setLevel() -> Int{
        var currentXP = Double(experience)
        var currentLevel = 1
        var experienceToLevel = 500 * (1.2 * Double(currentLevel))
        while currentXP >= experienceToLevel{
            currentXP -= experienceToLevel
            currentLevel += 1
            experienceToLevel = 500 * (1.2 * Double(currentLevel))
        }
        return currentLevel
    }
    
    func setExperience() -> Double{
        var currentXP = Double(experience)
        var currentLevel = 1
        var experienceToLevel = 500 * (1.2 * Double(currentLevel))
        while currentXP >= experienceToLevel{
            currentXP -= experienceToLevel
            currentLevel += 1
            experienceToLevel = 500 * (1.2 * Double(currentLevel))
            
        }
        let percentToLevel = currentXP / experienceToLevel
        return percentToLevel
    }
    
    func getExperienceToLevel() -> String{
        var currentXP = Double(experience)
        var currentLevel = 1
        var experienceToLevel = 500 * (1.2 * Double(currentLevel))
        while currentXP >= experienceToLevel{
            currentXP -= experienceToLevel
            currentLevel += 1
            experienceToLevel = 500 * (1.2 * Double(currentLevel))
            
        }
        if currentXP >= 0 {
        return "XP: \(Int(currentXP))/\(Int(experienceToLevel))"
        }
        else{
            return "XP: 0/\(Int(experienceToLevel))"
        }
    }
    
    
    
}
