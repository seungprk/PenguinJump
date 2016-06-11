//
//  SettingsScene.swift
//  PenguinJump
//
//  Created by Seung Park on 6/6/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit
import CoreData

class SettingsScene: SKScene {
    var managedObjectContext : NSManagedObjectContext!
    var fetchRequest : NSFetchRequest!
    
    var fetchedData = [GameData]()
    var musicOn : NSNumber!
    var soundEffectsOn : NSNumber!
    
    var musicButton : SimpleButton!
    var soundsButton : SimpleButton!
    var backButton : SimpleButton!
    
    override func didMoveToView(view: SKView) {
        
        // Fetch Data
        managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        fetchRequest = NSFetchRequest(entityName: "GameData")

        do {
            fetchedData = try managedObjectContext.executeFetchRequest(fetchRequest) as! [GameData]
        } catch {
            print(error)
        }
        
        musicOn = fetchedData.first?.musicOn
        soundEffectsOn = fetchedData.first?.soundEffectsOn
        
        // Build Interface
        let logo = SKSpriteNode(imageNamed: "logo")
        logo.name = "logo"
        logo.position = CGPoint(x: size.width/2, y: size.height/2)
        logo.zPosition = -100
        addChild(logo)
        
        let musicLabel = SKLabelNode(text: "Music")
        musicLabel.color = UIColor.whiteColor()
        musicLabel.position = CGPoint(x: size.width/2, y: size.height/2)
        musicLabel.zPosition = 100
        addChild(musicLabel)
        
        musicButton = SimpleButton(text: "On")
        musicButton.name = "musicButton"
        musicButton.position = musicLabel.position
        musicButton.position.x += 50
        addChild(musicButton)
        
        let soundsLabel = SKLabelNode(text: "Sounds")
        soundsLabel.color = UIColor.whiteColor()
        soundsLabel.position = CGPoint(x: size.width/2, y: size.height/2 - 50)
        soundsLabel.zPosition = 100
        addChild(soundsLabel)
        
        soundsButton = SimpleButton(text: "On")
        soundsButton.name = "soundsButton"
        soundsButton.position = soundsLabel.position
        soundsButton.position.x += 50
        addChild(soundsButton)
        
        backButton = SimpleButton(text: "Back")
        backButton.name = "backButton"
        backButton.position = CGPoint(x: CGRectGetMidX(view.frame), y: CGRectGetMidY(view.frame))
        backButton.position.y -= 200
        addChild(backButton)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let positionInScene = touch.locationInNode(self)
            let touchedNodes = self.nodesAtPoint(positionInScene)
            for touchedNode in touchedNodes {
                if touchedNode.name == "musicButton" {
                    musicButton.buttonPress()
                }
                if touchedNode.name == "soundsButton" {
                    soundsButton.buttonPress()
                }
                if touchedNode.name == "backButton" {
                    backButton.buttonPress()
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let positionInScene = touch.locationInNode(self)
            let touchedNodes = self.nodesAtPoint(positionInScene)
            for touchedNode in touchedNodes {
                if touchedNode.name == "musicButton" && musicButton.pressed == true {
                    if musicOn == true {
                        musicOn = false
                        musicButton.label.text = "Off"
                    } else {
                        musicOn = true
                        musicButton.label.text = "On"
                    }
                    musicButton.buttonRelease()
                }
                if touchedNode.name == "soundsButton" && soundsButton.pressed == true {
                    if soundEffectsOn == true {
                        soundEffectsOn = false
                        soundsButton.label.text = "Off"
                    } else {
                        soundEffectsOn = true
                        soundsButton.label.text = "On"
                    }
                    soundsButton.buttonRelease()
                }
                if (touchedNode.name == "backButton" && backButton.pressed == true) {
                    backButton.buttonRelease()
                    saveSettings()
                    
                    // Present Main Game Scene
                    let gameScene = GameScene(size: self.size)
                    let transition = SKTransition.pushWithDirection(.Up, duration: 0.5)
                    gameScene.scaleMode = SKSceneScaleMode.AspectFill
                    self.scene!.view?.presentScene(gameScene, transition: transition)
                }
            }
        }
        musicButton.buttonRelease()
        soundsButton.buttonRelease()
        backButton.buttonRelease()
    }
    
    func saveSettings() {
        if let firstGameData = fetchedData.first {

            firstGameData.musicOn = musicOn
            firstGameData.soundEffectsOn = soundEffectsOn
            
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
            }
        }
    }
}
