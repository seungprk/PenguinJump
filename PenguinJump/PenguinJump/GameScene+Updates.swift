//
//  GameScene+Updates.swift: Collects all the update functions run in every rendering loop into one file.
//  PenguinJump
//
//  Created by Matthew Tso on 6/18/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit

extension GameScene {
    
    /// Updates the difficulty modifier based on y distance traveled.
    func trackDifficulty() {
        // Difficulty:
        // minimum 0.0
        // maximum 1.0
        difficulty = -1.0 * pow(0.9995, Double(penguin.position.y)) + 1.0
    }
    
    override func update(currentTime: TimeInterval) {
        
        updateGameTime(currentTime)
        
        // Stage is created whether a game session is in play or not because it serves as the background for the menu scene.
        stage.update()
        waves.update()
        coinLabel.text = "\(totalCoins) coins"
        
        if gameRunning {
            penguin.isUserInteractionEnabled = true
            
            scoreLabel.text = "Score: " + String(intScore)
            
            checkGameOver()
            if gameOver {
                runGameOver()
            }
            
            trackDifficulty()
            penguinUpdate()
            coinUpdate()
            chargeBarUpdate()
            
            updateStorm()
            updateRain()
            updateLightning()
            updateShark()
            
            centerCamera()
        } else {
            penguin.isUserInteractionEnabled = false
            penguin.removeAllActions()
            for child in penguin.children {
                child.removeAllActions()
            }
        }
        
    }
    
    /// Corrects game time upon exiting a pause state.
    func updateGameTime(currentTime: TimeInterval) {
        if shouldCorrectAfterPause {
            timeSinceLastUpdate = 0.0
            shouldCorrectAfterPause = false
            previousTime = currentTime
        } else {
            // previousTime is nil before the first time it is assigned to currentTime.
            if let previousTime = previousTime {
                timeSinceLastUpdate = currentTime - previousTime
                self.previousTime = currentTime
            } else {
                self.previousTime = currentTime
            }
        }
    }
    
    func updateShark() {
        for child in sharkLayer!.children {
            let shark = child as! Shark
            
            if shark.position.y < cam.position.y - view!.frame.height * 1.2 {
                shark.removeFromParent()
                
                if sharkLayer!.children.count < 1 {
                    lurkingSound?.stop()
                }
            }
        }
        
    }
    
    func updateLightning() {
        if let lightningLayer = lightningLayer{
            for child in lightningLayer.children {
                let lightning = child as! Lightning
                
                let difference = lightning.position.y - penguin.position.y
                if difference < 40 {
                    if !lightning.didBeginStriking {
                        lightning.didBeginStriking = true
                        lightning.beginStrike()
                    }
                }
            }
        }
    }
    
    func updateRain() {
        if stormMode {
            let maxRaindropsPerSecond = 80.0
            
            // Storm start ease in
            var raindropsPerSecond = 0.1 * pow(5.3, stormTimeElapsed) - 0.1
            
            // Cap at 80 maximum
            if raindropsPerSecond > maxRaindropsPerSecond {
                raindropsPerSecond = maxRaindropsPerSecond
            }
            
            // Storm ending rain ease out
            if stormTimeElapsed > stormDuration - 2 {
                raindropsPerSecond = 0.1 * pow(5.3, abs(stormTimeElapsed - stormDuration)) - 0.1
            }
            
            let numberOfRainDrops = Int(timeSinceLastUpdate * raindropsPerSecond /* * stormIntensity */) + 1// + randomRaindrops
            
            for _ in 0..<numberOfRainDrops {
                
                let randomX = 3.0 * CGFloat(random()) % view!.frame.width - view!.frame.width / 2
                let randomY = 2.0 * CGFloat(random()) % view!.frame.height - view!.frame.height / 4
                
                let raindrop = Raindrop()
                addChild(raindrop)
                
                raindrop.drop(CGPoint(x: penguin.position.x + CGFloat(randomX), y: penguin.position.y + CGFloat(randomY)), windSpeed: windSpeed * 2)
                
                // Attempt to avoid dropping a raindrop over an iceberg.
                for child in stage.children {
                    let berg = child as! Iceberg
                    if berg.containsPoint(convertPoint(CGPoint(x: penguin.position.x + CGFloat(randomX), y: penguin.position.y + CGFloat(randomY)), toNode: stage)) {
                        raindrop.zPosition = 0
                        
                    } else {
                        raindrop.zPosition = 24000
                    }
                }
            }
        }
    }
    
