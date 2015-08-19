//
//  MainMenuScene.swift
//  newBoston
//
//  Created by Chris on 8/18/15.
//  Copyright (c) 2015 Chris Repanich. All rights reserved.
//

import UIKit
import SpriteKit

class MainMenuScene: SKScene {
    override func didMoveToView(view: SKView) {
        //loading code
        //title label
        var nameLabel = SKLabelNode(text: "Break Even")
        nameLabel.fontName = "Arial-BoldMt"
        nameLabel.fontSize = 70
        nameLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)*1.25)
        //new game button
        var newGame = SKSpriteNode(imageNamed: "newGameButton.png")
        newGame.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        newGame.name = "play"
        //how to play button
        var howTo = SKSpriteNode(imageNamed: "howToPlay.png")
        howTo.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)*0.7)
        howTo.name = "howTo"
        //add children
        self.addChild(newGame)
        self.addChild(howTo)
        self.addChild(nameLabel)
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
        } else if (node.name == "howTo"){
            var gameScene = HowToPlayScene(size: self.size)
            var transition = SKTransition.doorsOpenHorizontalWithDuration(0.5)
            gameScene.scaleMode = SKSceneScaleMode.AspectFill
            self.scene!.view?.presentScene(gameScene, transition: transition)
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        //update method
    }
}
