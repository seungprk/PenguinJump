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
//    var bergVertices:[CGPoint]!
    
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
    
    // Path and Shape
//    var reusablePath: CGMutablePath!
//    var drawingLayer: CGLayerRef!
    
    // Functions
    init(size: CGSize) {
        super.init(texture: nil, color: UIColor.clearColor(), size: size)
        
//        self.reusablePath = reusablePath
//        self.drawingLayer = drawingLayer
        
//        bergVertices = generateRandomPoints(aroundPoint: CGPointZero, radius: Double(size.width) / 2)
        createBergNodes()
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

        // Generate points of shadow
        var shadowVertices = [CGPoint]()
        shadowVertices.append(vertices[startPoint])
        shadowVertices.append(CGPoint(x: vertices[startPoint].x, y: vertices[startPoint].y - shadowHeight))
        for point in startPoint + 1 ..< endPoint {
            shadowVertices.append(CGPoint(x: vertices[point].x, y: vertices[point].y - shadowHeight))
        }
        shadowVertices.append(CGPoint(x: vertices[endPoint].x, y: vertices[endPoint].y - shadowHeight))
        shadowVertices.append(vertices[endPoint])

        // Generate points of underwater shape
        var underwaterVertices = [CGPoint]()
        underwaterVertices.append(vertices[startPoint])
        underwaterVertices.append(CGPoint(x: vertices[startPoint].x, y: vertices[startPoint].y - shadowHeight - underwaterHeight))
        for point in startPoint + 1 ..< endPoint {
            underwaterVertices.append(CGPoint(x: vertices[point].x, y: vertices[point].y - shadowHeight - underwaterHeight))
        }
        underwaterVertices.append(CGPoint(x: vertices[endPoint].x, y: vertices[endPoint].y - shadowHeight - underwaterHeight))
        underwaterVertices.append(vertices[endPoint])
        
        
        // Generate images
        UIGraphicsBeginImageContext(CGSize(width: 150, height: 150))
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSaveGState(context)
        CGContextScaleCTM(context, 1, -1)
        CGContextTranslateCTM(context, 0, -size.height)
        CGContextSetRGBFillColor(context, 1, 1, 1, 1)
        CGContextAddLines(context, vertices, vertices.count)
        CGContextFillPath(context)
        let bergImage = UIGraphicsGetImageFromCurrentImageContext()
        CGContextRestoreGState(context)
        
        UIGraphicsEndImageContext()
        
        UIGraphicsBeginImageContext(CGSize(width: 150, height: 150 + shadowHeight))
        let context1 = UIGraphicsGetCurrentContext()
        
        CGContextSaveGState(context1)
        //  let shadowColor = SKColor(red: 0.88, green: 0.93, blue: 0.96, alpha: 1.0)
        CGContextScaleCTM(context1, 1, -1)
        CGContextTranslateCTM(context1, 0, -size.height / 2 - shadowHeight)
        CGContextSetRGBFillColor(context1, 0.88, 0.93, 0.96, 1)
        CGContextAddLines(context1, shadowVertices, shadowVertices.count)
        CGContextFillPath(context1)
        let shadowImage = UIGraphicsGetImageFromCurrentImageContext()
        CGContextRestoreGState(context1)
        
        UIGraphicsBeginImageContext(CGSize(width: 150, height: 150 + shadowHeight + underwaterHeight))
        let context2 = UIGraphicsGetCurrentContext()
        
        CGContextSaveGState(context2)
        // let underwaterColor = SKColor(red: 0.25, green: 0.55, blue: 0.8, alpha: 1.0)
        CGContextScaleCTM(context2, 1, -1)
        CGContextTranslateCTM(context2, 0, -size.height / 2 - underwaterHeight - shadowHeight)
        CGContextSetRGBFillColor(context2, 0.25, 0.55, 0.8, 1)
        CGContextAddLines(context2, underwaterVertices, underwaterVertices.count)
        CGContextFillPath(context2)
        let underwaterImage = UIGraphicsGetImageFromCurrentImageContext()
        let shadowMaskImage = UIGraphicsGetImageFromCurrentImageContext()
        CGContextRestoreGState(context2)
        
        UIGraphicsEndImageContext()
        

        let bergTexture = SKTexture(image: bergImage)
        berg = SKSpriteNode(texture: bergTexture)
        berg.position = CGPointZero
        berg.position.y -= underwaterHeight / 4
        berg.zPosition = 100
//        berg.alpha = 0.5
        addChild(berg)
        
        
        
        let underwaterTexture = SKTexture(image: underwaterImage)
        underwater = SKSpriteNode(texture: underwaterTexture)
        underwater.position = CGPointZero
        underwater.position.y -= shadowHeight + underwaterHeight + underwaterHeight
        underwater.zPosition = -300
        addChild(underwater)
        
        
        let shadowMaskTexture = SKTexture(image: shadowMaskImage)
        shadowMask = SKSpriteNode(texture: shadowMaskTexture)
        let shadowTexture = SKTexture(image: shadowImage)
        shadow = SKSpriteNode(texture: shadowTexture)
        
        let croppedShadow = SKCropNode()
        croppedShadow.maskNode = shadowMask
        croppedShadow.zPosition = 50
        addChild(croppedShadow)
        
        croppedShadow.addChild(shadow)
        croppedShadow.position.y -= shadowHeight + underwaterHeight / 2
        shadowMask.position.y -= shadowHeight + underwaterHeight / 2
        shadow.position.y -= shadowHeight + underwaterHeight

        
    }
    
    /*
    // Create CGPath of berg shape
    let bergPath = CGPathCreateMutable()
    CGPathMoveToPoint(bergPath, nil, vertices[0].x, vertices[0].y)
    for point in 1..<vertices.count {
    CGPathAddLineToPoint(bergPath, nil, vertices[point].x, vertices[point].y)
    }
    CGPathCloseSubpath(bergPath)
    
    // Create CGPath of shadow shape
    let shadowPath = CGPathCreateMutable()
    CGPathMoveToPoint(shadowPath, nil, vertices[startPoint].x, vertices[startPoint].y)
    CGPathAddLineToPoint(shadowPath, nil, vertices[startPoint].x, vertices[startPoint].y - shadowHeight)
    for point in startPoint + 1 ..< endPoint {
    CGPathAddLineToPoint(shadowPath, nil, vertices[point].x, vertices[point].y - shadowHeight)
    }
    CGPathAddLineToPoint(shadowPath, nil, vertices[endPoint].x, vertices[endPoint].y - shadowHeight)
    CGPathAddLineToPoint(shadowPath, nil, vertices[endPoint].x, vertices[endPoint].y)
    CGPathCloseSubpath(shadowPath)
    
    // Create CGPath of underwater shape
    let underwaterPath = CGPathCreateMutable()
    CGPathMoveToPoint(underwaterPath, nil, vertices[startPoint].x, vertices[startPoint].y)
    CGPathAddLineToPoint(underwaterPath, nil, vertices[startPoint].x, vertices[startPoint].y - shadowHeight - underwaterHeight)
    for point in startPoint + 1 ..< endPoint {
    CGPathAddLineToPoint(underwaterPath, nil, vertices[point].x, vertices[point].y - shadowHeight - underwaterHeight)
    }
    CGPathAddLineToPoint(underwaterPath, nil, vertices[endPoint].x, vertices[endPoint].y - shadowHeight - underwaterHeight)
    CGPathAddLineToPoint(underwaterPath, nil, vertices[endPoint].x, vertices[endPoint].y)
    CGPathCloseSubpath(underwaterPath)
    
    
    // Generate images
    UIGraphicsBeginImageContext(CGSize(width: 150, height: 150))
    let context = UIGraphicsGetCurrentContext()
    
    let renderingLayer = CAShapeLayer()
    renderingLayer.path = bergPath
    renderingLayer.fillColor = bergColor.CGColor // UIColor.whiteColor().CGColor
    renderingLayer.setNeedsDisplay()
    renderingLayer.renderInContext(context!)
    let bergImage = UIGraphicsGetImageFromCurrentImageContext()
    
    renderingLayer.path = shadowPath
    renderingLayer.fillColor = shadowColor.CGColor
    renderingLayer.setNeedsDisplay()
    renderingLayer.renderInContext(context!)
    let shadowImage = UIGraphicsGetImageFromCurrentImageContext()
    
    renderingLayer.path = underwaterPath
    renderingLayer.fillColor = underwaterColor.CGColor
    renderingLayer.setNeedsDisplay()
    renderingLayer.renderInContext(context!)
    let underwaterImage = UIGraphicsGetImageFromCurrentImageContext()
    let shadowMaskImage = UIGraphicsGetImageFromCurrentImageContext()
    
    UIGraphicsEndImageContext()
    */

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Generate 8 points around a circle
    func generateRandomPoints(aroundPoint center: CGPoint, radius: Double) -> [CGPoint] {
//        let radius = Double(size.width / 2)
        
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
    
    /*
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
*/
    /*
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
*/
    /*
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
            self.sink(7.0)
        }
        runAction(action: SKAction, completion block: () -> Void)
    */
    
    func sink(duration: Double, completion block: (() -> Void)?) {
        let sinkDepth = shadowHeight
        
        let sink = SKAction.moveBy(CGVector(dx: 0.0, dy: -sinkDepth), duration: duration)
        
        underwater!.runAction(sink)
        shadowMask!.runAction(sink)
        
        berg!.runAction(sink, completion: {
            let underwaterColor = SKColor(red: 0.83, green: 0.94, blue: 0.97, alpha: 1)
            //            self.berg!.fillColor = underwaterColor
            //            self.berg!.strokeColor = underwaterColor
            
            
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
//        let wait = SKAction.waitForDuration(bobDuration / 2)
        let up = SKAction.moveBy(CGVector(dx: 0.0, dy: -bobDepth), duration: bobDuration)
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