    func updateWinds() {
        if windEnabled {
            windSpeed = windDirectionRight ? stormIntensity * 70 : -stormIntensity * 70
            
            var deltaX = penguin.inAir ? windSpeed * timeSinceLastUpdate * difficulty : windSpeed * 0.5 * timeSinceLastUpdate * difficulty
            if penguin.type == PenguinType.shark {
                deltaX = deltaX * 0.75
            }
            
            let push = SKAction.moveBy(CGVector(dx: deltaX, dy: 0), duration: timeSinceLastUpdate)
            penguin.runAction(push)
        }
        
    }
    
    func updateStorm() {
        
        if stormMode {
            updateWinds()
            
            // Update storm intensity during storm mode.
            if stormTimeElapsed < stormDuration - stormTransitionDuration {
                stormTimeElapsed += timeSinceLastUpdate
                
                if stormIntensity < 0.99 {
                    // Begin storm gradually
                    stormIntensity += 1.0 * (timeSinceLastUpdate / stormTransitionDuration) * 0.3
                } else {
                    // Enter full storm intensity
                    stormIntensity = 1.0
                }
            } else {
                // Begin ending storm mode.
                if stormIntensity > 0.01 {
                    // Exit storm gradually
                    stormIntensity -= 1.0 * (timeSinceLastUpdate / stormTransitionDuration) * 0.3
                } else {
                    // End of storm mode.
                    stormIntensity = 0.0
                    stormTimeElapsed = 0.0
                    stormMode = false
                    
                    waves.stormMode = self.stormMode
                    waves.bob()
                    
                    for child in stage.children {
                        let berg = child as! Iceberg
                        berg.stormMode = self.stormMode
                        berg.bob()
                    }
                    
                    chargeBar.barFlash.removeAllActions()
                }
            }
        }
        backgroundColor = SKColor(red: bgColorValues.red, green: bgColorValues.green - CGFloat(40 / 255 * stormIntensity), blue: bgColorValues.blue - CGFloat(120 / 255 * stormIntensity), alpha: bgColorValues.alpha)
    }
    
    func penguinUpdate() {
        for child in stage.children {
            let berg = child as! Iceberg
            
            if  penguin.shadow.intersects(berg)
                &&  penguin.onBerg
                && !penguin.inAir
                && !berg.landed
                &&  berg.name != "firstBerg" {
                    // Penguin landed on an iceberg if check is true
                    
                    if gameData.soundEffectsOn == true { landingSound?.play() }
                    
                    berg.land()
                    stage.updateCurrentBerg(berg)
                    shakeScreen()
                    
                    let sinkDuration = 7.0 - (3.0 * difficulty)
                    berg.sink(sinkDuration, completion: nil)
                    penguin.land(sinkDuration)
                    
                    intScore += 1
                    
                    let scoreBumpUp = SKAction.scale(to: 1.2, duration: 0.1)
                    let scoreBumpDown = SKAction.scale(to: 1.0, duration: 0.1)
                    scoreLabel.run(SKAction.sequence([scoreBumpUp, scoreBumpDown]))
            }
        }
        
        if !penguin.hitByLightning && penguin.contactingLightning {
            
            for child in lightningLayer!.children {
                
                let lightning = child as! Lightning
                if lightning.activated && lightning.shadow.intersects(penguin.shadow) {
                    // Penguin hit by lightning strike.
                    penguin.hitByLightning = true
                    
                    let shadowPositionInLayer = lightningLayer!.convert(lightning.shadow.position, from: lightning)
                    let lightningShadowPositionInScene = convert(shadowPositionInLayer, from: lightningLayer!)
                    let penguinShadowPositionInScene = convert(penguin.shadow.position, from: penguin)
                    
                    let deltaX = penguinShadowPositionInScene.x - lightningShadowPositionInScene.x
                    let deltaY = penguinShadowPositionInScene.y - lightningShadowPositionInScene.y
                    let maxDelta = lightning.shadow.size.width / 2
                    
                    let maxPushDistance = penguin.size.height * 1.5
                    let pushX = (deltaX / maxDelta) * maxPushDistance
                    let pushY = (deltaY / maxDelta) * maxPushDistance
                    
                    let push = SKAction.move(by: CGVector(dx: pushX, dy: pushY), duration: 1.0)
                    push.timingMode = .easeOut
                    penguin.removeAllActions()
                    penguin.run(push, completion:  {
                        self.penguin.hitByLightning = false
                    })
                }
            }
        }
        
        
    }
    
