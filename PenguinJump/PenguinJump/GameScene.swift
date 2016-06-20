//
//  GameSceneUsingCamera.swift
//  PenguinJump
//
//  Created by Matthew Tso on 5/25/16.
//  Edited by Seung Park.
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit
import CoreData
import AVFoundation

/// The `ColorValues` structure holds RGBA values separately so arithmetic operations can be performed on individual values. Each value is a CGFloat between 0.0 and 1.0
struct ColorValues {
    var red: CGFloat!
    var green: CGFloat!
    var blue: CGFloat!
    var alpha: CGFloat!
}

class GameScene: SKScene, IcebergGeneratorDelegate {
    
    // Framework Objects
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let fetchRequest = NSFetchRequest(entityName: "GameData")
    var gameData : GameData!
    
    // Game options
    var enableScreenShake = true
    
    // Constant game properties
    let bgColorValues = ColorValues(red: 0/255, green: 151/255, blue: 255/255, alpha: 1)
    let stormDuration = 15.0
    let stormTransitionDuration = 2.0
    
    // Node Objects
    var cam:SKCameraNode!
    var penguin: Penguin!
    var stage: IcebergGenerator!
    let jumpAir = SKShapeNode(circleOfRadius: 20.0)
    var waves: Waves!
    var background: Background!
    var coinLayer: SKNode?
    var lightningLayer: SKNode?
    var sharkLayer: SKNode?
    
    // Audio
    var backgroundMusic: AVAudioPlayer?
    var backgroundOcean: AVAudioPlayer?
    
    var splashSound: AVAudioPlayer?
    var jumpSound: AVAudioPlayer?
    var landingSound: AVAudioPlayer?
    var buttonPressSound: AVAudioPlayer?
    var coinSound: AVAudioPlayer?
    var alertSound: AVAudioPlayer?
    var sharkSound: AVAudioPlayer?
    var lurkingSound: AVAudioPlayer?
    var zapSound: AVAudioPlayer?
    var thunderSound: AVAudioPlayer?
    var powerUpSound: AVAudioPlayer?
    var burstSound: AVAudioPlayer?
    
    var musicInitialized = false
    
    // Labels
    var startMenu : StartMenuNode!
    
    // Information bar
    var intScore = 0
    var totalCoins = 0
    var scoreLabel: SKLabelNode!
    var coinLabel: SKLabelNode!
    var chargeBar: ChargeBar!
    var shouldFlash = false
    let pauseButton = SKLabelNode(text: "I I")
    
    // Audio settings -> fetched from CoreData?
    var musicVolume:Float = 1.0
    var soundVolume:Float = 1.0
    
    // Debug
    var testZoomed = false
    var viewOutlineOn = false
    var viewFrame: SKShapeNode!
    
    let debugButton = SKLabelNode(text: "DEBUG")
    let zoomButton = SKLabelNode(text: "ZOOM")
    let rainButton = SKLabelNode(text: "RAINDROP")
    let lightningButton = SKLabelNode(text: "LIGHTNING")
    let sharkButton = SKLabelNode(text: "SHARK")
    let stormButton = SKLabelNode(text: "STORM")
    let moneyButton = SKLabelNode(text: "MONEY")
    let viewOutlineButton = SKLabelNode(text: "OUTLINE VIEW")
    
    // Game session logic
    var gameBegin = false
    var gameRunning = false
    var gameOver = false
    var gamePaused = false
    var shouldCorrectAfterPause = false
    var playerTouched = false
    var freezeCamera = false
    /// Difficulty modifier that ranges from `0.0` to `1.0`.
    var difficulty = 0.0
    
    var previousTime: NSTimeInterval?
    var timeSinceLastUpdate: NSTimeInterval = 0.0
    var stormTimeElapsed: NSTimeInterval = 0.0
    var stormIntensity = 0.0
    var stormMode = false
    var windSpeed = 0.0
    var windEnabled = true
    var windDirectionRight = true
    
    // MARK: - Scene setup
    
