/*

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
    let underwaterColor = SKColor(red: 0.25, green: 0.55, blue: 0.8, alpha: 1.0) // SKColor(red: 0.5, green: 0.8, blue: 0.89, alpha: 0.5)
    let shadowHeight:CGFloat = 20.0
    let underwaterHeight:CGFloat = 20.0
    
    // Settings
    var stormMode = false
    let debug = false
    var landed = false
    
    // Functions
    init(size: CGSize) {
        super.init(texture: nil, color: UIColor.clearColor(), size: size)
        
        createBergNodes()
        bob()
        beginMoving()
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
        CGContextTranslateCTM(contextExtruded, 0, renderingRect.height)// size.height / 2 + underwaterHeight + shadowHeight)
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
        let moveDuration = maxDuration //- ((maxDuration - minDuration) * (scene as! GameScene).difficulty)
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
        
        let bobDepth = stormMode ? 5.0 : 2.0
        let bobDuration = stormMode ? 0.8 : 2.0
        
        let down = SKAction.moveBy(CGVector(dx: 0.0, dy: -bobDepth), duration: bobDuration)
        let up = SKAction.moveBy(CGVector(dx: 0.0, dy: bobDepth), duration: bobDuration)
        down.timingMode = .EaseInEaseOut
        up.timingMode = .EaseInEaseOut
        
        let bobSequence = SKAction.sequence([down, up])
        let bob = SKAction.repeatActionForever(bobSequence)
        
        berg!.removeAllActions()
        berg!.runAction(bob)
        underwater!.removeAllActions()
        underwater!.runAction(bob)
        shadowMask!.removeAllActions()
        shadowMask!.runAction(bob)
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
        }
    }
}
*/








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
    var berg:SKShapeNode!
    var shadow:SKShapeNode!
    var underwater:SKShapeNode!
    var shadowMask:SKShapeNode!
    var bergVertices:[CGPoint]!
    
    // Attributes
    let shadowColor = SKColor(red: 0.88, green: 0.93, blue: 0.96, alpha: 1.0)
    var underwaterColor = SKColor(red: 0.25, green: 0.55, blue: 0.8, alpha: 1.0) // SKColor(red: 0.5, green: 0.8, blue: 0.89, alpha: 0.5)
    var shadowHeight:CGFloat = 20.0
    var underwaterHeight:CGFloat = 20.0
    
    // Settings
    var stormMode = false
    let debug = false
    var landed = false
    
    // Path and Shape
    var reusablePath: CGMutablePath!
    var reusableShapeNode: SKShapeNode!
    
    // Functions
    init(size: CGSize, reusablePath: CGMutablePath, reusableShapeNode: SKShapeNode) {
        super.init(texture: nil, color: UIColor.clearColor(), size: size)
        
        self.reusablePath = reusablePath
        self.reusableShapeNode = reusableShapeNode
        
        bergVertices = generateRandomPoints(aroundPoint: CGPointZero)
        createBergImages()
    }
    
    init(size: CGSize) {
        super.init(texture: nil, color: UIColor.clearColor(), size: size)
        if stormMode {
            underwaterColor = SKColor(red: 0.25, green: 0.4, blue: 0.5, alpha: 1)
        }
        
        bergVertices = generateRandomPoints(aroundPoint: CGPointZero)
        
        createBergShapes()
        bob()
    }
    
    func createBergImages() {
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func generateRandomPoints(aroundPoint center: CGPoint) -> [CGPoint] { // Generate 8 points around a circle
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
            
            berg.path = bergPath
            berg.position = CGPointZero
            berg.fillColor = SKColor.whiteColor()
            berg.strokeColor = SKColor.redColor()
            berg.strokeColor = SKColor.whiteColor()
            berg.lineWidth = 1
            berg.zPosition = 100

            addChild(berg)
            
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
            
            underwater.path = underwaterPath
            underwater.position = CGPointZero
            underwater.fillColor = underwaterColor
            underwater.strokeColor = underwaterColor
            underwater.lineWidth = 1
            underwater.zPosition = -100
            
            addChild(underwater)
            
            // Create shadow shape cropped to underwater path
            let croppedShadow = SKCropNode()
            shadowMask = SKShapeNode(path: underwaterPath)
            shadow = SKShapeNode()
                        
            shadowMask.fillColor = SKColor.blackColor()
            shadowMask.strokeColor = SKColor(red: 0, green: 0, blue: 0, alpha: 0.5)
            shadowMask.position = CGPointZero
            shadowMask.name = "shadowMask"
            
            croppedShadow.maskNode = shadowMask
            croppedShadow.position = CGPointZero
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
            
            shadow.path = shadowPath
            shadow.position = CGPointZero
            shadow.fillColor = shadowColor
            shadow.strokeColor = SKColor.clearColor()// shadowColor
            shadow.lineWidth = 1
            shadow.zPosition = 50
            croppedShadow.addChild(shadow)
        }
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
    
//    func sink() {
//        self.sink(7.0)
//    }
//    runAction(action: SKAction, completion block: () -> Void)
    
    
    func sink(duration: Double, completion block: (() -> Void)?) {
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
        // Need to implement berg position reset with each new bob call.
        
        let bobDepth = stormMode ? 5.0 : 2.0
        let bobDuration = stormMode ? 0.8 : 2.0
        
        let down = SKAction.moveBy(CGVector(dx: 0.0, dy: bobDepth), duration: bobDuration)
        let wait = SKAction.waitForDuration(bobDuration / 2)
        let up = SKAction.moveBy(CGVector(dx: 0.0, dy: -bobDepth), duration: bobDuration)
        
        let bobSequence = SKAction.sequence([down, wait, up, wait])
        let bob = SKAction.repeatActionForever(bobSequence)
        
        berg!.removeAllActions()
        berg!.runAction(bob)
        underwater!.removeAllActions()
        underwater!.runAction(bob)
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
        }
    }
}



