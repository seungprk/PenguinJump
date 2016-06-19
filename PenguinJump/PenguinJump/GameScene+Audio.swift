//
//  GameScene+Audio.swift
//  PenguinJump
//
//  Created by Matthew Tso on 6/18/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit
import AVFoundation

extension GameScene {
    
    // MARK: - Game audio
    
    func playMusic() {
        if gameData.musicOn == true && gameData.musicPlaying == false {
            if let backgroundMusic = backgroundMusic {
                backgroundMusic.volume = 0.0
                backgroundMusic.numberOfLoops = -1 // Negative integer to loop indefinitely
                backgroundMusic.play()
                fadeAudioPlayer(backgroundMusic, fadeTo: musicVolume * 0.5, duration: 1, completion: nil)
            }
            if let backgroundOcean = backgroundOcean {
                backgroundOcean.volume = 0.0
                backgroundOcean.numberOfLoops = -1 // Negative integer to loop indefinitely
                backgroundOcean.play()
                fadeAudioPlayer(backgroundOcean, fadeTo: musicVolume * 0.1, duration: 1, completion: nil)
            }
            gameData.musicPlaying = true
            do { try managedObjectContext.save() } catch { print(error) }
        }
    }
    
    func fadeMusic() {
        if gameData.musicOn == true {
            fadeAudioPlayer(backgroundMusic!, fadeTo: 0.0, duration: 1.0, completion: {() in
                self.backgroundMusic?.stop()
            })
            fadeAudioPlayer(backgroundOcean!, fadeTo: 0.0, duration: 1.0, completion: {() in
                self.backgroundOcean?.stop()
            })
            gameData.musicOn = false
            gameData.musicPlaying = false
            do { try managedObjectContext.save() } catch { print(error) }
        }
    }
    
    // MARK: - Audio helper functions
    
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
        if player.volume < musicVolume {
            // Use afterDelay value to change duration.
            performSelector("fadeVolumeUp:", withObject: player, afterDelay: 0.02)
        }
    }
    
    /// Helper function to fade the volume of an `AVAudioPlayer` object.
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
}
