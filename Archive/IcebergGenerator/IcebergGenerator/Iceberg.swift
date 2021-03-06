//
//  Iceberg.swift
//  IcebergGenerator
//
//  Created by Matthew Tso on 5/23/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit

class Iceberg: SKSpriteNode {
    
    var stormMode = false
    
    let shadowColor = SKColor(red: 0.88, green: 0.93, blue: 0.96, alpha: 1.0)
    var underwaterColor = SKColor(red: 0.5, green: 0.8, blue: 0.89, alpha: 0.5)
//    var underwaterColor = SKColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)

    let debug = false
    
    var shadowHeight:CGFloat = 20.0
    var underwaterHeight:CGFloat = 20.0
    
    var bergVertices:[CGPoint]?
    
    var berg:SKShapeNode?
    var shadow:SKShapeNode?
    var underwater:SKShapeNode?
    var shadowMask:SKShapeNode?
        
    init(size: CGSize) {
        super.init(texture: nil, color: UIColor.clearColor(), size: size)
        name = "iceberg"
        
        if stormMode {
            underwaterColor = SKColor(red: 0.25, green: 0.4, blue: 0.5, alpha: 1)
        }
        
        bergVertices = generateRandomPoints(aroundPoint: CGPointZero)
        
        createBergShapes()
        bob()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createBergShapes() {
        if let vertices = bergVertices {
        
            // Create path of iceberg
            let bergPath = CGPathCreateMutable()
            CGPathMoveToPoint(bergPath, nil, vertices[0].x, vertices[0].y)
            for point in 1..<vertices.count {
                CGPathAddLineToPoint(bergPath, nil, vertices[point].x, vertices[point].y)
            }
            CGPathCloseSubpath(bergPath)
            
            // Create berg shape node
            berg = SKShapeNode(path: bergPath)
            if let berg = berg {
                berg.path = bergPath
                berg.position = CGPointZero
                berg.fillColor = SKColor.whiteColor()
                //        berg!.strokeColor = SKColor.redColor()
                berg.strokeColor = SKColor.whiteColor()
                berg.lineWidth = 1
                berg.zPosition = 100
                addChild(berg)
            }
            
            // Set startPoint and endPoint of shadows based on which point is further out
            let startPoint = vertices[1].x > vertices[2].x ? 1 : 2
            let endPoint = vertices[6].x < vertices[5].x ? 6 : 5
            
            
            
            // Create underwater shape
            underwater = SKShapeNode()
            
            let underwaterPath = CGPathCreateMutable()
            CGPathMoveToPoint(underwaterPath, nil, vertices[startPoint].x, vertices[startPoint].y)
            CGPathAddLineToPoint(underwaterPath, nil, vertices[startPoint].x, vertices[startPoint].y - shadowHeight - underwaterHeight)
            for point in startPoint + 1 ..< endPoint {
                CGPathAddLineToPoint(underwaterPath, nil, vertices[point].x, vertices[point].y - shadowHeight - underwaterHeight)
            }
            CGPathAddLineToPoint(underwaterPath, nil, vertices[endPoint].x, vertices[endPoint].y - shadowHeight - underwaterHeight)
            CGPathAddLineToPoint(underwaterPath, nil, vertices[endPoint].x, vertices[endPoint].y)
            CGPathCloseSubpath(underwaterPath)
            
            if let underwater = underwater {
                underwater.path = underwaterPath
                underwater.position = CGPointZero
                underwater.fillColor = underwaterColor
                underwater.strokeColor = underwaterColor
                underwater.lineWidth = 1
                underwater.zPosition = -100
                
                addChild(underwater)
            }
            
            
            
            // Create shadow shape cropped to underwater path
            let croppedShadow = SKCropNode()
            shadowMask = SKShapeNode(path: underwaterPath)
            shadow = SKShapeNode()
            
            if let shadowMask = shadowMask {
                shadowMask.fillColor = SKColor.blackColor()
                shadowMask.position = CGPointZero
                shadowMask.name = "shadowMask"
            }
            
            croppedShadow.maskNode = shadowMask
            croppedShadow.position = CGPointZero
            croppedShadow.zPosition = 50
            addChild(croppedShadow)

            let shadowPath = CGPathCreateMutable()
            CGPathMoveToPoint(shadowPath, nil, vertices[startPoint].x, vertices[startPoint].y)
            CGPathAddLineToPoint(shadowPath, nil, vertices[startPoint].x, vertices[startPoint].y - shadowHeight)
            for point in startPoint + 1 ..< endPoint {
                CGPathAddLineToPoint(shadowPath, nil, vertices[point].x, vertices[point].y - shadowHeight)
            }
            CGPathAddLineToPoint(shadowPath, nil, vertices[endPoint].x, vertices[endPoint].y - shadowHeight)
            CGPathAddLineToPoint(shadowPath, nil, vertices[endPoint].x, vertices[endPoint].y)
            CGPathCloseSubpath(shadowPath)
            
            if let shadow = shadow{
                shadow.path = shadowPath
                shadow.position = CGPointZero //(x: view.center.x, y: view.center.y)// - shadowHeight)
                //                let shadowColor = SKColor(red: 0.88, green: 0.93, blue: 0.96, alpha: 1.0)
                shadow.fillColor = shadowColor
                shadow.strokeColor = shadowColor
                shadow.lineWidth = 1
                shadow.zPosition = 50
                
                croppedShadow.addChild(shadow)
            }
            
        }
    }
    
    func beginMovingBerg() {
        let forth = SKAction.moveBy(CGVector(dx: 50, dy: 0), duration: 2.0)
        let back = SKAction.moveBy(CGVector(dx: -50, dy: 0), duration: 2.0)
        let backAndForth = SKAction.repeatActionForever(SKAction.sequence([forth, back]))
        
        position.x -= 25
        runAction(backAndForth)
    }
    
    func testSink() {
        let sinkDepth = shadowHeight
        let sinkDuration = 1.0
        
        let sink = SKAction.moveBy(CGVector(dx: 0.0, dy: -sinkDepth), duration: sinkDuration)
        let wait = SKAction.waitForDuration(sinkDuration * 2)
        let rise = SKAction.moveBy(CGVector(dx: 0.0, dy: sinkDepth), duration: sinkDuration)
        
        let sinkSequence = SKAction.sequence([sink, wait, rise])
        
        underwater!.runAction(sinkSequence)
        shadowMask!.runAction(sinkSequence)
        
        berg!.runAction(sink, completion: {
            let underwaterColor = SKColor(red: 0.83, green: 0.94, blue: 0.97, alpha: 1) //SKColor(red: 0.8, green: 0.95, blue: 1, alpha: 1)
            self.berg!.fillColor = underwaterColor
            self.berg!.strokeColor = underwaterColor
            
            self.berg!.runAction(wait, completion: {
                self.berg!.fillColor = SKColor.whiteColor()
                self.berg!.strokeColor = SKColor.whiteColor()
                
                self.berg!.runAction(rise)
            })
        })
    }
    
    func sink() {
        sink(7.0, completion: {})
    }
    
    func sink(duration: Double, completion block: () -> Void) {
        let sinkDepth = shadowHeight
        
        let sink = SKAction.moveBy(CGVector(dx: 0.0, dy: -sinkDepth), duration: duration)
        
        underwater!.runAction(sink)
        shadowMask!.runAction(sink)
        
        berg!.runAction(sink, completion: {
            let underwaterColor = SKColor(red: 0.83, green: 0.94, blue: 0.97, alpha: 1)
            self.berg!.fillColor = underwaterColor
            self.berg!.strokeColor = underwaterColor
            
            let flattenedTexture = self.scene?.view?.textureFromNode(self)
            
            self.removeAllChildren()
            
            self.texture = flattenedTexture
            self.size = flattenedTexture!.size()
            self.position.y -= self.shadowHeight * 1.5
            
            let fade = SKAction.fadeOutWithDuration(0.5)
            fade.timingMode = .EaseIn
            self.runAction(fade, completion: {
                block()
            })
        })
        
    }
    
    func bump() {
        let enlarge = SKAction.scaleTo(1.1, duration: 0.1)
        let reduce = SKAction.scaleTo(1.0, duration: 0.1)
        
        enlarge.timingMode = .EaseOut
        reduce.timingMode = .EaseIn
        
        let bumpSequence = SKAction.sequence([enlarge, reduce])
        
        runAction(bumpSequence)
    }
    
    func generateRandomPoints(aroundPoint center: CGPoint) -> [CGPoint] {
        let radius = Double(size.width / 2)
        
        var randomPoints = [CGPoint]()
        for count in 0...7 {
            let section = M_PI / 4 * Double(count)
            let randomAngleInSection = section + Double(arc4random_uniform(628)) / 100 / 8
            
            let xFromCenter = sin(randomAngleInSection) * radius
            let yFromCenter = cos(randomAngleInSection) * radius
            
            let pointX = center.x + CGFloat(xFromCenter)
            let pointY = center.y + CGFloat(yFromCenter)
            
            let point = CGPoint(x: pointX, y: pointY)
            randomPoints.append(point)
        }
        return randomPoints
    }
    
    func bob() {
        // Need to implement berg position reset with each new bob call.
        
        let bobDepth = stormMode ? 5.0 : 2.0
        let bobDuration = stormMode ? 0.8 : 2.0
        
        let down = SKAction.moveBy(CGVector(dx: 0.0, dy: bobDepth), duration: bobDuration)
        let wait = SKAction.waitForDuration(bobDuration / 4)
        let up = SKAction.moveBy(CGVector(dx: 0.0, dy: -bobDepth), duration: bobDuration)
        
        down.timingMode = .EaseInEaseOut
        up.timingMode = .EaseInEaseOut
        
        let bobSequence = SKAction.sequence([down, wait, up, wait])
        let bob = SKAction.repeatActionForever(bobSequence)
        
        shadow!.removeAllActions()
        shadow!.runAction(bob)
    }

}
