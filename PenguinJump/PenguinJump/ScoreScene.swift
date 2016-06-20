//
//  ScoreScene.swift: Displays the all-time high score and the score of the last play session. The score of the last play session is zero when navigated to from the start menu instead of a game over state.
//
//  Created by Matthew Tso on 5/26/16.
//  Edited by Seung Park
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit
import CoreData

class ScoreScene: SKScene {
    
    var managedObjectContext : NSManagedObjectContext!
    var fetchRequest : NSFetchRequest!
    var gameData : GameData!
    
    var score: Int!
    
    var button : SimpleButton!
    
    override func didMoveToView(view: SKView) {
        managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        fetchRequest = NSFetchRequest(entityName: "GameData")
        var fetchedData = [GameData]()
        do {
            fetchedData = try managedObjectContext.executeFetchRequest(fetchRequest) as! [GameData]
        } catch {
            print(error)
        }
        gameData = fetchedData.first
        
        backgroundColor = SKColor(red: 220/255, green: 230/255, blue: 236/255, alpha: 1.0)
        
        let logo = SKSpriteNode(texture: SKTexture(image: UIImage(named: "logo")!))
        logo.name = "logo"
        logo.alpha = 0.2
        logo.position = CGPoint(x: size.width/2, y: size.height/2)
        logo.zPosition = -100
        addChild(logo)
        
        let highScoreTitle = SKLabelNode(text: "Highscore")
        highScoreTitle.fontName = "Helvetica Neue Condensed Black"
        highScoreTitle.fontSize = 24
        highScoreTitle.position = CGPoint(x: CGRectGetMidX(view.frame), y: CGRectGetMidY(view.frame))
        highScoreTitle.position.y += 200
        highScoreTitle.fontColor = SKColor(red: 35/255, green: 134/255, blue: 221/255, alpha: 1.0)
        addChild(highScoreTitle)
        
        let highScoreLabel = SKLabelNode(text: "\(gameData.highScore)")
        highScoreLabel.fontName = "Helvetica Neue Condensed Black"
        highScoreLabel.fontSize = 120
        highScoreLabel.position = CGPoint(x: CGRectGetMidX(view.frame), y: CGRectGetMidY(view.frame))
        highScoreLabel.position.y += 100
        highScoreLabel.fontColor = SKColor(red: 35/255, green: 134/255, blue: 221/255, alpha: 1.0)
        addChild(highScoreLabel)
        
        let scoreTitle = SKLabelNode(text: "Last Run")
        scoreTitle.fontName = "Helvetica Neue Condensed Black"
        scoreTitle.fontSize = 24
        scoreTitle.position = CGPoint(x: CGRectGetMidX(view.frame), y: CGRectGetMidY(view.frame))
        scoreTitle.fontColor = SKColor(red: 35/255, green: 134/255, blue: 221/255, alpha: 1.0)
        addChild(scoreTitle)
        
        let scoreLabel = SKLabelNode(text: "\(score)")
        scoreLabel.fontName = "Helvetica Neue Condensed Black"
        scoreLabel.fontSize = 120
        scoreLabel.position = CGPoint(x: CGRectGetMidX(view.frame), y: CGRectGetMidY(view.frame))
        scoreLabel.position.y -= 100
        scoreLabel.fontColor = SKColor(red: 35/255, green: 134/255, blue: 221/255, alpha: 1.0)
        addChild(scoreLabel)
        
        button = SimpleButton(text: "Back")
        button.name = "restartButton"
        button.position = CGPoint(x: CGRectGetMidX(view.frame), y: CGRectGetMidY(view.frame))
        button.position.y -= 200
        addChild(button)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let positionInScene = touch.locationInNode(self)
            let touchedNodes = self.nodesAtPoint(positionInScene)
            for touchedNode in touchedNodes {
                if (touchedNode.name == "restartButton") {
                    button.buttonPress(gameData.soundEffectsOn)
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let positionInScene = touch.locationInNode(self)
            let touchedNodes = self.nodesAtPoint(positionInScene)
            for touchedNode in touchedNodes {
                // If previous button is touched, start transition to previous scene
                if (touchedNode.name == "restartButton" && button.pressed == true) {
                    button.buttonRelease()
                    
                    let gameScene = GameScene(size: self.size)
                    let transition = SKTransition.pushWithDirection(.Up, duration: 0.5)
                    gameScene.scaleMode = SKSceneScaleMode.AspectFill
                    self.scene!.view?.presentScene(gameScene, transition: transition)
                }
            }
        }
        button.buttonRelease()
    }
}