    override func didMoveToView(view: SKView) {
        // Set up audio files
        if musicInitialized == false {
            musicInitialized = true
            if let backgroundMusic = audioPlayerWithFile("Reformat", type: "mp3") {
                self.backgroundMusic = backgroundMusic
            }
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
        if let alertSound = audioPlayerWithFile("alert", type: "mp3") {
            self.alertSound = alertSound
        }
        if let sharkSound = audioPlayerWithFile("roar", type: "wav") {
            self.sharkSound = sharkSound
        }
        if let lurkingSound = audioPlayerWithFile("lurking", type: "mp3") {
            lurkingSound.numberOfLoops = -1
            self.lurkingSound = lurkingSound
        }
        if let zapSound = audioPlayerWithFile("zap", type: "mp3") {
            self.zapSound = zapSound
        }
        if let thunderSound = audioPlayerWithFile("thunder", type: "wav") {
            self.thunderSound = thunderSound
        }
        if let powerUpSound = audioPlayerWithFile("power_up", type: "mp3") {
            self.powerUpSound = powerUpSound
        }
        if let burstSound = audioPlayerWithFile("balloon_pop", type: "mp3") {
            self.burstSound = burstSound
        }
        
        
        // Fetch total coins data and sound settings
        var fetchedData = [GameData]()
        do {
            fetchedData = try managedObjectContext.executeFetchRequest(fetchRequest) as! [GameData]
        } catch {
            print(error)
        }
        if fetchedData.first != nil {
            gameData = fetchedData.first
        }
      
        // Physics setup
        setupPhysics()
        
        // Set up Game Scene
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
        
        // Set up Debugging buttons
//        setupDebugButtons()
        
        pauseButton.name = "pauseButton"
        pauseButton.fontName = "Helvetica Neue Condensed Black"
        pauseButton.fontSize = 24
        pauseButton.zPosition = 200000
        pauseButton.fontColor = UIColor.blackColor()
        pauseButton.position = CGPoint(x: view.frame.width * 0.5, y: view.frame.height * 0.47)
        pauseButton.position.x -= pauseButton.frame.width * 1.5
        pauseButton.position.y -= pauseButton.frame.height * 2
        pauseButton.alpha = 0
        cam.addChild(pauseButton)
        
        // Register for application state notifications.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "enterPause", name: UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "becomeActive", name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    func setupScene() {
        
        gameOver = false
        
        cam = SKCameraNode()
        cam.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMidY(frame))
        camera = cam
        addChild(cam)        
        
        stage = IcebergGenerator(view: view!, camera: cam)
        stage.position = view!.center
        stage.zPosition = 10
        stage.delegate = self
        addChild(stage)
        
        coinLayer = SKNode()
        coinLayer?.position = view!.center
        coinLayer?.zPosition = 500 // above stage
        addChild(coinLayer!)
        
        lightningLayer = SKNode()
        lightningLayer?.position = view!.center
        lightningLayer?.zPosition = 500 // same level as coins (for shadow)
        addChild(lightningLayer!)
        
        sharkLayer = SKNode()
        sharkLayer?.position = view!.center
        sharkLayer?.zPosition = 0
        addChild(sharkLayer!)
        
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
        
        coinLabel = SKLabelNode(text: "\(totalCoins) coins")
        coinLabel.fontName = "Helvetica Neue Condensed Black"
        coinLabel.fontSize = 24
        coinLabel.fontColor = SKColor.blackColor()
        coinLabel.position = CGPoint(x: view!.frame.width * 0.45, y: view!.frame.height * 0.45)
        coinLabel.zPosition = 30000
        coinLabel.horizontalAlignmentMode = .Right
        cam.addChild(coinLabel)
        
        // Fetch penguin type
        var fetchedData = [GameData]()
        var penguinType: PenguinType!
        do {
            fetchedData = try managedObjectContext.executeFetchRequest(fetchRequest) as! [GameData]
                
            do {
                fetchedData = try managedObjectContext.executeFetchRequest(fetchRequest) as! [GameData]
            } catch { print(error) }
            
        } catch {
            print(error)
        }
        
        if let gameData = fetchedData.first {
            switch (gameData.selectedPenguin as String) {
            case "normal":
                penguinType = .normal
            case "parasol":
                penguinType = .parasol
            case "tinfoil":
                penguinType = .tinfoil
            case "shark":
                penguinType = .shark
            case "penguinAngel":
                penguinType = .penguinAngel
            case "penguinCrown":
                penguinType = .penguinCrown
            case "penguinDuckyTube":
                penguinType = .penguinDuckyTube
            case "penguinMarathon":
                penguinType = .penguinMarathon
            case "penguinMohawk":
                penguinType = .penguinMohawk
            case "penguinPolarBear":
                penguinType = .penguinPolarBear
            case "penguinPropellerHat":
                penguinType = .penguinPropellerHat
            case "penguinSuperman":
                penguinType = .penguinSuperman
            case "penguinTophat":
                penguinType = .penguinTophat
            case "penguinViking":
                penguinType = .penguinViking
            default:
                penguinType = .normal
            }
            totalCoins = gameData.totalCoins as Int
            coinLabel.text = "\(totalCoins) coins"
        }
        
        // Wrap penguin around a cropnode for death animation
        let penguinPositionInScene = CGPoint(x: size.width * 0.5, y: size.height * 0.3)
        
        penguin = Penguin(type: penguinType)

        penguin.position = penguinPositionInScene
        penguin.zPosition = 2100
        penguin.userInteractionEnabled = true
        addChild(penguin)
        
        stage.newGame(convertPoint(penguinPositionInScene, toNode: stage))
        
        waves = Waves(camera: cam, gameScene: self)
        waves.position = view!.center
        waves.zPosition = 0
        addChild(waves)
        waves.stormMode = self.stormMode
        waves.bob()
        
        background = Background(view: view!, camera: cam)
        background.position = view!.center
        background.zPosition = -1000
        addChild(background)
        
        playMusic()
    }
    
