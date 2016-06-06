//
//  Iceberg.swift
//  IcebergGenerator
//
//  Created by Matthew Tso on 5/23/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit

class Iceberg: SKSpriteNode {
    
    // Main Objects
    var berg:SKSpriteNode!
    var shadow:SKSpriteNode!
    var underwater:SKSpriteNode!
    var shadowMask:SKSpriteNode!
    var wave:SKSpriteNode!
    
    // Attributes
    let bergColor = SKColor.whiteColor()
    let shadowColor = SKColor(red: 0.88, green: 0.93, blue: 0.96, alpha: 1.0)
    let underwaterColor = SKColor(red: 0.25, green: 0.55, blue: 0.8, alpha: 1.0)
    let shadowHeight:CGFloat = 20.0
    let underwaterHeight:CGFloat = 20.0
    
    // Settings
    var stormMode: Bool!// = false
    let debug = false
    var landed = false
    
    // Functions
    init(size: CGSize, stormMode: Bool) {
        super.init(texture: nil, color: UIColor.clearColor(), size: size)
        
        createBergNodes()
        
        self.stormMode = stormMode
        bob()
    }
    
    
    func createBergNodes() {
        // ***** Create images *****
        // Set rendering layer rectangle.
        let renderingRect = CGRect(x: 0, y: 0, width: size.width, height: size.width)
        let renderingRectCenter = CGPoint(x: CGRectGetMidX(renderingRect), y: CGRectGetMidY(renderingRect))
        
        // Generate points of iceberg
        let vertices = generateRandomPoints(aroundPoint: renderingRectCenter, radius: Double(size.width) / 2)
        
        // Calculate startPoint and endPoint of shadows based on which point is further out
        let startPoint = vertices[1].x > vertices[2].x ? 1 : 2
        let endPoint = vertices[6].x < vertices[5].x ? 6 : 5
        
        // Generate points of extruded shape
        var underwaterVertices = [CGPoint]()
        for point in 0...startPoint {
            underwaterVertices.append(vertices[point])
        }
        underwaterVertices.append(CGPoint(
            x: vertices[startPoint].x,
            y: vertices[startPoint].y - shadowHeight * 2))
        for point in startPoint + 1 ..< endPoint {
            underwaterVertices.append(CGPoint(x: vertices[point].x, y: vertices[point].y - shadowHeight * 2))
        }
        underwaterVertices.append(CGPoint(
            x: vertices[endPoint].x,
            y: vertices[endPoint].y - shadowHeight * 2))
        for point in endPoint...vertices.count - 1 {
            underwaterVertices.append(vertices[point])
        }
        
        // Generate images
        // Iceberg Image
        UIGraphicsBeginImageContextWithOptions(renderingRect.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        
        CGContextTranslateCTM(context, 0, renderingRect.height)
        CGContextScaleCTM(context, 1, -1)
        CGContextSetRGBFillColor(context, 1, 1, 1, 1)
        CGContextAddLines(context, vertices, vertices.count)
        CGContextFillPath(context)
        let bergImage = UIGraphicsGetImageFromCurrentImageContext()
        
        CGContextRestoreGState(context)
        UIGraphicsEndImageContext()
        
        // Underwater Shape Image
        UIGraphicsBeginImageContextWithOptions(CGSize(width: renderingRect.width, height: renderingRect.height + shadowHeight + underwaterHeight), false, 0.0)
        let contextExtruded = UIGraphicsGetCurrentContext()
        
        CGContextSaveGState(contextExtruded)
        CGContextTranslateCTM(contextExtruded, 0, renderingRect.height)//+ shadowHeight + underwaterHeight)
        CGContextScaleCTM(contextExtruded, 1, -1)
        CGContextAddLines(contextExtruded, underwaterVertices, underwaterVertices.count)
        
        CGContextSetRGBFillColor(contextExtruded, 0.88, 0.93, 0.96, 1)
        CGContextFillPath(contextExtruded)
        let shadowImage = UIGraphicsGetImageFromCurrentImageContext()
        let shadowMaskImage = UIGraphicsGetImageFromCurrentImageContext()
        CGContextRestoreGState(contextExtruded)
        
        CGContextSaveGState(contextExtruded)
        CGContextTranslateCTM(contextExtruded, 0, renderingRect.height)
        CGContextScaleCTM(contextExtruded, 1, -1)
        CGContextAddLines(contextExtruded, underwaterVertices, underwaterVertices.count)
        
        CGContextSetRGBFillColor(contextExtruded, 0.25, 0.55, 0.8, 1)
        CGContextFillPath(contextExtruded)
        let underwaterImage = UIGraphicsGetImageFromCurrentImageContext()
        CGContextRestoreGState(contextExtruded)
        UIGraphicsEndImageContext()
        
        // ***** Create Sprite Nodes *****
        // Create the textures
        let bergTexture = SKTexture(image: bergImage)
        let underwaterTexture = SKTexture(image: underwaterImage)
        let shadowMaskTexture = SKTexture(image: shadowMaskImage)
        let shadowTexture = SKTexture(image: shadowImage)
        
        // Instantiate nodes
        berg = SKSpriteNode(texture: bergTexture)
        underwater = SKSpriteNode(texture: underwaterTexture)
        shadowMask = SKSpriteNode(texture: shadowMaskTexture)
        shadow = SKSpriteNode(texture: shadowTexture)
        wave = SKSpriteNode(texture: bergTexture)
        let croppedShadow = SKCropNode()
        croppedShadow.maskNode = shadowMask
        croppedShadow.addChild(shadow)
        
        // Set y offsets
        underwater.position.y -= shadowHeight
        shadowMask.position.y -= shadowHeight
        wave.position.y -= shadowHeight
        
        // Set zPositions
        berg.zPosition = 100
        underwater.zPosition = -300
        croppedShadow.zPosition = 50
        wave.zPosition = 20
        
        // Add nodes
        addChild(berg)
        addChild(underwater)
        addChild(croppedShadow)
        addChild(wave)
        wave.alpha = 0.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Generate 8 points around a circle
    func generateRandomPoints(aroundPoint center: CGPoint, radius: Double) -> [CGPoint] {
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
    
    func beginMoving() {
        let maxDuration = 12.0
        let minDuration = 3.0
        let moveDuration = maxDuration - ((maxDuration - minDuration) * (scene as! GameScene).difficulty)
        let moveDistance = 100
        
        let forthFirst = SKAction.moveBy(CGVector(dx: moveDistance / 2, dy: 0), duration: moveDuration / 2)
        let forthSecond = SKAction.moveBy(CGVector(dx: moveDistance / 2, dy: 0), duration: moveDuration / 2)
        let back = SKAction.moveBy(CGVector(dx: -moveDistance, dy: 0), duration: moveDuration)
        forthFirst.timingMode = .EaseOut
        back.timingMode = .EaseInEaseOut
        forthSecond.timingMode = .EaseIn
        
        let backAndForth = SKAction.repeatActionForever(SKAction.sequence([forthFirst, back, forthSecond]))
        
        runAction(backAndForth)
    }
    
    func ripple() {
        wave.xScale = 1.0
        wave.yScale = 1.0
        wave.alpha = 1.0
        
        let pulse = SKAction.scaleTo(1.1, duration: 1)
        let fade = SKAction.fadeAlphaTo(0.0, duration: 1)
        pulse.timingMode = .EaseOut
        fade.timingMode = .EaseIn
        
        wave.runAction(pulse)
        wave.runAction(fade)
    }
    
    func sink(duration: Double, completion block: (() -> Void)?) {
        let sinkDepth = shadowHeight
        
        let sink = SKAction.moveBy(CGVector(dx: 0.0, dy: -sinkDepth), duration: duration)
        
        underwater!.runAction(sink)
        shadowMask!.runAction(sink)
        
        berg!.runAction(sink, completion: {
            self.berg.removeFromParent()
            self.zPosition = -500
            self.alpha = 0.5
            
            let fade = SKAction.fadeOutWithDuration(0.5)
            self.runAction(fade, completion: {
                self.removeFromParent()
                
                block?()
            })
        })
        
    }
    
    func fade() {
        let flattenedTexture = self.scene?.view?.textureFromNode(self)
        
        self.removeAllChildren()
        
        texture = flattenedTexture
        size = flattenedTexture!.size()
        position.y -= shadowHeight * 1.5
        
        let fade = SKAction.fadeOutWithDuration(0.5)
        self.runAction(fade)
    }
    
    func bob() {
        // If there is a storm mode, need to implement berg position reset with each new bob call.
        let bobActionKey = "bob_action"
        
        berg.removeActionForKey(bobActionKey)
        underwater.removeActionForKey(bobActionKey)
        shadowMask.removeActionForKey(bobActionKey)
        
        let bobDepth = (stormMode == true) ? 5.0 : 2.0
        let bobDuration = (stormMode == true) ? 0.8 : 2.0
        
//        let bobDepth = 2.0 + 3.0 * (scene as! GameScene).stormIntensity
        
        let down = SKAction.moveBy(CGVector(dx: 0.0, dy: -bobDepth), duration: bobDuration)
        let up = SKAction.moveBy(CGVector(dx: 0.0, dy: bobDepth), duration: bobDuration)
        down.timingMode = .EaseInEaseOut
        up.timingMode = .EaseInEaseOut
        
        let bobSequence = SKAction.sequence([down, up])
        let bob = SKAction.repeatActionForever(bobSequence)
        
        // Reset position and then run action
        let bergReset = SKAction.moveTo(CGPointZero, duration: 2.0)
        let underwaterReset = SKAction.moveTo(CGPoint(x: CGPointZero.x, y: CGPointZero.y - shadowHeight), duration: 2.0)
        let shadowMaskReset = SKAction.moveTo(CGPoint(x: CGPointZero.x, y: CGPointZero.y - shadowHeight), duration: 2.0)
        bergReset.timingMode = .EaseInEaseOut
        underwaterReset.timingMode = .EaseInEaseOut
        shadowMaskReset.timingMode = .EaseInEaseOut
        
        berg.runAction(bergReset, completion: {
            print("berg reset, now start bobbing")
            print(self.stormMode)
            print(bobDepth)
            self.berg!.runAction(bob, withKey: bobActionKey)
        })
        underwater.runAction(underwaterReset, completion: {
            self.underwater!.runAction(bob, withKey: bobActionKey)
        })
        shadowMask.runAction(shadowMaskReset, completion: {
            self.shadowMask!.runAction(bob, withKey: bobActionKey)
        })
    }
    
    func land() {
        if !landed {
            landed = true
            self.removeAllActions()
            
            let enlarge = SKAction.scaleTo(1.06, duration: 0.06)
            let reduce = SKAction.scaleTo(1.0, duration: 0.06)
            
            enlarge.timingMode = .EaseOut
            reduce.timingMode = .EaseIn
            
            let bumpSequence = SKAction.sequence([enlarge, reduce])
            
            runAction(bumpSequence)
            self.ripple()
        }
    }
}