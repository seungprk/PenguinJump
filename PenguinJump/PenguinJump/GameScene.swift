//
//  GameSceneUsingCamera.swift
//  PenguinJump
//
//  Created by Matthew Tso on 5/25/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit
import CoreData
import AVFoundation

struct ColorValues {
    var red: CGFloat!
    var green: CGFloat!
    var blue: CGFloat!
    var alpha: CGFloat!
}

class GameScene: SKScene {
    
    // Game options
    var enableScreenShake = true
    var musicOn = true
    var soundOn = true
    
    // Node Objects
    var cam:SKCameraNode!
    let penguin = Penguin()
    var stage: IcebergGenerator!
    let jumpAir = SKShapeNode(circleOfRadius: 20.0)
    var waves: Waves!
    var background: Background!
    
    var backgroundMusic: AVAudioPlayer?
    var backgroundOcean: AVAudioPlayer?
    
    var splashSound: AVAudioPlayer?
    var jumpSound: AVAudioPlayer?
    var landingSound: AVAudioPlayer?
    var buttonPressSound: AVAudioPlayer?
    var coinSound: AVAudioPlayer?

    // Labels
    var startMenu : StartMenuNode!
    
    // Game session logic
    var gameBegin = false
    var gameRunning = false
    var gameOver = false
    var gamePaused = false
    var shouldCorrectAfterPause = false
    var playerTouched = false
    var freezeCamera = false
    var difficulty = 0.0

    var previousTime: NSTimeInterval?
    var timeSinceLastUpdate: NSTimeInterval = 0.0
    var stormTimeElapsed: NSTimeInterval = 0.0
    var stormIntensity = 0.0
    var stormDuration = 15.0
    var stormTransitionDuration = 2.0
    var stormMode = false
    let bgColorValues = ColorValues(red: 0/255, green: 151/255, blue: 255/255, alpha: 1)
    var windSpeed = 0.0
    var windEnabled = true
    var windDirectionRight = true
    
    // Information bar
    var intScore = 0
    var scoreLabel: SKLabelNode!
    var chargeBar: ChargeBar!
    var shouldFlash = false
    
    // Audio settings -> fetched from CoreData?
    var musicVolume:Float = 0.0
    var soundVolume:Float = 1.0
    
    // Debug
    var testZoomed = false
    var presentationMode = true
    var viewFrame: SKShapeNode!
    var debugMode = false
    

    // MARK: - Scene setup
    
