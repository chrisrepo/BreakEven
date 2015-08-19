import SpriteKit

class GameScene: SKScene {
    //background node
    var background: SKSpriteNode = SKSpriteNode()
    let bgColor: UIColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
    //node member vars
    let evenNodeLimit = 1
    let oddNodeLimit = 10
    let evenNodeRadius = 150
    let oddNodeRadius = 35
    //view bounds member vars
    var lowerBoundX: CGFloat = 0.0
    var upperBoundX: CGFloat = 0.0
    var lowerBoundY: CGFloat = 0.0
    var upperBoundY: CGFloat = 0.0
    //score/timer member vars
    var highScore = NSUserDefaults.standardUserDefaults().integerForKey("highscore")
    var currentScore: Int = 0
    var scoreLabel: SKLabelNode = SKLabelNode()
    var timer = NSTimer()
    var startTime: CFTimeInterval = CFTimeInterval()
    var timeRemaining: Double = 15
    var timeAlloted: Double = 15
    var timeLabel: SKLabelNode = SKLabelNode()
    //game state vars
    var gameHasEnded = false
    var gameHasStarted = false
    
    //load view
    override func didMoveToView(view: SKView) {
        //set background node
        background = SKSpriteNode(color: UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0), size: self.frame.size)
        background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        background.colorBlendFactor = 1
        self.addChild(background)
        //set bounds of view
        self.upperBoundX = self.frame.size.width * 0.75
        self.lowerBoundX = self.frame.size.width/4
        self.lowerBoundY = 0;
        self.upperBoundY = self.frame.size.height
        //create score label
        scoreLabel.position = CGPointMake(upperBoundX - lowerBoundX*1.5, upperBoundY - (upperBoundY / 14))
        scoreLabel.text = "Score: \(currentScore)"
        scoreLabel.fontName = "Arial-BoldMt"
        self.addChild(scoreLabel)
        //create time label
        timeLabel.position = CGPointMake(upperBoundX - lowerBoundX/1.5, upperBoundY - (upperBoundY / 14))
        timeLabel.text = "Time: \(timeAlloted)"
        timeLabel.fontName = "Arial-BoldMt"
        self.addChild(timeLabel)
        //set actions
        self.runAction(SKAction.runBlock(self.initOddBubbleGroup))
        self.runAction(SKAction.runBlock(self.makeEvenBubble))
        self.startCountdown()
    }
    
    //Touches method
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch in touches {
            let location = (touch as! UITouch).locationInNode(self)
            let node = self.nodeAtPoint(location)
            //if an odd bubble was clicked
            if (!gameHasEnded && gameHasStarted){
                if (node is SKLabelNode || node is SKSpriteNode || node is SKShapeNode) {
                    //if child node is clicked
                    var oddNodeLocation = node.parent?.position
                    if (node.parent!.name == "oddNode") { //if child node is clicked
                        let even = self.childNodeWithName("evenNode") as! SKSpriteNode
                        let children = even.children
                        for child in children {
                            //lower the even number by value of odd number
                            if (child.name == "numberChild") {
                                //calculate value
                                var previousVal = even.userData!.objectForKey("value")?.integerValue
                                var oddVal = node.parent?.userData?.objectForKey("value")?.integerValue
                                var new = previousVal! - oddVal!
                                //check if ball value is in deletion range
                                if (new <= 0){
                                    if (new == 0){
                                        //if they break even
                                        var newScore = self.currentScore + 1
                                        self.startTime += 2
                                        updateScore(newScore)
                                    } else {
                                        //if they go negative
                                        var newScore = self.currentScore - 1
                                        updateScore(newScore)
                                    }
                                    node.parent?.hidden = true
                                    self.runAction(SKAction.runBlock({self.replaceOddBubble(oddNodeLocation!)}))
                                    node.parent?.removeFromParent()
                                    even.removeFromParent()
                                    let newEvenAction = SKAction.runBlock({self.makeEvenBubbleWithVal(CGFloat(self.evenNodeRadius), position: even.position)})
                                    self.runAction(newEvenAction)
                                } else {//just replace text
                                    //alter text and remove the odd node
                                    let child = child as! SKLabelNode
                                    child.text = "\(new)"
                                    even.userData = ["value": new]
                                    var factor = 1 - (0.02 * Double(oddVal!))
                                    var scaleDown = SKAction.scaleBy(CGFloat(factor), duration: NSTimeInterval(0.1))
                                    even.runAction(scaleDown)
                                    node.parent?.hidden = true
                                    self.runAction(SKAction.runBlock({self.replaceOddBubble(oddNodeLocation!)}))
                                    node.parent?.removeFromParent()
                                    
                                }//end if new < 0
                            }//end if child name is number
                        }//end for children
                    }//end if oddnode
                }//end node check
            }//end if game ended
            else if (node.name == "newGame") {
                //new game
                var gameScene = GameScene(size: self.size)
                var transition = SKTransition.doorsOpenHorizontalWithDuration(0.5)
                gameScene.scaleMode = SKSceneScaleMode.AspectFill
                self.scene!.view?.presentScene(gameScene, transition: transition)
            } else if (node.name == "mainMenu") {
                var menuScene = MainMenuScene(size: self.size)
                var transition = SKTransition.doorsOpenHorizontalWithDuration(0.5)
                menuScene.scaleMode = SKSceneScaleMode.AspectFill
                self.scene!.view?.presentScene(menuScene, transition: transition)
                //main menu
            }
        }//end for touches
    }//end touches began
    
    //update call each frame
    override func update(currentTime: CFTimeInterval) {
        if (gameHasStarted && !gameHasEnded) {
            if (self.startTime == 0) {
                self.startTime = currentTime
            }
            var elapsedTime = currentTime - self.startTime
            var timeLeft = timeRemaining - elapsedTime
            if timeLeft > 0 {
                //still time remaining in game
                //update clock
                timeLabel.text = String(format: "Time: %.2f",timeLeft)
            } else {
                //stop game
                //show end menu
                timeLabel.text = "Time: 0.00"
                self.gameHasEnded = true
                self.gameOver()
            }
        }
    }
    
    func replaceOddBubble(old: CGPoint){
        //make ball
        let ball = BallNode(odd: true, radius: CGFloat(oddNodeRadius), color: SKColor.blueColor(), range: NSMakeRange(1, 15), position: old)
        //set scale to really small and make scale action
        ball.parentNode.setScale(CGFloat(0.1))
        ball.parentNode.name = "oddNode"
        var scaleAction = SKAction.scaleTo(CGFloat(1), duration: 0.25)
        self.addChild(ball.parentNode)
        ball.parentNode.runAction(scaleAction)
    }
    
    //init the starting group of odd bubbles
    //default num of bubbles is 10
    func initOddBubbleGroup(){
        //set vertical level
        var lowerLevelY = self.upperBoundY/6 - self.upperBoundY/50
        var middleLevelY = self.upperBoundY/4
        var upperLevelY = self.upperBoundY/3 + self.upperBoundY/50
        //get horizontal offset
        var horizontalOffset = self.upperBoundX - self.lowerBoundX
        //find offset for bubbles
        var bubblesPerRow = CGFloat(self.oddNodeLimit/2)
        var fractionOffset = horizontalOffset/bubblesPerRow
        
        //create the bubbles
        for var i = 0; i < Int(bubblesPerRow); i++ {
            var xPos = CGFloat(i) * fractionOffset + fractionOffset/2 + self.lowerBoundX
            //offset isnt perfect, add values depending on i
            switch (i) {
            case 0:
                xPos = xPos + fractionOffset/3
                break;
            case 1:
                xPos = xPos + fractionOffset/6
                break;
            case 3:
                xPos = xPos - fractionOffset/6
                break;
            case 4:
                xPos = xPos - fractionOffset/3
                break;
            default: break;
            }
            var upBall = BallNode(odd: true, radius: CGFloat(oddNodeRadius), color: SKColor.blueColor(), range: NSMakeRange(1, 15), position: CGPointMake(xPos, upperLevelY))
            upBall.parentNode.name = "oddNode"
            
            var downBall = BallNode(odd: true, radius: CGFloat(oddNodeRadius), color: SKColor.blueColor(), range: NSMakeRange(1, 15), position: CGPointMake(xPos, lowerLevelY))
            downBall.parentNode.name = "oddNode"
            
            var midBall = BallNode(odd: true, radius: CGFloat(oddNodeRadius), color: SKColor.blueColor(), range: NSMakeRange(1, 15), position: CGPointMake(xPos, middleLevelY))
            midBall.parentNode.name = "oddNode"
            
            self.addChild(upBall.parentNode)
            self.addChild(downBall.parentNode)
            self.addChild(midBall.parentNode)
        }
        
    }
    
    func makeEvenBubble(){
        let locationY = self.upperBoundY*0.65
        let locationX = self.upperBoundX - self.lowerBoundX
        let location = CGPointMake(locationX, locationY)
        
        var ball = BallNode(odd: false, radius: CGFloat(evenNodeRadius), color: SKColor.greenColor(), range: NSMakeRange(1, 30), position: location)
        ball.parentNode.name = "evenNode"
        ball.numberNode.fontSize = 72
        ball.numberNode.position.y = ball.numberNode.position.y - 18
        self.addChild(ball.parentNode)
    }
    
    //create even bubble with certain value or position
    func makeEvenBubbleWithVal(val: CGFloat, position: CGPoint){
        var ball = BallNode(odd: false, radius: val, color: SKColor.greenColor(), range: NSMakeRange(1, 30), position: position)
        ball.parentNode.name = "evenNode"
        //adjust label for larger ball
        ball.numberNode.fontSize = 72
        ball.numberNode.position.y = ball.numberNode.position.y - 18
        ball.parentNode.setScale(CGFloat(0.1))
        self.addChild(ball.parentNode)
        var scaleUp = SKAction.scaleTo(CGFloat(1.25), duration: NSTimeInterval(0.1))
        var scaleDown = SKAction.scaleTo(CGFloat(1), duration: NSTimeInterval(0.1))
        
        ball.parentNode.runAction(SKAction.sequence([scaleUp, scaleDown]))
    }
    
    //development method only used to visualize the alignment
    func makeGrid(){
        var ref = CGPathCreateMutable()
        CGPathMoveToPoint(ref, nil, self.frame.size.width/2, 0 + 5)
        var line = SKShapeNode()
        CGPathAddLineToPoint(ref, nil, self.frame.size.width/2, self.frame.size.height - 5)
        line.path = ref
        line.lineWidth = 4
        line.fillColor = UIColor.redColor()
        line.strokeColor = UIColor.redColor()
        self.addChild(line)
        
        var lineHor = SKShapeNode()
        CGPathMoveToPoint(ref, nil, self.frame.size.width/4 + 50, self.frame.size.height/2)
        CGPathAddLineToPoint(ref, nil, self.frame.size.width * 0.75 - 50, self.frame.size.height/2)
        lineHor.path = ref
        lineHor.lineWidth = 4
        lineHor.fillColor = UIColor.redColor()
        lineHor.strokeColor = UIColor.redColor()
        self.addChild(lineHor)
    }
    
    //updates score with the given value
    func updateScore(newVal: Int){
        if (currentScore < newVal) {
            //the player earned a point
            //create point label
            var pointLabel = SKLabelNode(text: "+1")
            pointLabel.position = self.scoreLabel.position
            pointLabel.alpha = 0.0
            pointLabel.fontName = "Arial-BoldMt"
            pointLabel.fontSize = 20
            //create time label
            var timeLabel = SKLabelNode(text: "+2 sec")
            timeLabel.position = self.timeLabel.position
            timeLabel.alpha = 0.0
            timeLabel.fontName = "Arial-BoldMt"
            timeLabel.fontSize = 24
            //fun point animation
            var moveDownRight = SKAction.moveBy(CGVectorMake(CGFloat(15), CGFloat(-75)), duration: 0.75)
            var moveDownLeft = SKAction.moveBy(CGVectorMake(CGFloat(-15), CGFloat(-75)), duration: 0.75)
            var fadeIn = SKAction.fadeInWithDuration(0.01)
            var fadeOut = SKAction.fadeOutWithDuration(0.75)
            var scaleUp = SKAction.scaleTo(CGFloat(2), duration: 0.3)
            var scaleBack = SKAction.scaleTo(CGFloat(1), duration: 0.4)
            var removeT = SKAction.runBlock({
                timeLabel.removeFromParent()
            })
            var removeP = SKAction.runBlock({
                pointLabel.removeFromParent()
            })
            //background flash green
            var flashGreen = SKAction.colorizeWithColor(SKColor.greenColor(), colorBlendFactor: 1, duration: 0.2)
            var flashBack = SKAction.colorizeWithColor(self.bgColor, colorBlendFactor: 1.0, duration: 0.4)
            
            
            self.addChild(pointLabel)
            self.addChild(timeLabel)
            
            pointLabel.runAction(SKAction.sequence([fadeIn, SKAction.group([fadeOut, moveDownRight, SKAction.sequence([scaleUp, scaleBack])]), removeP]))
            timeLabel.runAction(SKAction.sequence([fadeIn, SKAction.group([fadeOut, moveDownLeft, SKAction.sequence([scaleUp, scaleBack])]), removeT]))
            background.runAction(SKAction.sequence([flashGreen, flashBack]))
        } else {
            //create point label
            var pointLabel = SKLabelNode(text: "-1")
            pointLabel.position = self.scoreLabel.position
            pointLabel.alpha = 0.0
            pointLabel.fontName = "Arial-BoldMt"
            pointLabel.fontSize = 20
            pointLabel.fontColor = SKColor.redColor()
            //fun point animation
            var moveDownRight = SKAction.moveBy(CGVectorMake(CGFloat(15), CGFloat(-75)), duration: 0.75)
            var moveDownLeft = SKAction.moveBy(CGVectorMake(CGFloat(-15), CGFloat(-75)), duration: 0.75)
            var fadeIn = SKAction.fadeInWithDuration(0.01)
            var fadeOut = SKAction.fadeOutWithDuration(0.75)
            var scaleUp = SKAction.scaleTo(CGFloat(2), duration: 0.3)
            var scaleBack = SKAction.scaleTo(CGFloat(1), duration: 0.4)
            var removeP = SKAction.runBlock({
                pointLabel.removeFromParent()
            })
            //background flash red
            var flashRed = SKAction.colorizeWithColor(SKColor.redColor(), colorBlendFactor: 1, duration: 0.2)
            var flashBack = SKAction.colorizeWithColor(self.bgColor, colorBlendFactor: 1.0, duration: 0.4)
            self.addChild(pointLabel)
            pointLabel.runAction(SKAction.sequence([fadeIn, SKAction.group([fadeOut, moveDownRight, SKAction.sequence([scaleUp, scaleBack])]), removeP]))
            background.runAction(SKAction.sequence([flashRed, flashBack]))
        }
        self.currentScore = newVal
        self.scoreLabel.text = "Score: \(self.currentScore)"
    }
    
    func startCountdown(){
        var labelVal = 3
        var countdownLabel = SKLabelNode(text: "\(labelVal)")
        countdownLabel.fontSize = 220
        countdownLabel.fontColor = SKColor.redColor()
        countdownLabel.fontName = "Arial-BoldMt"
        countdownLabel.zPosition = 50
        countdownLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        self.addChild(countdownLabel)
        var changeLabel = SKAction.runBlock({
            labelVal--
            countdownLabel.text = "\(labelVal)"
            if (labelVal == 0){
                countdownLabel.text = "Go!"
                var fade1 = SKAction.fadeOutWithDuration(0.9)
                var remove = SKAction.runBlock({countdownLabel.removeFromParent()})
                countdownLabel.runAction(SKAction.sequence([fade1,remove]))
            }
        })
        var wait1 = SKAction.waitForDuration(1)
        var startGame = SKAction.runBlock({
            self.gameHasStarted = true
            self.startTime = CFTimeInterval()
        })
        self.runAction(SKAction.sequence([wait1, changeLabel, wait1, changeLabel, wait1, changeLabel, wait1,startGame]))
    }
    //run when game ends (remove ball nodes and add game over menu)
    func gameOver(){
        var allKids = self.children as! [SKNode]
        var wait1 = SKAction.waitForDuration(1.5)
        var run = SKAction.runBlock({
            for kid in allKids{
                if (kid.name == "evenNode" || kid.name == "oddNode") {
                    kid.removeFromParent()
                }
            }
        })
        //game over label
        var gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontName = "Arial-BoldMt"
        gameOverLabel.fontSize = 50
        gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)*1.25)
        gameOverLabel.alpha = 0.0
        self.addChild(gameOverLabel)
        //score label
        var scorelabel = SKLabelNode(text: "Your score: \(self.currentScore)")
        scorelabel.fontSize = scorelabel.fontSize + 10
        scorelabel.fontName = "Arial-BoldMt"
        scorelabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)*0.8)
        scorelabel.alpha = 0.0
        //high score label
        var newHighScoreLabel = SKLabelNode(text: "Your high score: \(self.highScore)")
        if self.currentScore > self.highScore {
            newHighScoreLabel.text = "Old high score: \(self.highScore)"
            scorelabel.text = "New high score: \(self.currentScore)!"
            NSUserDefaults.standardUserDefaults().setInteger(self.currentScore, forKey: "highscore")
        }
        newHighScoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        newHighScoreLabel.alpha = 0.0
        newHighScoreLabel.fontName = "Arial-BoldMt"
        self.addChild(newHighScoreLabel)
        self.addChild(scorelabel)
        //get offset for buttons
        var xOffset = (upperBoundX - lowerBoundX)/5
        //new game button
        var newGameButton = SKSpriteNode(imageNamed: "newGameButton.png")
        newGameButton.position = CGPointMake(CGRectGetMidX(self.frame) - xOffset, CGRectGetMidY(self.frame) * 0.6)
        newGameButton.alpha = 0.0
        newGameButton.name = "newGame"
        self.addChild(newGameButton)
        //main menu button
        var mainMenuButton = SKSpriteNode(imageNamed: "mainMenu.png")
        mainMenuButton.position = CGPointMake(CGRectGetMidX(self.frame) + xOffset, CGRectGetMidY(self.frame) * 0.6)
        mainMenuButton.alpha = 0.0
        mainMenuButton.name = "mainMenu"
        self.addChild(mainMenuButton)
        //fade in labels and remove balls
        var fadeIn = SKAction.fadeInWithDuration(0.75)
        var goAction = SKAction.runBlock({
            gameOverLabel.runAction(fadeIn)
            scorelabel.runAction(fadeIn)
            newHighScoreLabel.runAction(fadeIn)
            newGameButton.runAction(fadeIn)
            mainMenuButton.runAction(fadeIn)
        })
        self.runAction(SKAction.sequence([wait1, run, goAction]))
    }
}
