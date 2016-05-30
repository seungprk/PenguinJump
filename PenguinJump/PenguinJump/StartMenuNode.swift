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
        
        // Button "High Scores"
        let highScoreButton = SKLabelNode(text: "High Scores")
        highScoreButton.fontName = "Helvetica Neue Condensed Black"
        highScoreButton.fontSize = 30
        highScoreButton.fontColor = SKColor.blackColor()
        highScoreButton.position = CGPointZero
        highScoreButton.position.y = playButton.position.y - playButton.frame.height
        highScoreButton.zPosition = 10000
        
        // Button "About"
        let aboutButton = SKLabelNode(text: "About")
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
        addChild(highScoreButton)
        addChild(aboutButton)
        addChild(playButton)
    }
    
    // ******** WORK IN PROGRESS!!!!! *********
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let scoreScene = ScoreScene(size: frame.size)
        
        scoreScene.highScore = 5
        scoreScene.score = 5
        
        let transition = SKTransition.moveInWithDirection(.Up, duration: 0.5)
        scoreScene.scaleMode = SKSceneScaleMode.AspectFill
        self.scene!.view?.presentScene(scoreScene, transition: transition)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
