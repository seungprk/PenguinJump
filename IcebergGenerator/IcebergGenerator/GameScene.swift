//
//  GameScene.swift
//  IcebergGenerator
//
//  Created by Matthew Tso on 5/22/16.
//  Copyright (c) 2016 De Anza. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    
    var forkNextBerg = false
    var forking = false
    var topmostOfLeft: Iceberg?
    var topmostOfRight: Iceberg?
    var pathing = ""
    var stormMode = false
    
    var stage: SKSpriteNode?
    var waves: SKSpriteNode?
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor(red: 0.55, green: 0.9, blue: 95, alpha: 1)
//        backgroundColor = SKColor(red: 0.35, green: 0.5, blue: 0.57, alpha: 1) // Storm color
        
        let sinkButton = SKLabelNode(text: "Sink")
        sinkButton.name = "sinkButton"
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
        
        let stormButton = SKLabelNode(text: "Storm")
        stormButton.name = "stormButton"
        stormButton.fontName = "Helvetica Neue Condensed Black"
        stormButton.fontSize = 24
        stormButton.fontColor = SKColor.blackColor()
        stormButton.position = CGPoint(x: 30, y: view.frame.height - 120)
        addChild(stormButton)
        
        stage = SKSpriteNode()
        stage!.position = view.center
        addChild(stage!)
        
        
        waves = SKSpriteNode()
        waves!.position = view.center
        addChild(waves!)
        
        // Fake wave crests
        for crest in 1...34 {
            let yPosition = view.frame.height / 30
            
            let wave = SKSpriteNode()
            wave.name = "crest"
            wave.color = SKColor.whiteColor()
            wave.size = CGSize(width: view.frame.width, height: 0.5)
            wave.position = CGPoint(x: 0, y: -view.frame.height / 2 + yPosition * CGFloat(crest) - 20)
//            testLine.zPosition = -1000
            waves!.addChild(wave)
        }
        
        bob(waves!)

    }
    
    func bob(node: SKSpriteNode) {
        let bobDepth = stormMode ? 7 : 2.0
        let bobDuration = stormMode ? 0.8 : 2.0
        
        let down = SKAction.moveBy(CGVector(dx: 0.0, dy: bobDepth), duration: bobDuration)
        let wait = SKAction.waitForDuration(bobDuration / 2)
        let up = SKAction.moveBy(CGVector(dx: 0.0, dy: -bobDepth), duration: bobDuration)
        
        let bobSequence = SKAction.sequence([down, wait, up, wait])
        let bob = SKAction.repeatActionForever(bobSequence)
        
        node.removeAllActions()
        node.runAction(bob)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        for touch in touches {
            let positionInScene = touch.locationInNode(self)
            let touchedNodes = self.nodesAtPoint(positionInScene)
            for touchedNode in touchedNodes {
                if let name = touchedNode.name
                {
                    if name == "sinkButton" {
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
//                        forkNextBerg = true
                        forking = true
                    }
                    if name == "stormButton" {
                        stormMode = stormMode ? false : true
                        backgroundColor = stormMode ?
                            SKColor(red: 0.35, green: 0.5, blue: 0.57, alpha: 1) :
                            SKColor(red: 0.55, green: 0.9, blue: 95, alpha: 1)
                        for child in stage!.children {
                            let berg = child as! Iceberg
//                            berg.removeAllActions()
                            berg.stormMode = stormMode ? true : false
                            berg.bob()
                            bob(waves!)
                        }
                    }
                }
                if touchedNode.isKindOfClass(Iceberg) {
                    print(touchedNode.position)
                    print("clicked on \(touchedNode.name)")
                    
                    touchedNode.removeAllActions()
                    
                    if touchedNode.name == "left" {
                        print("pathing left")
                        forking = true
                        pathing = "left"
                    } else if touchedNode.name == "right" {
                        print("pathing right")
                        forking = true
                        pathing = "right"
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
        
        clearBerg()
    }
    
    func clearBerg() {
        for child in stage!.children {
            let berg = child as! Iceberg
            if berg.position.y < -view!.frame.height / 2 - 60 {

                berg.removeFromParent()
            }
        }
    }
    
    func generateBerg() {
        // Check to see if the topmost iceberg is below the view's frame.
        var topmostBergY: CGFloat = 0.0
        for berg in stage!.children {
            if berg.position.y > topmostBergY{
                let bergPositionInScene = self.convertPoint(berg.position, fromNode: stage!)
                topmostBergY = bergPositionInScene.y
            }
        }
        
        // While the topmost iceberg is below the view's frame, generate an iceberg.
        while (topmostBergY < view!.frame.height) {
            if forking {
                switch (pathing) {
                    case "":
                        let bergLeft = Iceberg(size: CGSize(width: 150, height: 150))
                        let bergRight = Iceberg(size: CGSize(width: 150, height: 150))
                        
                        bergLeft.name = "left"
                        bergRight.name = "right"
                        
                        if let previousBerg = stage?.children.first {
                            // Get position of previous berg in scene
                            let previousBergPositionInScene = self.convertPoint(previousBerg.position, fromNode: stage!)
                            
//                            var leftX: CGFloat
//                            repeat {
//                                leftX = CGFloat(random()) % (view!.frame.width * 0.4)// + (view!.frame.width * 0.1)
//                            } while (previousBergPositionInScene.x - leftX > view!.frame.width * 0.4)
//                            
//                            var rightX:CGFloat
//                            repeat {
//                                rightX = CGFloat(random()) % (view!.frame.width * 0.4) + (view!.frame.width * 0.6)
//                            } while (previousBergPositionInScene.x - rightX > view!.frame.width * 0.4)
                            
                            // Calculate the x position relative to view frame width.
                            let leftX = CGFloat(random()) % (view!.frame.width * 0.4)
                            let rightX = CGFloat(random()) % (view!.frame.width * 0.4) + (view!.frame.width * 0.6)
                            
                            // Calculate the y position relative to the previous berg location
                            let bergPositionInSceneY = previousBergPositionInScene.y + 350 // + randomY
                            
                            // Set the topmostBergY Position to new yPosition
                            topmostBergY = bergPositionInSceneY
                            
                            // Set Values
                            bergLeft.position = self.convertPoint(CGPoint(x: leftX, y: bergPositionInSceneY), toNode: stage!)
                            bergRight.position = self.convertPoint(CGPoint(x: rightX, y: bergPositionInSceneY), toNode: stage!)
                        }
                        stage!.insertChild(bergLeft, atIndex: 0)
                        stage!.insertChild(bergRight, atIndex: 0)
                        
                        topmostOfLeft = bergLeft
                        topmostOfRight = bergRight
                    
                        pathing = "undecided"
                    
                    case "undecided":
                        let bergLeft = Iceberg(size: CGSize(width: 150, height: 150))
                        let bergRight = Iceberg(size: CGSize(width: 150, height: 150))
                    
                        bergLeft.name = "left"
                        bergRight.name = "right"
                        
                        if let previousLeft = topmostOfLeft {
//                            var leftXDifference: CGFloat
//                            repeat {
//                                leftXDifference = CGFloat(random()) % (view!.frame.width * 0.3)// + (view!.frame.width * 0.1)
//                            } while (leftXDifference > view!.frame.width * 0.4)
                            let previousBergLeftPositionInScene = self.convertPoint(previousLeft.position, fromNode: stage!)

                            let leftXDifference = CGFloat(random()) % (view!.frame.width * 0.3)
                            let leftY = previousBergLeftPositionInScene.y + 350
                            
                            bergLeft.position = self.convertPoint(CGPoint(x: previousBergLeftPositionInScene.x - leftXDifference, y: leftY), toNode: stage!)
                            
                            if leftY > topmostBergY {
                                topmostBergY = leftY
                            }
                        }
                        
                        if let previousRight = topmostOfRight {
//                            var rightX:CGFloat
//                            repeat {
//                                rightX = CGFloat(random()) % (view!.frame.width * 0.4) + (view!.frame.width * 0.6)
//                            } while (previousRight.position.x - rightX > view!.frame.width * 0.4)
                            let previousBergRightPositionInScene = self.convertPoint(previousRight.position, fromNode: stage!)

                            
                            let rightXDifference = CGFloat(random()) % (view!.frame.width * 0.3)
                            let rightY = previousBergRightPositionInScene.y + 350
                            
                            bergRight.position = self.convertPoint(CGPoint(x: previousBergRightPositionInScene.x + rightXDifference, y: rightY), toNode: stage!)
                            
                            if rightY > topmostBergY {
                                topmostBergY = rightY
                            }
                        }
                        
                        stage!.insertChild(bergLeft, atIndex: 0)
                        stage!.insertChild(bergRight, atIndex: 0)

                        topmostOfLeft = bergLeft
                        topmostOfRight = bergRight
                    
                    case "left":
                        print("making left berg")
                        let berg = Iceberg(size: CGSize(width: 150, height: 150))

                        if let previousBerg = topmostOfLeft {
                            let previousBergPositionInScene = self.convertPoint(previousBerg.position, fromNode: stage!)
                            
                            var randomX: CGFloat
                            repeat {
                                randomX = CGFloat(random()) % (view!.frame.width * 0.8) + (view!.frame.width * 0.1)
                            } while (previousBergPositionInScene.x - randomX > view!.frame.width * 0.4)
                            
                            let bergPositionInSceneY = previousBergPositionInScene.y + 350 // + randomY
                            berg.position = self.convertPoint(CGPoint(x: randomX, y: bergPositionInSceneY), toNode: stage!)
                            
                            topmostBergY = berg.position.y
                        }
                        
                        stage!.insertChild(berg, atIndex: 0)
                        
                        topmostOfLeft = berg
                            
                        forking = false
                        pathing = ""
                    
                    case "right":
                        let berg = Iceberg(size: CGSize(width: 150, height: 150))
                        
                        if let previousBerg = topmostOfRight {
                            let previousBergPositionInScene = self.convertPoint(previousBerg.position, fromNode: stage!)
                            
                            var randomX: CGFloat
                            repeat {
                                randomX = CGFloat(random()) % (view!.frame.width * 0.8) + (view!.frame.width * 0.1)
                            } while (previousBergPositionInScene.x - randomX > view!.frame.width * 0.4)
                            
                            let bergPositionInSceneY = previousBergPositionInScene.y + 350 // + randomY
                            berg.position = self.convertPoint(CGPoint(x: randomX, y: bergPositionInSceneY), toNode: stage!)
                            
                            topmostBergY = berg.position.y
                            
                        }
                        
                        stage!.insertChild(berg, atIndex: 0)
                        
                        topmostOfRight = berg
                        
                        forking = false
                        pathing = ""
                    
                default:
                    forking = false
                    pathing = ""
                }
                
                
                
            } else {
                topmostOfLeft = nil
                topmostOfRight = nil
                
                let berg = Iceberg(size: CGSize(width: 150, height: 150))
                
                if let previousBerg = stage?.children.first {
                    let previousBergPositionInScene = self.convertPoint(previousBerg.position, fromNode: stage!)

                    let randomX = CGFloat(random()) % (view!.frame.width * 0.4) - (view!.frame.width * 0.2)
                    
                    let bergPositionInSceneY = previousBergPositionInScene.y + 350 // + randomY
                    
                    berg.position = self.convertPoint(CGPoint(x: previousBergPositionInScene.x + randomX, y: bergPositionInSceneY), toNode: stage!)
                    
                    topmostBergY = bergPositionInSceneY
                    
                } else {
                    // If there are no previous icebergs, generate the initial iceberg under the penguin.
                    berg.position = CGPoint(x: 0, y: 0 - view!.frame.height * 0.4)
                }
                berg.bob()
                stage!.insertChild(berg, atIndex: 0)
            }
            
            
            
        }

    }
}
