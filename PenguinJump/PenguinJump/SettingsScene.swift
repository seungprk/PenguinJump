//
//  SettingsScene.swift
//  PenguinJump
//
//  Created by Seung Park on 6/6/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit
import CoreData
import AVFoundation

class SettingsScene: SKScene {
    var managedObjectContext : NSManagedObjectContext!
    var fetchRequest : NSFetchRequest!
    var gameData : GameData!
    
    var fetchedData = [GameData]()
    
    var musicButton : SimpleButton!
    var soundsButton : SimpleButton!
    var backButton : SimpleButton!
    
    var backgroundMusic: AVAudioPlayer?
    var backgroundOcean: AVAudioPlayer?
    
    override func didMoveToView(view: SKView) {
        
        // Fetch Data
        managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        fetchRequest = NSFetchRequest(entityName: "GameData")

        do {
            fetchedData = try managedObjectContext.executeFetchRequest(fetchRequest) as! [GameData]
        } catch {
            print(error)
        }
        gameData = fetchedData.first
        
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
        
        if gameData.musicOn == true {
            musicButton = SimpleButton(text: "On")
        } else {
            musicButton = SimpleButton(text: "Off")
        }
        musicButton.name = "musicButton"
        musicButton.position = musicLabel.position
        musicButton.position.x += 50
        addChild(musicButton)
        
        let soundsLabel = SKLabelNode(text: "Sounds")
        soundsLabel.color = UIColor.whiteColor()
        soundsLabel.position = CGPoint(x: size.width/2, y: size.height/2 - 50)
        soundsLabel.zPosition = 100
        addChild(soundsLabel)
        
        if gameData.soundEffectsOn == true {
            soundsButton = SimpleButton(text: "On")
        } else {
            soundsButton = SimpleButton(text: "Off")
        }
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
                    if gameData.musicOn == true {
                        fadeMusic()
                        gameData.musicOn = false
                        gameData.musicPlaying = false
                        do { try managedObjectContext.save() } catch { print(error) }
                        musicButton.label.text = "Off"
                    } else if gameData.musicOn == false {
                        playMusic()
                        gameData.musicOn = true
                        gameData.musicPlaying = true
                        do { try managedObjectContext.save() } catch { print(error) }
                        musicButton.label.text = "On"
                    }
                    musicButton.buttonRelease()
                }
                if touchedNode.name == "soundsButton" && soundsButton.pressed == true {
                    if gameData.soundEffectsOn == true {
                        gameData.soundEffectsOn = false
                        soundsButton.label.text = "Off"
                    } else {
                        gameData.soundEffectsOn = true
                        soundsButton.label.text = "On"
                    }
                    soundsButton.buttonRelease()
                }
                if (touchedNode.name == "backButton" && backButton.pressed == true) {
                    backButton.buttonRelease()
                    saveSettings()
                    
                    // Present Main Game Scene
                    let gameScene = GameScene(size: self.size)
                    gameScene.backgroundMusic = backgroundMusic
                    gameScene.musicInitialized = true
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
        if gameData != nil {
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
            }
        }
    }
    
    func playMusic() {
        if gameData.musicOn == false && gameData.musicPlaying == false {
            if let backgroundMusic = backgroundMusic {
                backgroundMusic.volume = 0.0
                backgroundMusic.numberOfLoops = -1 // Negative integer to loop indefinitely
                backgroundMusic.play()
                fadeAudioPlayer(backgroundMusic, fadeTo: 0.5, duration: 1, completion: nil)
            }
        }
    }
    
    func fadeMusic() {
        if gameData.musicOn == true {
            fadeAudioPlayer(backgroundMusic!, fadeTo: 0.0, duration: 1.0, completion: {() in
                self.backgroundMusic?.stop()
            })
        }
    }
    
    // MARK: - Audio
    
    func audioPlayerWithFile(file: String, type: String) -> AVAudioPlayer? {
        let path = NSBundle.mainBundle().pathForResource(file, ofType: type)
        let url = NSURL.fileURLWithPath(path!)
        
        var audioPlayer: AVAudioPlayer?
        
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: url)
        } catch {
            print("Audio player not available")
        }
        
        return audioPlayer
    }
    
    func fadeVolumeDown(player: AVAudioPlayer) {
        player.volume -= 0.01
        if player.volume < 0.01 {
            player.stop()
        } else {
            // Use afterDelay value to change duration.
            performSelector("fadeVolumeDown:", withObject: player, afterDelay: 0.02)
        }
    }
    
    func fadeVolumeUp(player: AVAudioPlayer ) {
        player.volume += 0.01
        if player.volume < 1.0 {
            performSelector("fadeVolumeUp:", withObject: player, afterDelay: 0.02)
        }
    }
    
    func fadeAudioPlayer(player: AVAudioPlayer, fadeTo: Float, duration: NSTimeInterval, completion block: (() -> ())? ) {
        let amount:Float = 0.1
        let incrementDelay = duration * Double(amount)// * amount)
        
        if player.volume > fadeTo + amount {
            player.volume -= amount
            
            delay(incrementDelay) {
                self.fadeAudioPlayer(player, fadeTo: fadeTo, duration: duration, completion: block)
            }
        } else if player.volume < fadeTo - amount {
            player.volume += amount
            
            delay(incrementDelay) {
                self.fadeAudioPlayer(player, fadeTo: fadeTo, duration: duration, completion: block)
            }
        } else {
            // Execute when desired volume reached.
            block?()
        }
        
    }
    
    // MARK: - Utilities
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
}
