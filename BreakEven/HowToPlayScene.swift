//
//  HowToPlayScene.swift
//  newBoston
//
//  Created by Chris on 8/18/15.
//  Copyright (c) 2015 Chris Repanich. All rights reserved.
//

import UIKit
import SpriteKit
class HowToPlayScene: SKScene {
    var fontName = "Arial-BoldMt"
    var lowerBoundX: CGFloat = 0.0
    var upperBoundX: CGFloat = 0.0
    var lowerBoundY: CGFloat = 0.0
    var upperBoundY: CGFloat = 0.0
    override func didMoveToView(view: SKView) {
        self.upperBoundX = self.frame.size.width * 0.75
        self.lowerBoundX = self.frame.size.width/4
        self.lowerBoundY = 0;
        self.upperBoundY = self.frame.size.height
        //title label
        var titleLabel = SKLabelNode(text: "How to play:")
        titleLabel.fontName = fontName
        titleLabel.fontSize = 40
        titleLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)*1.8)
        //first line
        let multiLabel1 = SKMultilineLabel(text: "- Tap the odd number balls at the bottom of the screen to subtract their value from the green ball.", labelWidth: Int(upperBoundX*0.8-lowerBoundX), pos: CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)*1.7), fontName: fontName, fontSize: 22, leading: 25, alignment: SKLabelHorizontalAlignmentMode.Left)
        
        let multiLabel2 = SKMultilineLabel(text: "- If you get the green ball to 0, you get 1 point added to your score and 2 seconds added to the timer.", labelWidth: Int(upperBoundX*0.8-lowerBoundX), pos: CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)*1.4), fontName: fontName, fontSize: 22, leading: 25, alignment: SKLabelHorizontalAlignmentMode.Left)
        
        let multiLabel3 = SKMultilineLabel(text: "- If the value of the green ball passes 0, you lose one point and do not gain any extra time.", labelWidth: Int(upperBoundX*0.8-lowerBoundX), pos: CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)*1.1),fontName: fontName, fontSize: 22, leading: 25, alignment: SKLabelHorizontalAlignmentMode.Left)
        
        let multiLabel4 = SKMultilineLabel(text: "- Have fun and break even!", labelWidth: Int(upperBoundX*0.8-lowerBoundX), pos: CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)*0.8),fontName: fontName, fontSize: 22, leading: 25, alignment: SKLabelHorizontalAlignmentMode.Left)
        
        self.addChild(titleLabel)
        self.addChild(multiLabel1)
        self.addChild(multiLabel2)
        self.addChild(multiLabel3)
        self.addChild(multiLabel4)
        
        //new game button
        var newGame = SKSpriteNode(imageNamed: "newGameButton.png")
        newGame.position = CGPointMake(CGRectGetMidX(self.frame)*0.8, CGRectGetMidY(self.frame)*0.55)
        newGame.name = "play"
        //main menu button
        var howTo = SKSpriteNode(imageNamed: "mainMenu.png")
        howTo.position = CGPointMake(CGRectGetMidX(self.frame)*1.2, CGRectGetMidY(self.frame)*0.55)
        howTo.name = "mainMenu"
        //add children
        self.addChild(newGame)
        self.addChild(howTo)
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        //touches method code
        var touch = touches as!  Set<UITouch>
        var location = touch.first!.locationInNode(self)
        var node = self.nodeAtPoint(location)
        
        if (node.name == "play") {
            var gameScene = GameScene(size: self.size)
            var transition = SKTransition.doorsOpenHorizontalWithDuration(0.5)
            gameScene.scaleMode = SKSceneScaleMode.AspectFill
            self.scene!.view?.presentScene(gameScene, transition: transition)
        } else if (node.name == "mainMenu"){
            var gameScene = MainMenuScene(size: self.size)
            var transition = SKTransition.doorsOpenHorizontalWithDuration(0.5)
            gameScene.scaleMode = SKSceneScaleMode.AspectFill
            self.scene!.view?.presentScene(gameScene, transition: transition)
        }
    }
}
