//
//  StartMenuNode.swift
//  PenguinJump
//
//  Created by Seung Park on 5/30/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit

class StartMenuNode: SKNode {
    
    let title = SKSpriteNode(texture: nil)
    let playButton = SKLabelNode(text: "Play")
    let highScoreButton = SKLabelNode(text: "High Scores")
    let aboutButton = SKLabelNode(text: "About")
    let settingsButton = SKLabelNode(text: "Settings")
    
    init(frame: CGRect) {
        super.init()
        
        // Main Title
        title.position = CGPointZero
        title.position.y += frame.height / 3
        title.zPosition = 10000
        
        let titleLabel = SKLabelNode(text: "PENGUIN")
        titleLabel.fontName = "Helvetica Neue Condensed Black"
        titleLabel.fontSize = 80
        titleLabel.position = CGPointZero
        
        let subtitleLabel = SKLabelNode(text: "JUMP")
        subtitleLabel.fontName = "Helvetica Neue Condensed Black"
        subtitleLabel.fontSize = 122
        subtitleLabel.position = CGPointZero
        subtitleLabel.position.y -= subtitleLabel.frame.height
        
        // Button "Play"
        playButton.name = "playButton"
        playButton.fontName = "Helvetica Neue Condensed Black"
        playButton.fontSize = 60
        playButton.fontColor = SKColor.blackColor()
        playButton.position = CGPointZero
        playButton.position.y -= frame.height * 0.20
        playButton.zPosition = 10000
        
        let shrinkDown = SKAction.scaleTo(0.95, duration: 0.1)
        let bumpUp = SKAction.scaleTo(1.05, duration: 0.1)
        let bumpDown = SKAction.scaleTo(1.0, duration: 0.1)
        let bumpWait = SKAction.waitForDuration(2.0)
        let bump = SKAction.sequence([shrinkDown, bumpUp, bumpDown, bumpWait])
        playButton.runAction(SKAction.repeatActionForever(bump))
        
        // Button "Settings"
        settingsButton.name = "settingsButton"
        settingsButton.fontName = "Helvetica Neue Condensed Black"
        settingsButton.fontSize = 30
        settingsButton.fontColor = SKColor.blackColor()
        settingsButton.position = CGPointZero
        settingsButton.position.y = playButton.position.y - playButton.frame.height
        settingsButton.zPosition = 10000
        
        // Button "High Scores"
        highScoreButton.name = "highScoreButton"
        highScoreButton.fontName = "Helvetica Neue Condensed Black"
        highScoreButton.fontSize = 30
        highScoreButton.fontColor = SKColor.blackColor()
        highScoreButton.position = CGPointZero
        highScoreButton.position.y = settingsButton.position.y - playButton.frame.height
        highScoreButton.zPosition = 10000
        
        // Button "About"
        aboutButton.name = "aboutButton"
        aboutButton.fontName = "Helvetica Neue Condensed Black"
        aboutButton.fontSize = 40
        aboutButton.fontColor = SKColor.blackColor()
        aboutButton.position = CGPointZero
        aboutButton.position.y = highScoreButton.position.y - playButton.frame.height
        aboutButton.zPosition = 10000
        
        // Add to screen
        title.addChild(titleLabel)
        title.addChild(subtitleLabel)
        addChild(title)
        addChild(settingsButton)
        addChild(highScoreButton)
        addChild(aboutButton)
        addChild(playButton)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let parentScene = scene as! GameScene
        
        for touch in touches {
            let positionInScene = touch.locationInNode(self)
            let touchedNodes = self.nodesAtPoint(positionInScene)
            for touchedNode in touchedNodes {
                if let name = touchedNode.name
                {
                    if name == "restartButton" {
                        parentScene.restart()
                        parentScene.gameRunning = true
                    }
                    if touchedNode.name == "playButton" {
                        let titleUp = SKAction.moveBy(CGVector(dx: 0, dy: 400), duration: 1.0)
                        titleUp.timingMode = .EaseIn
                        title.runAction(titleUp, completion: {
                            self.title.removeFromParent()
                        })
                        let playButtonDown = SKAction.moveBy(CGVector(dx: 0, dy: -300), duration: 1.0)
                        playButtonDown.timingMode = .EaseIn
                        playButton.runAction(playButtonDown, completion: {
                            self.playButton.removeFromParent()
                        })
                        settingsButton.runAction(playButtonDown, completion: {
                            self.settingsButton.removeFromParent()
                        })
                        highScoreButton.runAction(playButtonDown, completion: {
                            self.highScoreButton.removeFromParent()
                        })
                        aboutButton.runAction(playButtonDown, completion: {
                            self.aboutButton.removeFromParent()
                        })
                        parentScene.beginGame()
                        parentScene.buttonPressSound?.play()
                    }
                    if touchedNode.name == "highScoreButton" {
                        let scoreScene = ScoreScene(size: scene!.size)
                        let parentScene = scene as! GameScene
                        scoreScene.score = parentScene.intScore
                        
                        let transition = SKTransition.moveInWithDirection(.Up, duration: 0.5)
                        scoreScene.scaleMode = SKSceneScaleMode.AspectFill
                        self.scene!.view?.presentScene(scoreScene, transition: transition)
                    }
                    if touchedNode.name == "settingsButton" {
                        let settingsScene = SettingsScene(size: scene!.size)
                        let transition = SKTransition.moveInWithDirection(.Up, duration: 0.5)
                        settingsScene.scaleMode = SKSceneScaleMode.AspectFill
                        self.scene!.view?.presentScene(settingsScene, transition: transition)
                    }
                    if touchedNode.name == "aboutButton" {
                        let aboutScene = AboutScene(size: scene!.size)
                        let transition = SKTransition.moveInWithDirection(.Up, duration: 0.5)
                        aboutScene.scaleMode = SKSceneScaleMode.AspectFill
                        self.scene!.view?.presentScene(aboutScene, transition: transition)
                    }
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