    // MARK: - Debug Buttons
    
    /// Initializes and adds to camera all debug buttons
    func setupDebugButtons() {
        
        debugButtonInitialize(debugButton)
        debugButton.name = "debugButton"
        debugButton.position = CGPoint(x: 0, y: view!.frame.height / 2 - debugButton.frame.height * 2)
        
        debugButtonInitialize(zoomButton)
        zoomButton.name = "testZoom"
        zoomButton.position = CGPoint(x: 0, y: view!.frame.height / 2 - debugButton.frame.height * 2)

        debugButtonInitialize(rainButton)
        rainButton.name = "rainButton"
        rainButton.position = CGPoint(x: 0, y: view!.frame.height / 2 - debugButton.frame.height * 3)
        
        debugButtonInitialize(lightningButton)
        lightningButton.name = "lightningButton"
        lightningButton.position = CGPoint(x: 0, y: view!.frame.height / 2 - debugButton.frame.height * 4)
        
        debugButtonInitialize(sharkButton)
        sharkButton.name = "sharkButton"
        sharkButton.position = CGPoint(x: 0, y: view!.frame.height / 2 - debugButton.frame.height * 5)
        
        debugButtonInitialize(stormButton)
        stormButton.name = "stormButton"
        stormButton.position = CGPoint(x: 0, y: view!.frame.height / 2 - debugButton.frame.height * 6)

        debugButtonInitialize(moneyButton)
        moneyButton.name = "moneyButton"
        moneyButton.position = CGPoint(x: 0, y: view!.frame.height / 2 - debugButton.frame.height * 7)

        debugButtonInitialize(viewOutlineButton)
        viewOutlineButton.name = "viewOutlineButton"
        viewOutlineButton.position = CGPoint(x: 0, y: view!.frame.height / 2 - debugButton.frame.height * 8)
        
        zoomButton.hidden = true
        rainButton.hidden = true
        lightningButton.hidden = true
        sharkButton.hidden = true
        stormButton.hidden = true
        moneyButton.hidden = true
        viewOutlineButton.hidden = true
        
        viewFrame = SKShapeNode(rectOfSize: view!.frame.size)
        viewFrame.position = cam.position
        viewFrame.strokeColor = SKColor.redColor()
        viewFrame.fillColor = SKColor.clearColor()
        viewFrame.hidden = viewOutlineOn ? false : true
        addChild(viewFrame)
    }
    
