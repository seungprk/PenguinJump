//
//  UnlockedPenguins.swift
//  PenguinJump
//
//  Created by Matthew Tso on 6/11/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import UIKit
import CoreData

class UnlockedPenguins: NSManagedObject {
    @NSManaged var penguinNormal: NSNumber!
    @NSManaged var penguinParasol: NSNumber!
}
