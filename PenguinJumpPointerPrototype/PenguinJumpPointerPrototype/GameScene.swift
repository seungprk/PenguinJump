//
//  GameScene.swift
//  PenguinJumpPointerPrototype
//
//  Created by Matthew Tso on 5/13/16.
//  Copyright (c) 2016 De Anza. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    let penguin = SKSpriteNode(imageNamed: "player")
    let pointer = SKSpriteNode(imageNamed: "arrow")
    let pointerChargeSpeed = 1.0
    let maxJumpDistance: CGFloat = 500.0
    
    var stage: SKSpriteNode?
    var penguinShadow: SKShapeNode?
    var pointerBar: SKShapeNode?
    var pointerCharge = 0
    var chargeDistance: CGFloat?
    var pointerRotation:CGFloat = 0.0
        
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        buildScene()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let xFromPenguin = location.x - penguin.position.x
            let yFromPenguin = location.y - penguin.position.y

            let angleInRadians = -atan(xFromPenguin / yFromPenguin )
            
            pointer.zRotation = angleInRadians
            
            pointer.hidden = false
            let increaseCharge = SKAction.moveBy(CGVector(dx: 0, dy: chargeDistance! / 100), duration: pointerChargeSpeed / 100)
            let chargeAction = SKAction.repeatAction(increaseCharge, count: 99)
            pointerBar!.runAction(chargeAction, withKey: "chargeAction")
        }

    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let xFromPenguin = location.x - penguin.position.x
            let yFromPenguin = location.y - penguin.position.y
            
            let angleInRadians = -atan(xFromPenguin / yFromPenguin )
            
            pointer.zRotation = angleInRadians
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        pointerBar!.removeActionForKey("chargeAction")
        
        let chargeAmount = pointerBar!.position.y + chargeDistance! / 2
        let chargePercentage = chargeAmount / chargeDistance!
        
        let jumpDistance = chargePercentage * maxJumpDistance
        let jumpDirection = -pointer.zRotation * 180 / CGFloat( M_PI )
        
        // Reset pointer
        pointer.hidden = true
        
        // Return pointerBar to 0
        pointerBar!.position.y = -chargeDistance! / 2
        
        jump(distance: jumpDistance, direction: jumpDirection)

    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        generateBergs()
    }
    
    func buildScene() {
        backgroundColor = SKColor.whiteColor()
        
        // Place penguin
        penguin.position = CGPoint(x: size.width * 0.5, y: size.height * 0.1)
        addChild(penguin)
        
        // Create penguin's shadow
        penguinShadow = SKShapeNode(rectOfSize: CGSize(width: penguin.frame.width, height: penguin.frame.width), cornerRadius: penguin.frame.width / 2)
        penguinShadow!.fillColor = SKColor.blackColor()
        penguinShadow!.alpha = 0.2
        penguinShadow!.position = CGPoint(x: 0, y: -penguinShadow!.frame.height/4)
        penguin.addChild(penguinShadow!)
        
        // Place pointer
        pointer.position = CGPoint(x: 0, y: -penguinShadow!.frame.height/4) // Same as shadow
        chargeDistance = pointer.frame.height
        pointer.zPosition = -1.0
        pointer.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        penguin.addChild(pointer)
        
        // Create pointer bar
        pointerBar = SKShapeNode(rectOfSize: pointer.frame.size)
        pointerBar!.fillColor = SKColor.redColor()
        pointerBar!.position = CGPoint(x: 0, y: -pointer.frame.height / 2)
        
        // Add pointer charge bar
        let barCrop = SKCropNode()
        let pointerCrop = SKSpriteNode(imageNamed: "arrow")
        pointerCrop.anchorPoint = pointer.anchorPoint
        barCrop.maskNode = pointerCrop //
        barCrop.zPosition = 1.0
        barCrop.addChild(pointerBar!)
        pointer.addChild(barCrop)
        
//        pointer.zRotation = 0.5
        
        pointer.hidden = true
        
        // Make stage
        stage = SKSpriteNode(color: UIColor.clearColor(), size: CGSize(width: size.width, height: size.height))
        stage!.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        addChild(stage!)
        
        generateBergs()
    }
    
//    func generateBergs() {
//        let berg = SKShapeNode(rectOfSize: CGSize(width: penguin.frame.height * 3, height: penguin.frame.height * 3))
//        berg.fillColor = SKColor(red: 0, green: 0, blue: 0, alpha: 0.1)
//        berg.position = self.convertPoint(CGPoint(x: penguin.position.x, y: penguin.position.y), toNode: stage!)
//        
//        stage!.addChild(berg)
//    }
    
    func generateBergs() {
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
            let berg = SKShapeNode(rectOfSize: CGSize(width: penguin.frame.height * 3, height: penguin.frame.height * 3))
            berg.fillColor = SKColor(red: 0, green: 0, blue: 0, alpha: 0.1)
            
            let randomY = CGFloat(random()) % 120 + 110
            let randomX = CGFloat(random()) % view!.frame.width / 2 + view!.frame.width / 4
            
            let previousBerg = stage!.children.last
            if previousBerg != nil {
                let previousBergPositionInScene = self.convertPoint(previousBerg!.position, fromNode: stage!)
                let bergPositionInSceneY = previousBergPositionInScene.y + randomY
                berg.position = self.convertPoint(CGPoint(x: randomX, y: bergPositionInSceneY), toNode: stage!)
                
                topmostBerg = bergPositionInSceneY
            } else {
                // If there are no previous icebergs, generate the initial iceberg under the penguin.
                berg.position = self.convertPoint(CGPoint(x: penguin.position.x, y: penguin.position.y), toNode: stage!)
            }
            
            stage?.addChild(berg)
        }
    }

    
    func jump(distance distance: CGFloat, direction: CGFloat) {
        let directionInRad = direction / 180 * CGFloat(M_PI)
        
        let xDistance = distance * sin(directionInRad)
        let yDistance = distance * cos(directionInRad)
        
        for berg in stage!.children {
            let moveAction = SKAction.moveBy(CGVector(dx: -xDistance, dy: -yDistance), duration: 1)
            moveAction.timingMode = .EaseInEaseOut
            berg.runAction(moveAction)
        }
    }
}
