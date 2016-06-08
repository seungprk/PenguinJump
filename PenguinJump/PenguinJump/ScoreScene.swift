//
//  ScoreScene.swift
//  PenguinJump
//
//  Created by Matthew Tso on 5/26/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit
import CoreData

class ScoreScene: SKScene {
    
    var highScore: Int!
    var score: Int!
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.whiteColor()
        
        fetchHighscore()
        
        let highScoreTitle = SKLabelNode(text: "Highscore")
        highScoreTitle.fontName = "Helvetica Neue Condensed Black"
        highScoreTitle.fontSize = 24
        highScoreTitle.position = CGPoint(x: CGRectGetMidX(view.frame), y: CGRectGetMidY(view.frame))
        highScoreTitle.position.y += 200
        highScoreTitle.fontColor = SKColor.blackColor()
        addChild(highScoreTitle)
        
        let highScoreLabel = SKLabelNode(text: "\(highScore)")
        highScoreLabel.fontName = "Helvetica Neue Condensed Black"
        highScoreLabel.fontSize = 120
        highScoreLabel.position = CGPoint(x: CGRectGetMidX(view.frame), y: CGRectGetMidY(view.frame))
        highScoreLabel.position.y += 100
        highScoreLabel.fontColor = SKColor.blackColor()
        addChild(highScoreLabel)
        
        let scoreTitle = SKLabelNode(text: "Last Run")
        scoreTitle.fontName = "Helvetica Neue Condensed Black"
        scoreTitle.fontSize = 24
        scoreTitle.position = CGPoint(x: CGRectGetMidX(view.frame), y: CGRectGetMidY(view.frame))
        scoreTitle.fontColor = SKColor.blackColor()
        addChild(scoreTitle)
        
        let scoreLabel = SKLabelNode(text: "\(score)")
        scoreLabel.fontName = "Helvetica Neue Condensed Black"
        scoreLabel.fontSize = 120
        scoreLabel.position = CGPoint(x: CGRectGetMidX(view.frame), y: CGRectGetMidY(view.frame))
        scoreLabel.position.y -= 100
        scoreLabel.fontColor = SKColor.blackColor()
        addChild(scoreLabel)
        
        let button = SKLabelNode(text: "Again")
        button.fontName = "Helvetica Neue Condensed Black"
        button.fontSize = 48
        button.position = CGPoint(x: CGRectGetMidX(view.frame), y: CGRectGetMidY(view.frame))
        button.position.y -= 200
        button.fontColor = SKColor.blackColor()
        button.name = "restartButton"
        addChild(button)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches
        let location = touch.first!.locationInNode(self)
        let node = self.nodeAtPoint(location)
        
        // If previous button is touched, start transition to previous scene
        if (node.name == "restartButton") {
            runAction(SKAction.playSoundFileNamed("button_press.m4a", waitForCompletion: false))
            
            let gameScene = GameScene(size: self.size)
            
            let transition = SKTransition.pushWithDirection(.Up, duration: 0.5)
            gameScene.scaleMode = SKSceneScaleMode.AspectFill
            self.scene!.view?.presentScene(gameScene, transition: transition)
        }
    }
    
    func fetchHighscore() {
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "GameData")
        
        var fetchedData = [GameData]()
        do {
            fetchedData = try managedObjectContext.executeFetchRequest(fetchRequest) as! [GameData]
        } catch {
            print(error)
        }
        
        if fetchedData.isEmpty {
            highScore = 0
        } else {
            highScore = fetchedData.first?.highScore as! Int
        }
    }
}
