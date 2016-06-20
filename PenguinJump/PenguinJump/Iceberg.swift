//
//  Iceberg.swift: A single iceberg object that is instantiated by the IcebergGenerator to form the platforms of the game.
//
//  Created by Matthew Tso on 5/23/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit

/**
    Iceberg object class.
    Creates a node with children sprite nodes that represent the iceberg's layers: iceberg surface, shadow, and underwater reflection.

    - Parameter stormMode: Boolean that determines bobbing action values
    - Parameter landed: Boolean that determines if the penguin has landed on the berg before or not.

    - shadowMask: Shadow masking sprite node.
    - waves: Sprite node that uses the same texture as the berg sprite node. The y position is shifted down to sea level (the bottom of the shadow sprite node).
*/
class Iceberg: SKSpriteNode {
    
    // Sprite objects.
    /// Surface sprite node.
    var berg:SKSpriteNode!
    /// Shadow sprite node.
    var shadow:SKSpriteNode!
    /// Underwater sprite node.
    var underwater:SKSpriteNode!
    /// Sprite node used by the `croppedShadow` `SKCropNode` to mask the top edge of shadow sprite node.
    var shadowMask:SKSpriteNode!
    /// Sprite node that uses the same texture as the berg sprite node. The y position is shifted down to sea level (the bottom of the shadow sprite node).
    var wave:SKSpriteNode!
    
    // Attributes
    let bergColor = SKColor.whiteColor()
    let shadowColor = SKColor(red: 0.88, green: 0.93, blue: 0.96, alpha: 1.0)
    let underwaterColor = SKColor(red: 0.25, green: 0.55, blue: 0.8, alpha: 1.0)
    let shadowHeight:CGFloat = 20.0
    let underwaterHeight:CGFloat = 20.0
    
    // Settings
    var stormMode: Bool!
    let debug = false
    var landed = false
    
    // Functions
    init(size: CGSize, stormMode: Bool) {
        super.init(texture: nil, color: UIColor.clearColor(), size: size)
        
        createBergNodes()
        
        self.stormMode = stormMode
        bob()
    }
    