    func chargeBarUpdate() {
        chargeBar.mask.size.width = scoreLabel.frame.width * 0.95
        
        if chargeBar.bar.position.x >= chargeBar.mask.size.width {
            shouldFlash = true
            
            if shouldFlash && !stormMode {
                shouldFlash = false
                beginStorm()
                
                chargeBar.flash(completion: {
                    
                    let chargeDown = SKAction.moveToX(0, duration: self.stormDuration - self.stormTimeElapsed)
                    self.chargeBar.bar.runAction(chargeDown)
                })
                
                
            }
        } else if chargeBar.bar.position.x > 0 && !stormMode {
            let decrease = SKAction.moveBy(CGVector(dx: -5 * timeSinceLastUpdate, dy: 0), duration: timeSinceLastUpdate)
            chargeBar.bar.runAction(decrease)
            
            if !stormMode && !chargeBar.flashing {
                chargeBar.barFlash.alpha = 0.0
                
            }
        }
    }
    
    func coinUpdate() {
        
        if let coinLayer = coinLayer {
            for child in coinLayer.children {
                
                let coin = child as! Coin
                
                let coinShadowPositionInLayer = coinLayer.convert(coin.shadow.position, from: coin)
                let coinPositionInScene = convert(coinShadowPositionInLayer, from: coinLayer)
                let penguinPositionInScene = convert(penguin.shadow.position, from: penguin)
                
                if penguinPositionInScene.y > coinPositionInScene.y {
                    coin.body.zPosition = 90000
                }
            }
        }
    }
    
    func incrementBarWithCoinParticles(coin: Coin) {
        for particle in coin.particles {
            let chargeBarPositionInCam = cam.convert(chargeBar.position, from: scoreLabel)
            
            let randomX = CGFloat(random()) % (chargeBar.bar.position.x + 1)
            
            let move = SKAction.move(to: CGPoint(x: chargeBarPositionInCam.x + randomX, y: chargeBarPositionInCam.y), duration: 1.0)
            move.timingMode = .easeOut
            
            let wait = SKAction.wait(forDuration: 0.2 * Double(coin.particles.index(of: particle)!))
            
            particle.run(wait, completion: {
                particle.run(move, completion: {
                    particle.removeFromParent()
                    if self.gameData.soundEffectsOn as Bool {
                        let charge = SKAction.playSoundFileNamed("charge.wav", waitForCompletion: false)
                        self.run(charge)
                    }
                    
                    self.chargeBar.flashOnce()
                    
                    if !self.stormMode {
                        let incrementAction = SKAction.move(by: CGVector(dx: self.chargeBar.increment, dy: 0), duration: 0.5)
                        incrementAction.timingMode = .easeOut
                        self.chargeBar.bar.run(incrementAction)
                    } else {
                        // Coin collected during storm mode.
                        // Increment bar but add to time elapsed too.
                    }
                    
                    if coin.particles.isEmpty {
                        coin.removeFromParent()
                    }
                })
            })
        }
    }
    
    func incrementTotalCoins() {
        totalCoins += 1
        
        // Increment coin total in game data
        if gameData != nil {
            let totalCoins = gameData.totalCoins as Int
            gameData.totalCoins = totalCoins + 1
            
            do { try managedObjectContext.save() } catch { print(error) }
        }
    }
    
    func checkGameOver() {
        if !penguin.inAir && !penguin.onBerg {
            gameOver = true
        }
    }
    
}