    override func didMoveToView(view: SKView) {

        if let backgroundMusic = audioPlayerWithFile("Reformat", type: "mp3") {
            self.backgroundMusic = backgroundMusic
        }
        if let backgroundOcean = audioPlayerWithFile("ocean", type: "m4a") {
            self.backgroundOcean = backgroundOcean
        }
        if let splashSound = audioPlayerWithFile("splash", type: "m4a") {
            self.splashSound = splashSound
        }
        if let jumpSound = audioPlayerWithFile("jump", type: "m4a") {
            self.jumpSound = jumpSound
        }
        if let landingSound = audioPlayerWithFile("landing", type: "m4a") {
            self.landingSound = landingSound
        }
        if let buttonPressSound = audioPlayerWithFile("button_press", type: "m4a") {
            self.buttonPressSound = buttonPressSound
        }
        if let coinSound = audioPlayerWithFile("coin", type: "wav") {
            self.coinSound = coinSound
        }
        
        setupScene()
        
        // Start Menu Setup
        startMenu = StartMenuNode(frame: view.frame)
        startMenu.userInteractionEnabled = true //change to true once menu interaction properly enabled
        cam.addChild(startMenu)
        
        // Camera Setup
        cam.position = penguin.position
        cam.position.y += view.frame.height * 0.06
        let zoomedIn = SKAction.scaleTo(0.4, duration: 0.0)
        cam.runAction(zoomedIn)
        
        let startX = penguin.position.x
        let startY = penguin.position.y
        let pan = SKAction.moveTo(CGPoint(x: startX, y: startY), duration: 0.0)
        pan.timingMode = .EaseInEaseOut
        cam.runAction(pan)
        
        // Zoom out button for debugging
        let zoomButton = SKLabelNode(text: "ZOOM")
        zoomButton.name = "testZoom"
        zoomButton.fontName = "Helvetica Neue Condensed Black"
        zoomButton.fontSize = 24
        zoomButton.alpha = 0.5
        zoomButton.zPosition = 200000
        zoomButton.fontColor = UIColor.blackColor()
        zoomButton.position = CGPoint(x: 0 /* -view.frame.width / 2 */, y: view.frame.height / 2)
//        zoomButton.position.x += zoomButton.frame.width
        zoomButton.position.y -= zoomButton.frame.height * 2
        cam.addChild(zoomButton)

        let rainButton = SKLabelNode(text: "RAIN")
        rainButton.name = "rainButton"
        rainButton.fontName = "Helvetica Neue Condensed Black"
        rainButton.fontSize = 24
        rainButton.alpha = 0.5
        rainButton.zPosition = 200000
        rainButton.fontColor = UIColor.blackColor()
        rainButton.position = CGPoint(x: 0 /* -view.frame.width / 2 */, y: view.frame.height / 2 - zoomButton.frame.height)
        rainButton.position.y -= rainButton.frame.height * 2
        cam.addChild(rainButton)
        
        let lightningButton = SKLabelNode(text: "LIGHTNING")
        lightningButton.name = "lightningButton"
        lightningButton.fontName = "Helvetica Neue Condensed Black"
        lightningButton.fontSize = 24
        lightningButton.alpha = 0.5
        lightningButton.zPosition = 200000
        lightningButton.fontColor = UIColor.blackColor()
        lightningButton.position = CGPoint(x: 0 /* -view.frame.width / 2 */, y: view.frame.height / 2 - zoomButton.frame.height * 2)
        lightningButton.position.y -= lightningButton.frame.height * 2
        cam.addChild(lightningButton)
        
        let pauseButton = SKLabelNode(text: "I I")
        pauseButton.name = "pauseButton"
        pauseButton.fontName = "Helvetica Neue Condensed Black"
        pauseButton.fontSize = 24
        pauseButton.alpha = 0.5
        pauseButton.zPosition = 200000
        pauseButton.fontColor = UIColor.blackColor()
        pauseButton.position = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
        pauseButton.position.x -= pauseButton.frame.width * 1.5
        pauseButton.position.y -= pauseButton.frame.height * 2
        cam.addChild(pauseButton)
        
        if presentationMode {
            viewFrame = SKShapeNode(rectOfSize: view.frame.size)
            viewFrame.position = cam.position
            viewFrame.strokeColor = SKColor.redColor()
            viewFrame.fillColor = SKColor.clearColor()
            addChild(viewFrame)
        }
    }
    
    func setupScene() {
        gameOver = false
        
        cam = SKCameraNode()
        cam.xScale = 1.0
        cam.yScale = 1.0
        
        camera = cam
        addChild(cam)
        
        cam.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMidY(frame))
        
        stage = IcebergGenerator(view: view!, camera: cam)
        stage.position = view!.center
        stage.zPosition = 10
        addChild(stage)
        
//        backgroundColor = SKColor(red: 0/255, green: 151/255, blue: 255/255, alpha: 1.0)
        backgroundColor = SKColor(red: bgColorValues.red, green: bgColorValues.green, blue: bgColorValues.blue, alpha: bgColorValues.alpha)
        
        scoreLabel = SKLabelNode(text: "Score: " + String(intScore))
        scoreLabel.fontName = "Helvetica Neue Condensed Black"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = SKColor.blackColor()
        scoreLabel.position = CGPoint(x: -view!.frame.width * 0.45, y: view!.frame.height * 0.45)
        scoreLabel.zPosition = 30000
        scoreLabel.horizontalAlignmentMode = .Left
        
