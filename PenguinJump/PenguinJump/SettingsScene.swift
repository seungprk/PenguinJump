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
    var fetchRequest : NSFetchRequest<AnyObject>!
    var gameData : GameData!
    
    var fetchedData = [GameData]()
    
    var musicButton : SimpleButton!
    var soundsButton : SimpleButton!
    var backButton : SimpleButton!
    
    var backgroundMusic: AVAudioPlayer?
    var backgroundOcean: AVAudioPlayer?
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 220/255, green: 230/255, blue: 236/255, alpha: 1.0)
        
        // Fetch Data
        managedObjectContext = (UIApplication.shared().delegate as! AppDelegate).managedObjectContext
        fetchRequest = NSFetchRequest(entityName: "GameData")

        do {
            fetchedData = try managedObjectContext.executeFetchRequest(fetchRequest) as! [GameData]
        } catch {
            print(error)
        }
        gameData = fetchedData.first
        
        // Build Interface
        let logo = SKSpriteNode(texture: SKTexture(image: UIImage(named: "logo")!))
        logo.name = "logo"
        logo.alpha = 0.2
        logo.position = CGPoint(x: size.width/2, y: size.height/2)
        logo.zPosition = -100
        addChild(logo)
        
        let musicLabel = SKLabelNode(text: "Music")
        musicLabel.fontName = "Helvetica Neue Condensed Black"
        musicLabel.fontSize = 24
        musicLabel.position = CGPoint(x: size.width * 0.5 - 45, y: size.height * 0.55)
        musicLabel.fontColor = SKColor(red: 35/255, green: 134/255, blue: 221/255, alpha: 1.0)
        musicLabel.zPosition = 100
        addChild(musicLabel)
        
        if gameData.musicOn == true {
            musicButton = SimpleButton(text: "On")
        } else {
            musicButton = SimpleButton(text: "Off")
        }
        musicButton.name = "musicButton"
        musicButton.position = musicLabel.position
        musicButton.position.x += 100
        addChild(musicButton)
        
        let soundsLabel = SKLabelNode(text: "Sounds")
        soundsLabel.fontName = "Helvetica Neue Condensed Black"
        soundsLabel.fontSize = 24
        soundsLabel.position = CGPoint(x: size.width * 0.5 - 45, y: size.height * 0.45)
        soundsLabel.fontColor = SKColor(red: 35/255, green: 134/255, blue: 221/255, alpha: 1.0)
        soundsLabel.zPosition = 100
        addChild(soundsLabel)
        
        if gameData.soundEffectsOn == true {
            soundsButton = SimpleButton(text: "On")
        } else {
            soundsButton = SimpleButton(text: "Off")
        }
        soundsButton.name = "soundsButton"
        soundsButton.position = soundsLabel.position
        soundsButton.position.x += 100
        addChild(soundsButton)
        
        backButton = SimpleButton(text: "Back")
        backButton.name = "backButton"
        backButton.position = CGPoint(x: view.frame.midX, y: view.frame.midY)
        backButton.position.y -= 200
        addChild(backButton)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let positionInScene = touch.location(in: self)
            let touchedNodes = self.nodes(at: positionInScene)
            for touchedNode in touchedNodes {
                if touchedNode.name == "musicButton" {
                    musicButton.buttonPress(gameData.soundEffectsOn)
                }
                if touchedNode.name == "soundsButton" {
                    soundsButton.buttonPress(gameData.soundEffectsOn)
                }
                if touchedNode.name == "backButton" {
                    backButton.buttonPress(gameData.soundEffectsOn)
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let positionInScene = touch.location(in: self)
            let touchedNodes = self.nodes(at: positionInScene)
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
                    let transition = SKTransition.push(with: .up, duration: 0.5)
                    gameScene.scaleMode = SKSceneScaleMode.aspectFill
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
        let path = Bundle.main().pathForResource(file, ofType: type)
        let url = NSURL.fileURL(withPath: path!)
        
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
            perform("fadeVolumeDown:", with: player, afterDelay: 0.02)
        }
    }
    
    func fadeVolumeUp(player: AVAudioPlayer ) {
        player.volume += 0.01
        if player.volume < 1.0 {
            perform("fadeVolumeUp:", with: player, afterDelay: 0.02)
        }
    }
    
    func fadeAudioPlayer(player: AVAudioPlayer, fadeTo: Float, duration: TimeInterval, completion block: (() -> ())? ) {
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
        dispatch_time(
                dispatch_time_t(DISPATCH_TIME_NOW),
                Int64(delay * Double(NSEC_PER_SEC))
            ).after(
            DispatchTime.nowwhen: DispatchQueue.main(), execute: closure)
    }
}