    /**
        Creates the SKSpriteNode objects using textures generated from UIImages created in a CoreGraphics Bitmap Context.
    */
    func createBergNodes() {
        // ***** Create images *****
        /// Set rendering layer rectangle.
        let renderingRect = CGRect(x: 0, y: 0, width: size.width, height: size.width)
        let renderingRectCenter = CGPoint(x: CGRectGetMidX(renderingRect), y: CGRectGetMidY(renderingRect))
        
        /// The points used to draw the Iceberg in the CGContext coordinate.
        let vertices = generateRandomPoints(aroundPoint: renderingRectCenter, radius: Double(size.width) / 2)
        
        /// The calculated start point of the shadow shape based on which point is further out.
        let startPoint = vertices[1].x > vertices[2].x ? 1 : 2
        /// The calculated end point of the shadow shape based on which point is further out.
        let endPoint = vertices[6].x < vertices[5].x ? 6 : 5
        
        /// The CGPoints of the extruded shadow shape.
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
        
        // ***** Generate images *****
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
        
        //  ***** Create the physics body based off of the berg's vertices. *****
        
        /// A new set of `CGPoint`s in the reverse order of the generated vertices because bodyWithPolygonFromPath winds counter-clockwise.
        let physicsPoints:[CGPoint] = shiftPointsFromRenderingRect(vertices.reverse())
        
        /// The CGPath used for the berg's physics body shape.
        let bergPhysicsPath = CGPathCreateMutable()
        CGPathMoveToPoint(bergPhysicsPath, nil, physicsPoints[0].x, physicsPoints[0].y)
        for point in 1..<physicsPoints.count {
            CGPathAddLineToPoint(bergPhysicsPath, nil, physicsPoints[point].x, physicsPoints[point].y)
        }
        CGPathCloseSubpath(bergPhysicsPath)
        
        let bergBody = SKPhysicsBody(polygonFromPath: bergPhysicsPath)
        bergBody.allowsRotation = false
        bergBody.friction = 0
        bergBody.affectedByGravity = false
        bergBody.dynamic = false
        bergBody.categoryBitMask = IcebergCategory
        
        berg.physicsBody = bergBody
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
        Generates 8 random CGPoints around a center point.
        - parameter center: CGPoint of center point.
        - parameter radius: Distance between points and center.
        - returns: An array of CGPoints.
     */
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
    
    /**
        Shifts a set of points generated around the ImageContext center point back to the node's center at CGPointZero.
        - parameter points: The set of CGPoints to shift.
        - returns: The new set of shifted CGPoints.
     */
    func shiftPointsFromRenderingRect(points: [CGPoint]) -> [CGPoint] {
        let renderingRect = CGRect(x: 0, y: 0, width: size.width, height: size.width)
        let renderingRectCenter = CGPoint(x: CGRectGetMidX(renderingRect), y: CGRectGetMidY(renderingRect))
        
        var newPoints = [CGPoint]()
        for point in points {
            let newPointX = point.x - renderingRectCenter.x
            let newPointY = point.y - renderingRectCenter.y
            
            newPoints.append(CGPoint(x: newPointX, y: newPointY))
        }
        return newPoints
    }
    
    /// Runs a set of back and forth move actions on the Iceberg forever.
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
    
    /// Wave ripple effect on Iceberg landing.
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
    
    /// Begins the sinking and subsequent removal of the Iceberg.
    func sink(duration: Double, completion block: (() -> Void)?) {
        
        let sink = SKAction.moveBy(CGVector(dx: 0.0, dy: -shadowHeight), duration: duration)
        let fade = SKAction.fadeOutWithDuration(0.5)
        let pullOut = SKAction.moveBy(CGVector(dx: 0, dy: -self.berg.size.height * 2), duration: 0.5)
        let bergDelay = SKAction.waitForDuration(0.2)
        
        underwater!.runAction(sink)
        shadowMask!.runAction(sink)
        
        berg!.runAction(sink, completion: {
            self.berg.alpha = 0
            self.zPosition = -500
            self.alpha = 0.5
            
            self.berg.runAction(SKAction.sequence([bergDelay, pullOut]))
            self.runAction(fade, completion: {
                self.removeFromParent()
                
                block?()
            })
        })
        
    }
    
    /// Removes previous bob actions and then adds new bob actions. Needs to be called at the beginning and the end of storm mode to update the intensity of the bob.
    func bob() {
        if !landed {
            let bobActionKey = "bob_action"
            
            berg.removeActionForKey(bobActionKey)
            underwater.removeActionForKey(bobActionKey)
            shadowMask.removeActionForKey(bobActionKey)
            
            let bobDepth = (stormMode == true) ? 5.0 : 2.0
            let bobDuration = (stormMode == true) ? 0.8 : 2.0
            
            let down = SKAction.moveBy(CGVector(dx: 0.0, dy: -bobDepth), duration: bobDuration)
            let up = SKAction.moveBy(CGVector(dx: 0.0, dy: bobDepth), duration: bobDuration)
            down.timingMode = .EaseInEaseOut
            up.timingMode = .EaseInEaseOut
            let bobSequence = SKAction.sequence([down, up])
            let bob = SKAction.repeatActionForever(bobSequence)
            
            // Actions for resetting the position before running the new bobbing actions for a smooth transition.
            let bergReset = SKAction.moveTo(CGPointZero, duration: 2.0)
            let underwaterReset = SKAction.moveTo(CGPoint(x: CGPointZero.x, y: CGPointZero.y - shadowHeight), duration: 2.0)
            let shadowMaskReset = SKAction.moveTo(CGPoint(x: CGPointZero.x, y: CGPointZero.y - shadowHeight), duration: 2.0)
            bergReset.timingMode = .EaseInEaseOut
            underwaterReset.timingMode = .EaseInEaseOut
            shadowMaskReset.timingMode = .EaseInEaseOut
            
            berg.runAction(bergReset, completion: {
                self.berg.runAction(bob, withKey: bobActionKey)
            })
            underwater.runAction(underwaterReset, completion: {
                self.underwater.runAction(bob, withKey: bobActionKey)
            })
            shadowMask.runAction(shadowMaskReset, completion: {
                self.shadowMask.runAction(bob, withKey: bobActionKey)
            })
        }
    }
    
    func land() {
        
        if !landed {
            landed = true
            
            removeAllActions()
            berg.removeAllActions()
            underwater.removeAllActions()
            shadowMask.removeAllActions()
            
            let enlarge = SKAction.scaleTo(1.06, duration: 0.06)
            let reduce = SKAction.scaleTo(1.0, duration: 0.06)
            enlarge.timingMode = .EaseOut
            reduce.timingMode = .EaseIn
            
            let bumpSequence = SKAction.sequence([enlarge, reduce])
            runAction(bumpSequence)
            ripple()
        }
    }
    
    func bump() {
        
        let enlarge = SKAction.scaleTo(1.06, duration: 0.06)
        let reduce = SKAction.scaleTo(1.0, duration: 0.06)
        enlarge.timingMode = .EaseOut
        reduce.timingMode = .EaseIn
        
        let bumpSequence = SKAction.sequence([enlarge, reduce])
        runAction(bumpSequence)
        ripple()
    }
}