    func debugButtonInitialize(button: SKLabelNode) {
        button.fontName = "Helvetica Neue Condensed Black"
        button.fontSize = 24
        button.alpha = 0.5
        button.zPosition = 2000000
        button.fontColor = UIColor.blackColor()
        
        cam.addChild(button)
    }
    
    // MARK: - Scene Controls
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let positionInScene = touch.locationInNode(self)
            let touchedNodes = self.nodesAtPoint(positionInScene)
            for touchedNode in touchedNodes {
                if let name = touchedNode.name {
                    
                    // Debug Functionality
                    if name == "debugButton" {
                        debugButton.hidden = true
                        zoomButton.hidden = false
                        rainButton.hidden = false
                        lightningButton.hidden = false
                        sharkButton.hidden = false
                        stormButton.hidden = false
                        moneyButton.hidden = false
                        viewOutlineButton.hidden = false
                    } else {
                        debugButton.hidden = false
                        zoomButton.hidden = true
                        rainButton.hidden = true
                        lightningButton.hidden = true
                        sharkButton.hidden = true
                        stormButton.hidden = true
                        moneyButton.hidden = true
                        viewOutlineButton.hidden = true
                        
                        switch name {
                        case "testZoom":
                            let zoomOut = SKAction.scaleTo(3.0, duration: 0.5)
                            let zoomIn = SKAction.scaleTo(1.0, duration: 0.5)
                            
                            testZoomed ? cam.runAction(zoomIn) : cam.runAction(zoomOut)
                            testZoomed = testZoomed ? false : true
                            
                        case "rainButton":
                            let raindrop = Raindrop()
                            raindrop.zPosition = 100000
                            raindrop.drop(view!.center, windSpeed: windSpeed)
                            addChild(raindrop)

                        case "lightningButton":
                            if let berg = (stage as IcebergGenerator).highestBerg {
                                let lightningRandomX = CGFloat(random()) % berg.size.width - berg.size.width / 2
                                let lightningRandomY = CGFloat(random()) % berg.size.height - berg.size.height / 2
                                let lightningPosition = CGPoint(x: berg.position.x + lightningRandomX, y: berg.position.y + lightningRandomY)
                                let lightning = Lightning(view: view!)
                                lightning.position = lightningPosition
                                lightningLayer?.addChild(lightning)
                            }
                        case "sharkButton":
                            if let berg = (stage as IcebergGenerator).highestBerg {
                                let sharkX = berg.position.x
                                let sharkY = berg.position.y + (350 / 4)
                                let sharkPosition = CGPoint(x: sharkX, y: sharkY)
                                
                                let shark = Shark()
                                shark.position = sharkPosition
                                sharkLayer?.addChild(shark)
                                shark.beginSwimming()
                            }
                        case "stormButton":
                            beginStorm()
                        
                        case "moneyButton":
                            for _ in 1...1000 {
                                incrementTotalCoins()
                            }
                            
                        case "viewOutlineButton":
                            viewOutlineOn = !viewOutlineOn
                        
                        case "pauseButton":
                            enterPause()
                        
                        case "pauseCover":
                            exitPause()
                            
                        default:
                            break
                        }
                    }
                }
                
                // Doublejump Functionality
                else if penguin.inAir && !penguin.doubleJumped {
                    penguin.savePosForDoubleJump(positionInScene, time: touch.timestamp)
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let positionInScene = touch.locationInNode(self)
            // Doublejump Functionality
            if penguin.inAir && !penguin.doubleJumped {
                penguin.doubleJump(positionInScene, time: touch.timestamp)
            }
        }
    }
    /*
    func doubleJump(velocity: CGVector) {
        let nudgeRate: CGFloat = 180
        let nudgeDistance = sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy)
        let nudgeDuration = Double(nudgeDistance / nudgeRate)
        
        let nudge = SKAction.moveBy(velocity, duration: nudgeDuration)
        penguin.runAction(nudge)
        jumpSound?.currentTime = 0
        if gameData.soundEffectsOn == true { jumpSound?.play() }
    }*/
    
