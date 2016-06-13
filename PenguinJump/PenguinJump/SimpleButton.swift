//
//  SimpleButton.swift
//  PenguinJump
//
//  Created by Seung Park on 6/8/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit


class SimpleButton: SKNode {
    
    var label : SKLabelNode!
    var mainBox : SKShapeNode!
    var shadow : SKShapeNode!
    
    var pressed : Bool!
    
    init(text: String) {
        super.init()
        pressed = false
        
        // Init Label
        label = SKLabelNode(text: text)
        label.fontSize = 30
        label.fontColor = SKColor(red: 35/255, green: 134/255, blue: 221/255, alpha: 1.0)
        label.fontName = "Helvetica Neue Condensed Black"
        
        // Init Pressable Box
        let boxSize = CGSize(width: label.frame.width * 1.1, height: label.frame.height * 1.3)
        mainBox = SKShapeNode(rectOfSize: boxSize, cornerRadius: 10)
        mainBox.fillColor = UIColor(red: 250/255, green: 240/255, blue: 225/255, alpha: 1.0)
        mainBox.strokeColor = UIColor.clearColor()
        mainBox.position.y += label.frame.height * 0.5
        
        // Init Shadow
        shadow = SKShapeNode(rectOfSize: mainBox.frame.size, cornerRadius: 10)
        shadow.fillColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)
        mainBox.strokeColor = UIColor.clearColor()
        shadow.position.y = mainBox.position.y - 10
        
        // Add
        addChild(shadow)
        addChild(mainBox)
        addChild(label)
    }

    func buttonPress(soundOn: NSNumber) {
        if soundOn == true {
            runAction(SKAction.playSoundFileNamed("button_press.m4a", waitForCompletion: false))
        }
        mainBox.position.y -= 7
        label.position.y -= 7
        pressed = true
    }
    
    func buttonRelease() {
        if pressed == true {
            mainBox.position.y += 7
            label.position.y += 7
            pressed = false
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