        chargeBar = ChargeBar(size: scoreLabel.frame.size)
        chargeBar.position = CGPoint(x: 0 /* - scoreLabel.frame.width / 2 */, y: 0 - scoreLabel.frame.height * 0.5)
        
        scoreLabel.addChild(chargeBar)
//        chargeBar.position.x -= scoreLabel.frame.width / 2
        
//        chargeBar.position = CGPoint(x: scoreLabel.position.x - scoreLabel.frame.width / 2, y: scoreLabel.position.y - scoreLabel.frame.height)
        
        // Wrap penguin around a cropnode for death animation
        let penguinPositionInScene = CGPoint(x: size.width * 0.5, y: size.height * 0.3)
        
        penguin.position = penguinPositionInScene
        penguin.zPosition = 2100
        penguin.userInteractionEnabled = true
        addChild(penguin)
        
        stage.newGame(convertPoint(penguinPositionInScene, toNode: stage))
        
        waves = Waves(camera: cam, gameScene: self)
        waves.position = view!.center
        waves.zPosition = 0
        addChild(waves)
//        bob(waves)
        waves.stormMode = self.stormMode
        waves.bob()
        
        background = Background(view: view!, camera: cam)
        background.position = view!.center
        background.zPosition = -1000
        addChild(background)
        
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
        
    }
    
    // MARK: - Scene Controls
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            let positionInScene = touch.locationInNode(self)
            let touchedNodes = self.nodesAtPoint(positionInScene)
            for touchedNode in touchedNodes {
                if let name = touchedNode.name
                {
                    if name == "restartButton" {
                        restart()
                        gameRunning = true
                    }
                    if touchedNode.name == "playButton" {
                        beginGame()
                        buttonPressSound?.play()
                    }
                    if touchedNode.name == "testZoom" {
                        let zoomOut = SKAction.scaleTo(3.0, duration: 0.5)
                        let zoomIn = SKAction.scaleTo(1.0, duration: 0.5)
                        
                        testZoomed ? cam.runAction(zoomIn) : cam.runAction(zoomOut)
                        testZoomed = testZoomed ? false : true
                    }
                    if touchedNode.name == "rainButton" {
                        let raindrop = Raindrop()
                        addChild(raindrop)
//                        raindrop.testRotation(view!.center, windSpeed: windSpeed)
                        raindrop.zPosition = 100000
                        raindrop.drop(view!.center, windSpeed: windSpeed, scene: self)
                    }
                    if touchedNode.name == "lightningButton" {
                        let lightning = Lightning(view: view!)
                        addChild(lightning)
                        lightning.position = penguin.position // view!.center
                        lightning.zPosition = 100000
                    }
                    
                    if touchedNode.name == "pauseButton" {
                        if gamePaused == false {
                            shouldCorrectAfterPause = true
                            gamePaused = true
                            penguin.userInteractionEnabled = false
                            paused = true
                            
                            let cover = SKSpriteNode(color: SKColor.blackColor(), size: view!.frame.size)
                            cover.name = "pauseCover"
                            cover.position = cam.position
                            cover.alpha = 0.5
                            cover.zPosition = 1000000
                            addChild(cover)
                            
                            let unPause = SKLabelNode(text: "Tap to Play")
                            unPause.name = "pauseCover"
                            unPause.position = cam.position
                            unPause.fontColor = SKColor.whiteColor()
                            unPause.fontName = "Helvetica Neue Condensed Black"
                            unPause.zPosition = 1000001
                            addChild(unPause)
                        }
                    }
                    if touchedNode.name == "pauseCover" {
                        for child in children {
                            if child.name == "pauseCover" {
                                child.removeFromParent()
                            }
                        }
                        gamePaused = false
                        penguin.userInteractionEnabled = true
                        paused = false
                    }
                }
            }
            if penguin.inAir && !penguin.doubleJumped {
                penguin.doubleJumped = true
                
                let delta = positionInScene - penguin.position
                
                let jumpAir = SKShapeNode(circleOfRadius: 20.0)
                jumpAir.fillColor = SKColor.clearColor()
                jumpAir.strokeColor = SKColor.whiteColor()
                
                jumpAir.xScale = 1.0
                jumpAir.yScale = 1.0
                
                jumpAir.position = penguin.position
                addChild(jumpAir)
                
                let airExpand = SKAction.scaleBy(2.0, duration: 0.4)
                let airFade = SKAction.fadeAlphaTo(0.0, duration: 0.4)
                
                airExpand.timingMode = .EaseOut
                airFade.timingMode = .EaseIn
                
                jumpAir.runAction(airExpand)
                jumpAir.runAction(airFade, completion: {
                    self.jumpAir.removeFromParent()
                })
                
                doubleJump(CGVector(dx: -delta.x * 2.5, dy: -delta.y * 2.5))
            }
        }
    }
    
    func doubleJump(velocity: CGVector) {
        let nudgeRate: CGFloat = 180
        let nudgeDistance = sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy)
        let nudgeDuration = Double(nudgeDistance / nudgeRate)
        
        let nudge = SKAction.moveBy(velocity, duration: nudgeDuration)
        penguin.runAction(nudge)
        jumpSound?.currentTime = 0
        jumpSound?.play()
    }
    
    // MARK: - Game state
    
    func beginGame() {
        let zoomOut = SKAction.scaleTo(1.0, duration: 2.0)
        
        let cameraFinalDestX = penguin.position.x
        let cameraFinalDestY = penguin.position.y + frame.height / 6
        
        let pan = SKAction.moveTo(CGPoint(x: cameraFinalDestX, y: cameraFinalDestY), duration: 2.0)
        pan.timingMode = .EaseInEaseOut
        zoomOut.timingMode = .EaseInEaseOut
        
        cam.runAction(zoomOut)
        cam.runAction(pan, completion: {
            self.cam.addChild(self.scoreLabel)
            
            self.scoreLabel.position.y += 300
            
            let scoreLabelDown = SKAction.moveBy(CGVector(dx: 0, dy: -300), duration: 1.0)
            scoreLabelDown.timingMode = .EaseOut
            self.scoreLabel.runAction(scoreLabelDown)
            
            self.gameBegin = true
            self.gameRunning = true
        })
        
        let playButtonDown = SKAction.moveBy(CGVector(dx: 0, dy: -300), duration: 1.0)
        playButtonDown.timingMode = .EaseIn
        startMenu.playButton.runAction(playButtonDown, completion: {
            self.startMenu.playButton.removeFromParent()
        })
        
        let titleUp = SKAction.moveBy(CGVector(dx: 0, dy: 400), duration: 1.0)
        titleUp.timingMode = .EaseIn
        startMenu.title.runAction(titleUp, completion: {
            self.startMenu.title.removeFromParent()
        })

    }
    
    func restart() {
        removeAllChildren()
        removeAllActions()
        cam.removeAllChildren()
        
        penguin.removeAllActions()
        
        setupScene()
        freezeCamera = false

        intScore = 0
        cam.addChild(scoreLabel)
        gameRunning = true

    }
    
    func runGameOver() {
        if gameOver {
            for child in stage.children {
                let berg = child as! Iceberg
                berg.removeAllActions()
            }
            gameRunning = false
            freezeCamera = true
            self.backgroundColor = SKColor(red: 0/255, green: 120/255, blue: 200/255, alpha: 1.0)
            
            penguin.shadow.removeFromParent()
            
            let fall = SKAction.moveBy(CGVector(dx: 0, dy: -20), duration: 0.2)
            fall.timingMode = .EaseOut
            let slideUp = SKAction.moveBy(CGVector(dx: 0, dy: 25), duration: 0.2)
            slideUp.timingMode = .EaseOut
            
            penguin.runAction(slideUp)
            penguin.body.runAction(fall)
            
            splashSound?.play()
            
            let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
            let fetchRequest = NSFetchRequest(entityName: "GameData")
            var fetchedData = [GameData]()
            
            do {
                fetchedData = try managedObjectContext.executeFetchRequest(fetchRequest) as! [GameData]
                
                if fetchedData.isEmpty {
                    // Create initial game data
                    let newGameData = NSEntityDescription.insertNewObjectForEntityForName("GameData", inManagedObjectContext: managedObjectContext) as! GameData
                    newGameData.highScore = 0
                    
                    do {
                        try managedObjectContext.save()
                    } catch { print(error) }
                    
                    do {
                        fetchedData = try managedObjectContext.executeFetchRequest(fetchRequest) as! [GameData]
                    } catch { print(error) }
                }
            } catch {
                print(error)
            }
            
            if let firstGameData = fetchedData.first {
                let highScore = firstGameData.highScore as Int
                
                if intScore > highScore {
                    firstGameData.highScore = intScore
                    
                    do {
                        try managedObjectContext.save()
                    } catch {
                        print(error)
                    }
                }
            }
            
            fadeMusic()
            
            let wait = SKAction.waitForDuration(2.0)
            self.runAction(wait, completion:  {
                let scoreScene = ScoreScene(size: self.size)
                scoreScene.score = self.intScore
                
                let transition = SKTransition.moveInWithDirection(.Up, duration: 0.5)
                scoreScene.scaleMode = SKSceneScaleMode.AspectFill
                self.scene!.view?.presentScene(scoreScene, transition: transition)
            })
        }
    }
    
    func fadeMusic() {
        fadeAudioPlayer(backgroundMusic!, fadeTo: 0.0, duration: 1.0, completion: {() in
            self.backgroundMusic?.stop()
        })
        fadeAudioPlayer(backgroundOcean!, fadeTo: 0.0, duration: 1.0, completion: {() in
            self.backgroundOcean?.stop()
        })
        
    }
    
    // MARK: - Updates
    
    override func update(currentTime: NSTimeInterval) {
        if shouldCorrectAfterPause {
            timeSinceLastUpdate = 0.0
            shouldCorrectAfterPause = false
            previousTime = currentTime
        } else {
            if let previousTime = previousTime {
                timeSinceLastUpdate = currentTime - previousTime
                self.previousTime = currentTime
            } else {
                self.previousTime = currentTime
            }
        }
        
        
        stage.update()
        waves.update()

        if gameRunning {
            penguin.userInteractionEnabled = true

            scoreLabel.text = "Score: " + String(intScore)
            
            penguinUpdate()
            coinUpdate()
            chargeBarUpdate()
            trackDifficulty()
            
            checkGameOver()
            if gameOver {
                runGameOver()
            }
            
            updateStorm()
            updateRain()
            
            centerCamera()
        } else {
            penguin.userInteractionEnabled = false
            penguin.removeAllActions()
            for child in penguin.children {
                child.removeAllActions()
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
                
                let randomX = 1.5 * CGFloat(random()) % view!.frame.width - view!.frame.width / 2
                let randomY = 2.0 * CGFloat(random()) % view!.frame.height - view!.frame.height / 4

                let raindrop = Raindrop()

                raindrop.drop(CGPoint(x: penguin.position.x + CGFloat(randomX), y: penguin.position.y + CGFloat(randomY)), windSpeed: windSpeed * 2, scene: self)
                
                // Attempt to avoid dropping a raindrop over an iceberg.
                for child in stage.children {
                    let berg = child as! Iceberg
                    if berg.containsPoint(convertPoint(CGPoint(x: penguin.position.x + CGFloat(randomX), y: penguin.position.y + CGFloat(randomY)), toNode: stage)) {
                        raindrop.zPosition = 0
                        
                    } else {
                        raindrop.zPosition = 24000
                    }
                }
                
                addChild(raindrop)
            }
        }
    }
    
    func updateWinds() {
        if windEnabled {
            windSpeed = windDirectionRight ? stormIntensity * 50 : -stormIntensity * 50
            
            let deltaX = penguin.inAir ? windSpeed * timeSinceLastUpdate * difficulty : windSpeed * 0.5 * timeSinceLastUpdate * difficulty
            
            
            let push = SKAction.moveBy(CGVector(dx: deltaX, dy: 0), duration: timeSinceLastUpdate)
            penguin.runAction(push)
        }

    }
    
    func updateStorm() {

        if stormMode {
            updateWinds()
            
            if stormTimeElapsed < stormDuration - stormTransitionDuration {
                stormTimeElapsed += timeSinceLastUpdate
                
                if stormIntensity < 0.99 {
                    stormIntensity += 1.0 * (timeSinceLastUpdate / stormTransitionDuration) * 0.3
                } else {
                    stormIntensity = 1.0
                    
                }
                
            } else {
                if stormIntensity > 0.01 {
                    stormIntensity -= 1.0 * (timeSinceLastUpdate / stormTransitionDuration) * 0.3
                } else {
                    stormIntensity = 0.0
                    
                    // End storm mode.
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
            
        } else {

        }
        backgroundColor = SKColor(red: bgColorValues.red, green: bgColorValues.green - CGFloat(40 / 255 * stormIntensity), blue: bgColorValues.blue - CGFloat(120 / 255 * stormIntensity), alpha: bgColorValues.alpha)
    }
    
    func penguinUpdate() {
        for child in stage.children {
            let berg = child as! Iceberg
            
            if penguin.shadow.intersectsNode(berg) && !berg.landed && !penguin.inAir && berg.name != "firstBerg" {
                // Penguin landed on an iceberg if check is true
                landingSound?.play()
                
                berg.land()
                stage.updateCurrentBerg(berg)
                shakeScreen()
                
                let sinkDuration = 7.0 - (3.0 * difficulty)
                berg.sink(sinkDuration, completion: nil)
                penguin.land(sinkDuration)
                
                intScore += 1
                
                let scoreBumpUp = SKAction.scaleTo(1.2, duration: 0.1)
                let scoreBumpDown = SKAction.scaleTo(1.0, duration: 0.1)
                scoreLabel.runAction(SKAction.sequence([scoreBumpUp, scoreBumpDown]))
                
            } else if penguin.shadow.intersectsNode(berg) && !penguin.inAir {
                // Penguin landed on an iceberg that is sinking.
                // Needs fix. Constantly bumps right now.
//                berg.bump()
            }
        }
        
        if !penguin.hitByLightning {
            for child in children {
                if child.name == "lightning" {
                    let lightning = child as! Lightning
        
                    if lightning.activated {
                        if lightning.shadow.intersectsNode(penguin.shadow) {
                            // Penguin hit!
                            print("penguin hit!")
                            penguin.hitByLightning = true
                            
                            let lightningShadowPositionInScene = convertPoint(lightning.shadow.position, fromNode: lightning)
                            let penguinShadowPositionInScene = convertPoint(penguin.shadow.position, fromNode: penguin)
                            
                            let maxPushDistance = penguin.size.height * 2
                            
                            let deltaX = penguinShadowPositionInScene.x - lightningShadowPositionInScene.x
                            let deltaY = penguinShadowPositionInScene.y - lightningShadowPositionInScene.y
                            
                            let distanceFromLightningCenter = sqrt(deltaX * deltaX + deltaY * deltaY)
                            let pushDistance = -distanceFromLightningCenter + maxPushDistance
                            
                            let angle = atan(deltaY / deltaX)
                            
                            let pushX = cos(angle) * pushDistance
                            let pushY = sin(angle) * pushDistance
                            
                            print(CGVector(dx: pushX, dy: pushY))
                            let push = SKAction.moveBy(CGVector(dx: pushX, dy: pushY), duration: 1.0)
                            penguin.removeAllActions()
                            penguin.runAction(push, completion:  {
                            self.penguin.hitByLightning = false
                            })
                        }
                    }
        
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
        for child in stage.children {
            for icebergChild in child.children {
                if icebergChild.name == "coin" {
                    let coin = icebergChild as! Coin
                    
                    if !coin.collected {
                        if penguin.intersectsNode(coin.body) {
                            // Run coin hit collision
                            intScore += stormMode ? 4 : 2

                            let scoreBumpUp = SKAction.scaleTo(1.2, duration: 0.1)
                            let scoreBumpDown = SKAction.scaleTo(1.0, duration: 0.1)
                            scoreLabel.runAction(SKAction.sequence([scoreBumpUp, scoreBumpDown]))
                            
                            coin.collected = true
                            
                            coinSound?.currentTime = 0
                            coinSound?.play()
                            
                            let rise = SKAction.moveBy(CGVector(dx: 0, dy: coin.body.size.height), duration: 0.5)
                            rise.timingMode = .EaseOut
                            
                            coin.body.zPosition = 90000
                            coin.body.runAction(rise, completion: {
                                coin.generateCoinParticles(self.cam)
                                
                                let path = NSBundle.mainBundle().pathForResource("CoinBurst", ofType: "sks")
                                let coinBurst = NSKeyedUnarchiver.unarchiveObjectWithFile(path!) as! SKEmitterNode
                                
//                                coinBurst.position = self.convertPoint(coin.body.position, fromNode: coin)
                                coinBurst.zPosition = 240000
//                                coinBurst.position = coin.body.position
                                coinBurst.numParticlesToEmit = 100
                                coinBurst.targetNode = self.scene
                                
                                let coinBurstEffectNode = SKEffectNode()
                                coinBurstEffectNode.addChild(coinBurst)
                                coinBurstEffectNode.zPosition = 240000
                                
                                coinBurstEffectNode.position = self.convertPoint(coin.body.position, fromNode: coin)
                                coinBurstEffectNode.blendMode = .Replace
                                
                                self.addChild(coinBurstEffectNode)
                                
                                
//                                let bodyPositionInScene = self.convertPoint(coin.body.position, fromNode: coin)
//                                let bodyPositionInCam = self.cam.convertPoint(bodyPositionInScene, fromNode: self)
//                                coinBurst.position = bodyPositionInCam
                                
//                                self.addChild(coinBurst)
//                                coin.addChild(coinBurst)
                                
                                coin.body.removeFromParent()
                                coin.shadow.removeFromParent()
                                self.incrementWithCoinParticles(coin)
//                                icebergChild.removeFromParent()
                            })
                        }
                    }
                    
                }
            }
        }
    }
    
    func incrementWithCoinParticles(coin: Coin) {
        for particle in coin.particles {
            let chargeBarPositionInCam = cam.convertPoint(chargeBar.position, fromNode: scoreLabel)
            
            let randomX = CGFloat(random()) % (chargeBar.bar.position.x + 1)

            let move = SKAction.moveTo(CGPoint(x: chargeBarPositionInCam.x + randomX, y: chargeBarPositionInCam.y), duration: 1.0)
            move.timingMode = .EaseOut
            
//            var delaySequence = [SKAction]()
            
            let wait = SKAction.waitForDuration(0.2 * Double(coin.particles.indexOf(particle)!))
            
            particle.runAction(wait, completion: {
                particle.runAction(move, completion: {
                    particle.removeFromParent()
                    self.chargeBar.flashOnce()
                    
                    if !self.stormMode {
                        let incrementAction = SKAction.moveBy(CGVector(dx: self.chargeBar.increment, dy: 0), duration: 0.5)
                        incrementAction.timingMode = .EaseOut
                        self.chargeBar.bar.runAction(incrementAction)
                    } else {
                        // Increment bar but add to time elapsed too.
                    }
                    
                    if coin.particles.isEmpty {
                        coin.removeFromParent()
                    }
                })
            })
            

        }

    }
    
    func checkGameOver() {
        if !penguin.inAir && !onBerg() {
            gameOver = true            
        }
    }
    
    func onBerg() -> Bool {
        for child in stage.children {
            let berg = child as! Iceberg
            if penguin.shadow.intersectsNode(berg) {
                return true
            }
        }
        return false
    }
    
    // MARK: - Storm Mode
    
    func beginStorm() {
        stormMode = true
        
        windDirectionRight = random() % 2 == 0 ? true : false
        
        waves.stormMode = self.stormMode
        waves.bob()
        
        for child in stage.children {
            let berg = child as! Iceberg
            berg.stormMode = self.stormMode
            berg.bob()
        }
        
        let flashUp = SKAction.fadeAlphaTo(1.0, duration: 0.5)
        let flashDown = SKAction.fadeAlphaTo(0.0, duration: 0.5)
        flashUp.timingMode = .EaseInEaseOut
        flashDown.timingMode = .EaseInEaseOut
        
        let flash = SKAction.sequence([flashUp, flashDown])
        chargeBar.barFlash.runAction(SKAction.repeatActionForever(flash))
    }

    // MARK: - Gameplay logic
    
    func trackDifficulty() {
        // Difficulty:
        // minimum 0.0
        // maximum 1.0
        difficulty = -1.0 * pow(0.9995, Double(penguin.position.y)) + 1.0
    }
    
    // MARK: - Camera control
    
    func centerCamera() {
        if !freezeCamera {
            let cameraFinalDestX = penguin.position.x
            let cameraFinalDestY = penguin.position.y + frame.height / 6
            
            let pan = SKAction.moveTo(CGPoint(x: cameraFinalDestX, y: cameraFinalDestY), duration: 0.125)
            pan.timingMode = .EaseInEaseOut
            
            cam.runAction(pan)
            
            if presentationMode {
                viewFrame.position = cam.position
            }
        } else {
            cam.removeAllActions()
        }
    }
    
    // MARK: - Background
    
//    func bob(node: SKSpriteNode) {
//        let bobDepth = 2.0
//        let bobDuration = 2.0
//        
//        let down = SKAction.moveBy(CGVector(dx: 0.0, dy: bobDepth), duration: bobDuration)
//        let wait = SKAction.waitForDuration(bobDuration / 2)
//        let up = SKAction.moveBy(CGVector(dx: 0.0, dy: -bobDepth), duration: bobDuration)
//        
//        let bobSequence = SKAction.sequence([down, wait, up, wait])
//        let bob = SKAction.repeatActionForever(bobSequence)
//        
//        node.removeAllActions()
//        node.runAction(bob)
//    }
    
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
        if player.volume < musicVolume {
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
    
    func shakeScreen() {
        if enableScreenShake {
            let shakeAnimation = CAKeyframeAnimation(keyPath: "transform")
//            let randomIntensityOne = CGFloat(random() % 4 + 1)
            let randomIntensityTwo = CGFloat(random() % 4 + 1)
            shakeAnimation.values = [
                //NSValue( CATransform3D:CATransform3DMakeTranslation(-randomIntensityOne, 0, 0 ) ),
                //NSValue( CATransform3D:CATransform3DMakeTranslation( randomIntensityOne, 0, 0 ) ),
                NSValue( CATransform3D:CATransform3DMakeTranslation( 0, -randomIntensityTwo, 0 ) ),
                NSValue( CATransform3D:CATransform3DMakeTranslation( 0, randomIntensityTwo, 0 ) ),
            ]
            shakeAnimation.repeatCount = 1
            shakeAnimation.duration = 25/100
            
            view!.layer.addAnimation(shakeAnimation, forKey: nil)
        }
    }
}

// Overload minus operator to use on CGPoint
func -(first: CGPoint, second: CGPoint) -> CGPoint {
    let deltaX = first.x - second.x
    let deltaY = first.y - second.y
    return CGPoint(x: deltaX, y: deltaY)
}
