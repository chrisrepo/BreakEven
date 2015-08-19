//
//  BallNode.swift
//  newBoston
//
//  Created by Chris on 8/17/15.
//  Copyright (c) 2015 Chris Repanich. All rights reserved.
//

import UIKit
import SpriteKit

class BallNode: NSObject {
    //member variables
    var isOdd: Bool = false
    var radius: CGFloat = 10
    var color: SKColor = SKColor.blackColor()
    var number: Int = 0
    var range: NSRange = NSMakeRange(1, 10)
    
    var shapeNode: SKShapeNode
    var numberNode: SKLabelNode
    var parentNode: SKNode
    
    let circleZ = CGFloat(10)
    let numberZ = CGFloat(11)
    
    init(odd: Bool, radius: CGFloat, color:SKColor, range: NSRange, position: CGPoint){
        self.isOdd = odd
        self.radius = radius
        self.color = color
        //create random odd or even number
        if(self.isOdd){
            //loop through all possible odds then choose random index
            var odds = [Int]()
            for var i=0; i < range.length; i++ {
                if (i % 2 != 0){
                    odds.append(i)
                    odds.append(i)
                    if (i == 1){
                        //make 1 the most common
                        odds.append(i)
                        odds.append(i)
                    }
                }
            }
            let randomIndex = Int(arc4random_uniform(UInt32(odds.count)))
            self.number = odds[randomIndex]
        } else {
            self.number = range.length
        }//end odd check
        var val = "\(self.number)"
        //set shape node
        self.shapeNode = SKShapeNode(circleOfRadius: self.radius)
        self.shapeNode.fillColor = self.color
        self.shapeNode.name = "shapeChild"
        //set number node'
        self.numberNode = SKLabelNode(text: "\(self.number)");
        self.numberNode.fontSize = 20;
        self.numberNode.fontName = "Arial-BoldMt"
        self.numberNode.name = "numberChild"
        self.numberNode.position.y = self.numberNode.position.y - 7
        //set parent node
        self.parentNode = SKSpriteNode();
        self.parentNode.addChild(shapeNode)
        self.parentNode.addChild(numberNode)
        self.parentNode.position = position
        
        self.parentNode.userData = ["value": self.number]
        
    }//end init
}
