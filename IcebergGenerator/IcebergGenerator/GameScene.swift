//
//  GameScene.swift
//  IcebergGenerator
//
//  Created by Matthew Tso on 5/22/16.
//  Copyright (c) 2016 De Anza. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var stage: SKSpriteNode?
    
    var forkNextBerg = false

    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor(red: 0.6, green: 0.9, blue: 1, alpha: 1)
        
        let sinkButton = SKLabelNode(text: "Bob")
        sinkButton.name = "bobButton"
        sinkButton.fontName = "Helvetica Neue Condensed Black"
        sinkButton.fontSize = 24
        sinkButton.fontColor = SKColor.blackColor()
        sinkButton.position = CGPoint(x: 30, y: view.frame.height - 30)
        addChild(sinkButton)
        
        let stopButton = SKLabelNode(text: "Stop")
        stopButton.name = "stopButton"
        stopButton.fontName = "Helvetica Neue Condensed Black"
        stopButton.fontSize = 24
        stopButton.fontColor = SKColor.blackColor()
        stopButton.position = CGPoint(x: 30, y: view.frame.height - 60)
        addChild(stopButton)
        
        let forkButton = SKLabelNode(text: "Fork")
        forkButton.name = "forkButton"
        forkButton.fontName = "Helvetica Neue Condensed Black"
        forkButton.fontSize = 24
        forkButton.fontColor = SKColor.blackColor()
        forkButton.position = CGPoint(x: 30, y: view.frame.height - 90)
        addChild(forkButton)
        
        stage = SKSpriteNode()
        stage!.position = view.center
        addChild(stage!)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        for touch in touches {
            let positionInScene = touch.locationInNode(self)
            let touchedNodes = self.nodesAtPoint(positionInScene)
            for touchedNode in touchedNodes {
                if let name = touchedNode.name
                {
                    if name == "bobButton" {
                        for berg in stage!.children {
                            let berg = berg as! Iceberg
                            berg.runSinkAction()
                        }
                    }
                    if name == "stopButton" {
                        for berg in stage!.children {
                            let berg = berg as! Iceberg
                            berg.removeAllActions()
                        }
                    }
                    if name == "forkButton" {
                        forkNextBerg = true
                    }
                }
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
//            let touch = touch as! UITouch
            let startPosition = touch.previousLocationInView(view)
            let currentPosition = touch.locationInView(view)
            
            for berg in stage!.children {
                berg.position.x -= startPosition.x - currentPosition.x
                berg.position.y += startPosition.y - currentPosition.y
            }
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        generateBerg()
    }
    
    func generateBerg() {
        // Check to see if the topmost iceberg is below the view's frame.
        var topmostBerg: CGFloat = 0.0
        for berg in stage!.children {
            if berg.position.y > topmostBerg {
                let bergPositionInScene = self.convertPoint(berg.position, fromNode: stage!)
                topmostBerg = bergPositionInScene.y
            }
        }
        
        // While the topmost iceberg is below the view's frame, generate an iceberg.
        while (topmostBerg < view!.frame.height) {
            if forkNextBerg {
                let bergLeft = Iceberg(size: CGSize(width: 150, height: 150))
                let bergRight = Iceberg(size: CGSize(width: 150, height: 150))
                
                if let previousBerg = stage?.children.first {
                    let previousBergPositionInScene = self.convertPoint(previousBerg.position, fromNode: stage!)
                    
                    var leftX: CGFloat
                    repeat {
                        leftX = CGFloat(random()) % (view!.frame.width * 0.4)// + (view!.frame.width * 0.1)
                    } while (previousBergPositionInScene.x - leftX > view!.frame.width * 0.4)
                    
                    var rightX:CGFloat
                    repeat {
                        rightX = CGFloat(random()) % (view!.frame.width * 0.4) + (view!.frame.width * 0.6)
                    } while (previousBergPositionInScene.x - rightX > view!.frame.width * 0.4)
                    
                    
                    let bergPositionInSceneY = previousBergPositionInScene.y + 350 // + randomY
                    topmostBerg = bergPositionInSceneY
                    
                    bergLeft.position = self.convertPoint(CGPoint(x: leftX, y: bergPositionInSceneY), toNode: stage!)
                    bergRight.position = self.convertPoint(CGPoint(x: rightX, y: bergPositionInSceneY), toNode: stage!)
                }
                stage!.insertChild(bergLeft, atIndex: 0)
                stage!.insertChild(bergRight, atIndex: 0)
                
                forkNextBerg = false
            } else {
                let berg = Iceberg(size: CGSize(width: 150, height: 150))
                
                if let previousBerg = stage?.children.first {
                    let previousBergPositionInScene = self.convertPoint(previousBerg.position, fromNode: stage!)
                    
                    var randomX: CGFloat
                    repeat {
                        randomX = CGFloat(random()) % (view!.frame.width * 0.8) + (view!.frame.width * 0.1)
                    } while (previousBergPositionInScene.x - randomX > view!.frame.width * 0.4)
                    
                    let bergPositionInSceneY = previousBergPositionInScene.y + 350 // + randomY
                    berg.position = self.convertPoint(CGPoint(x: randomX, y: bergPositionInSceneY), toNode: stage!)
                    
                    topmostBerg = bergPositionInSceneY
                    
                    if stage!.children.count > 5 {
                        berg.beginMovingBerg()
                    }
                    
                } else {
                    // If there are no previous icebergs, generate the initial iceberg under the penguin.
                    berg.position = CGPoint(x: 0, y: 0 - view!.frame.height * 0.4)
                }
                
                stage!.insertChild(berg, atIndex: 0)
            }
            
        }

    }
}
