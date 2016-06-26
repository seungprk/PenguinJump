//
//  GameScene+Utilities.swift: Game scene utility functions.
//  PenguinJump
//
//  Created by Matthew Tso on 6/18/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit

/// Overloaded minus operator to use on CGPoint
func -(first: CGPoint, second: CGPoint) -> CGPoint {
    let deltaX = first.x - second.x
    let deltaY = first.y - second.y
    return CGPoint(x: deltaX, y: deltaY)
}

extension GameScene {
    
    /// Utility function that is used to shake the screen when the penguin lands on an iceberg to give the illusion of impact.
    func shakeScreen() {
        if enableScreenShake {
            let shakeAnimation = CAKeyframeAnimation(keyPath: "transform")
            //            let randomIntensityOne = CGFloat(random() % 4 + 1)
            let randomIntensityTwo = CGFloat(arc4random() % 4 + 1)
            shakeAnimation.values = [
                //NSValue( CATransform3D:CATransform3DMakeTranslation(-randomIntensityOne, 0, 0 ) ),
                //NSValue( CATransform3D:CATransform3DMakeTranslation( randomIntensityOne, 0, 0 ) ),
                NSValue( caTransform3D: CATransform3DMakeTranslation( 0, -randomIntensityTwo, 0 ) ),
                NSValue( caTransform3D: CATransform3DMakeTranslation( 0, randomIntensityTwo, 0 ) ),
            ]
            shakeAnimation.repeatCount = 1
            shakeAnimation.duration = 25/100
            
            view!.layer.add(shakeAnimation, forKey: nil)
        }
    }
}