    // MARK: - Pause state
    
    func becomeActive() {
        if gamePaused {
            enterPause()
        }
    }
    
    func enterPause() {
        if gameRunning {
            shouldCorrectAfterPause = true
            gamePaused = true
            penguin.userInteractionEnabled = false
            paused = true
            
            var needsPauseCover = true
            if let _ = childNodeWithName("pauseCover") {
                needsPauseCover = false
            }
            
            if needsPauseCover {
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
    }
    
    func exitPause() {
        for child in children {
            if child.name == "pauseCover" {
                child.removeFromParent()
            }
        }
        gamePaused = false
        penguin.userInteractionEnabled = true
        paused = false
    }
    
    // MARK: - Game Events
    
    func beginGame() {

        penguin.beginGame()

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
            
            self.pauseButton.alpha = 1
            
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
    
    func beginStorm() {
        stormMode = true
        
        if self.gameData.soundEffectsOn as Bool {
            thunderSound?.play()
        }
        
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
            
            if gameData.soundEffectsOn == true { splashSound?.play() }
            
            if gameData != nil {
                let highScore = gameData.highScore as Int
                
                if intScore > highScore {
                    gameData.highScore = intScore
                    
                    do { try managedObjectContext.save() } catch { print(error) }
                }
            }
            
            lurkingSound?.stop()
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

    // MARK: - Iceberg Generator Delegate method
    
    func didGenerateIceberg(generatedIceberg: Iceberg) {
        let berg = generatedIceberg
        
        let coinRandomX = CGFloat(random()) % berg.size.width - berg.size.width / 2
        let coinRandomY = CGFloat(random()) % berg.size.height - berg.size.height / 2
        let coinPosition = CGPoint(x: berg.position.x + coinRandomX, y: berg.position.y + coinRandomY)
        
        let coinRandom = random() % 3
        if coinRandom == 0 {
            let coin = Coin()
            coin.position = coinPosition
            coinLayer?.addChild(coin)
        }
        
        let lightningRandomX = CGFloat(random()) % berg.size.width - berg.size.width / 2
        let lightningRandomY = CGFloat(random()) % berg.size.height - berg.size.height / 2
        let lightningPosition = CGPoint(x: berg.position.x + lightningRandomX, y: berg.position.y + lightningRandomY)
        
        let stormIntensityInverseModifier = (2 * stormIntensity + 1)
        let lightningProbability = (-95 * difficulty + 100)
        let lightningRandom: Int = random() % Int(lightningProbability / stormIntensityInverseModifier)
        if lightningRandom == 0 {
            let lightning = Lightning(view: view!)
            lightning.position = lightningPosition
            lightningLayer?.addChild(lightning)
        }
        
        if generatedIceberg.name != "rightBerg" && generatedIceberg.name != "leftBerg" {
            // Can put in a shark
            
            // Reusing lightning RNG
            if lightningRandom == 1 {
                let sharkX = berg.position.x
                let sharkY = berg.position.y + (350 / 4)
                let sharkPosition = CGPoint(x: sharkX, y: sharkY)
                
                let shark = Shark()
                shark.position = sharkPosition
                sharkLayer?.addChild(shark)
                shark.beginSwimming()
            }
        }
    }
    
    // MARK: - Camera control
    
    func centerCamera() {
        if !freezeCamera {
            let cameraFinalDestX = penguin.position.x
            let cameraFinalDestY = penguin.position.y + frame.height / 6
            
            let pan = SKAction.moveTo(CGPoint(x: cameraFinalDestX, y: cameraFinalDestY), duration: 0.125)
            pan.timingMode = .EaseInEaseOut
            
            cam.runAction(pan)
            
            if let viewFrame = viewFrame {
                if viewOutlineOn {
                    viewFrame.hidden = false
                    viewFrame.position = cam.position
                } else {
                    viewFrame.hidden = true
                }
            }
            
        } else {
            cam.removeAllActions()
        }
    }
}
