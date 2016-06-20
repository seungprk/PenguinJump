//
//  GameViewController.swift
//  PenguinJump
//
//  Created by Matthew Tso on 5/13/16.
//  Copyright (c) 2016 De Anza. All rights reserved.
//

import UIKit
import SpriteKit
import CoreData

class GameViewController: UIViewController {
    
    // Core Data
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let fetchRequest = NSFetchRequest(entityName: "GameData")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Load Core Data and make sure musicPlaying is set to false to make sure music plays once main game scene loads
        var fetchedData = [GameData]()
        do {
            fetchedData = try managedObjectContext.executeFetchRequest(fetchRequest) as! [GameData]
            
            if fetchedData.isEmpty {
                // Create initial game data
                initializeGameData()
                
                do {
                    fetchedData = try managedObjectContext.executeFetchRequest(fetchRequest) as! [GameData]
                } catch { print(error) }
            }
        } catch { print(error) }
        
        fetchedData.first!.musicPlaying = false
        do {
            try managedObjectContext.save()
        } catch { print(error) }
        
        
        let scene = CutScene(size: view.bounds.size)
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsPhysics = false
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        
        skView.presentScene(scene)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func initializeGameData() {
        let newGameData = NSEntityDescription.insertNewObjectForEntityForName("GameData", inManagedObjectContext: managedObjectContext) as! GameData
        newGameData.highScore = 0
        newGameData.totalCoins = 0
        newGameData.musicOn = true
        newGameData.musicPlaying = false
        newGameData.soundEffectsOn = true
        newGameData.selectedPenguin = "normal"
        
        do {
            try managedObjectContext.save()
        } catch { print(error) }
    }
}
