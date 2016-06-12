//
//  GameData.swift
//  PenguinJump
//
//  Created by Matthew Tso on 5/31/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import UIKit
import CoreData

class GameData: NSManagedObject {
    @NSManaged var highScore: NSNumber!
    @NSManaged var totalCoins: NSNumber!
    @NSManaged var selectedPenguin: String!
    @NSManaged var musicOn: NSNumber!
    @NSManaged var soundEffectsOn: NSNumber!
    @NSManaged var musicPlaying: NSNumber!
}
