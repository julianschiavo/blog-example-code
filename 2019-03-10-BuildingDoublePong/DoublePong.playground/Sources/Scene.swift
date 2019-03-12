import AppKit
import SpriteKit

public class Scene: SKScene, SKPhysicsContactDelegate {

    // Restart the game when restart button is pressed, also resets ball position/velocity
    @objc public func restartGame() {
        if overLabel.isHidden {
            removeChilds(ball, topPaddle, bottomPaddle, leftPaddle, rightPaddle)
            removeSubviews(scoreLabel)
        }

        score = 0
        lives = 5
        overLabel.isHidden = true
        livesLabel.isHidden = false
        scoreLabel.isHidden = false
        curScoreLabel.isHidden = true
        restartButtonBig.isHidden = true

        ball.position = CGPoint(x: CGFloat.random(in: 325...1595), y: CGFloat.random(in: 325...755))
        ball.physicsBody!.velocity = CGVector(dx: 400, dy: 400)

        addSubviews(scoreLabel)
        addChilds(ball, topPaddle, bottomPaddle, leftPaddle, rightPaddle)
    }
    
    func endGame() {
        // Player doesn't have any lives left
        overLabel.isHidden = false
        livesLabel.isHidden = true
        scoreLabel.isHidden = true
        restartButtonBig.isHidden = false
        
        curScoreLabel.isHidden = false
        curScoreLabel.stringValue = "Score: " + String(score)

        // Remove any random obstacles and the sprites
        removeChilds(randomObstacle, randomObstacle)
        removeChilds(ball, topPaddle, leftPaddle, rightPaddle, bottomPaddle)
    }
    
    
    /// If the mouse is moved, move all the paddles based on the new mouse location
    override public func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
        
        /// **Using different padding sizes creates a "click" when the user moves the paddle to the screen edge**
        /// Minimum padding for "click" to activate
        let clickPadding: CGFloat = 65
        
        /// Bare minimum padding for horizontal paddles
        let horizontalPadding: CGFloat = 25
        
        /// Bare minimum padding for vertical paddles
        let verticalPadding: CGFloat = 27
        
        /// Half the length of the paddles
        let halfPaddleLength: CGFloat = 275 // 550 divided by 2
        
        /// The size of the screen
        let screenSize = CGSize(width: 1920, height: 1080)
        
        /// The location of the mouse
        let location = event.location(in: self)
        
        if location.x < screenSize.width - clickPadding - halfPaddleLength, location.x > halfPaddleLength + clickPadding {
            // If the mouse location is within the size of the screen with the padding included, use the location as the paddle location
            topPaddle.position.x = location.x
            bottomPaddle.position.x = location.x
            
        } else if location.x > screenSize.width - clickPadding - halfPaddleLength {
            // If the mouse location is past the padding (outside the bounds), use the maximum possible location
            topPaddle.position.x = screenSize.width - halfPaddleLength - horizontalPadding
            bottomPaddle.position.x = screenSize.width - halfPaddleLength - horizontalPadding
            
        } else if location.x < halfPaddleLength + clickPadding {
            // If the mouse location is before the padding (outside the bounds), use the minimum possible location
            topPaddle.position.x = halfPaddleLength + horizontalPadding
            bottomPaddle.position.x = halfPaddleLength + horizontalPadding
        }
        
        if location.y < screenSize.height - clickPadding - halfPaddleLength, location.y > clickPadding + halfPaddleLength {
            // If the mouse location is within the size of the screen with the padding included, use the location as the paddle location
            leftPaddle.position.y = location.y
            rightPaddle.position.y = location.y
            
        } else if location.y > screenSize.height - clickPadding - halfPaddleLength {
            // If the mouse location is past the padding (outside the bounds), use the maximum possible location
            leftPaddle.position.y = screenSize.height - verticalPadding - halfPaddleLength
            rightPaddle.position.y = screenSize.height - verticalPadding - halfPaddleLength
            
        } else if location.y < clickPadding + halfPaddleLength {
            // If the mouse location is before the padding (outside the bounds), use the minimum possible location
            leftPaddle.position.y = halfPaddleLength + verticalPadding
            rightPaddle.position.y = halfPaddleLength + verticalPadding
        }
    }
    
    /// Registers the view to receive mouse movements and clicks
    func registerForMouseEvents(on view: SKView) {
        let options: NSTrackingArea.Options = [.activeAlways, .inVisibleRect, .mouseEnteredAndExited, .mouseMoved]

        let trackingArea = NSTrackingArea(rect: view.frame, options: options, owner: self, userInfo: nil)
        view.addTrackingArea(trackingArea)
    }
    
    /// Set up the ball's position, color, and gravity settings
    func setupBall() {
        ball.name = "ball"
        ball.fillColor = themeColor
        ball.strokeColor = themeColor
        ball.position = CGPoint(x: CGFloat.random(in: 325...1595), y: CGFloat.random(in: 325...755))

        // Set up the ball's physics body and properties to make it bounce and work correctly
        let physicsBody = SKPhysicsBody(circleOfRadius: 30)
        physicsBody.velocity = CGVector(dx: 400, dy: 400)
        physicsBody.friction = 0
        physicsBody.restitution = 1
        physicsBody.linearDamping = 0
        physicsBody.allowsRotation = false
        physicsBody.categoryBitMask = Ball
        physicsBody.contactTestBitMask = randomObstacleI
        ball.physicsBody = physicsBody
    }
    
    // Sets up the paddles for the game
    func setupPaddles() {
        let randomHorizontalPosition = CGFloat.random(in: 325...1595)
        let horizontalPaddleSize = CGSize(width: 550, height: 50)

        let randomVerticalPosition = CGFloat.random(in: 325...755)
        let verticalPaddleSize = CGSize(width: 50, height: 550)

        topPaddle = createNode(color: themeColor, size: horizontalPaddleSize, name: "topPaddle", dynamic: false, friction: 0, restitution: 1, cBM: topPaddleI, cTBM: Ball, position: CGPoint(x: randomHorizontalPosition, y: frame.maxY - 50))
        bottomPaddle = createNode(color: themeColor, size: horizontalPaddleSize, name: "bottomPaddle", dynamic: false, friction: 0, restitution: 1, cBM: bottomPaddleI, cTBM: Ball, position: CGPoint(x: randomHorizontalPosition, y: frame.minY + 50))

        leftPaddle = createNode(color: themeColor, size: verticalPaddleSize, name: "leftPaddle", dynamic: false, friction: 0, restitution: 1, cBM: leftPaddleI, cTBM: Ball, position: CGPoint(x: frame.minX + 50, y: randomVerticalPosition))
        rightPaddle = createNode(color: themeColor, size: verticalPaddleSize, name: "rightPaddle", dynamic: false, friction: 0, restitution: 1, cBM: rightPaddleI, cTBM: Ball, position: CGPoint(x: frame.maxX - 50, y: randomVerticalPosition))
    }
    
    // Sets up the score and info labels
    func setupLabels() {
        guard let frame = view?.frame else { return }
        
        scoreLabel = createLabel(title: String(score), alignment: .left, size: 20.0, color: .white, hidden: false, x: 9, y: Double(frame.maxY - 24 - 9), width: 100, height: 24)
        curScoreLabel = createLabel(title: "Score: ", size: 25.0, color: .white, hidden: true, x: Double(frame.width / 2 - 260), y: Double(frame.height / 2 - 65), width: 520, height: 60)
        livesLabel = createLabel(title: String(repeating: "❤️", count: lives), alignment: .right, size: 15.0, color: .white, hidden: false, x: Double(frame.maxX - 113 - 9), y: Double(frame.maxY - 19 - 9), width: 113, height: 19)
        overLabel = createLabel(title: "Game Over", size: 60.0, color: .red, hidden: true, bold: true, x: Double((frame.width / 2) - 250), y: Double(30 + (frame.height / 2) - 50), width: 500, height: 100)
    }
    
    // Sets up the pause, play and restart buttons
    func setupButtons() {
        guard let frame = view?.frame else { return }
        
        restartButtonBig = createButton(title: "Restart", color: buttonColor, image: nil, action: #selector(self.restartGame), transparent: false, x: (frame.width / 2) - 140, y: ((frame.height / 2) - 8) - 130, width: 280, height: 45, hidden: true, radius: 18)
    }
    
    // The scene was created. Setup the game elements and start the game.
    override public func didMove(to view: SKView) {
        // Registers the view to receive mouse movements and clicks
        registerForMouseEvents(on: view)
        
        // Setup the world physics
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        // Create a border in the view to keep the ball inside
        size = CGSize(width: 1920, height: 1080)
        let margin: CGFloat = 50
        let physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: margin, y: margin, width: size.width - margin * 2, height: size.height - margin * 2))
        physicsBody.friction = 0
        physicsBody.restitution = 0
        self.physicsBody = physicsBody
        
        // Set up the game elements
        setupBall()
        setupPaddles()
        setupLabels()
        setupButtons()
        
        addChilds(ball, topPaddle, bottomPaddle, leftPaddle, rightPaddle)
        addSubviews(overLabel, scoreLabel, livesLabel, curScoreLabel, restartButtonBig)
    }
    
    /// Catch collisions between a paddle and the ball, to add points and velocity, as well as between the screen edges and the ball, to remove lives or show Game Over screen
    public func didBegin(_ contact: SKPhysicsContact) {
        let firstContactedBody = contact.bodyA.node?.name
        let secondContactedBody = contact.bodyB.node?.name

        // If the ball is not one of the bodies that contacted, skip everything else
        guard secondContactedBody == "ball" else { return }

        // If the ball's physics body doesn't exist, there's nothing we can do except exit
        guard let ballVelocity = ball.physicsBody?.velocity else { fatalError("The ball must have a physics body!") }

        // The ball has hit one of the paddles
        if firstContactedBody == "topPaddle" || firstContactedBody == "bottomPaddle" || firstContactedBody == "leftPaddle" || firstContactedBody == "rightPaddle" {
            // New score is current score plus the positive value of the ball's current Y velocity divided by 40
            // This increases amount of awarded points as ball speeds up
            let divisor: CGFloat = 40
            score += Int(abs(ballVelocity.dy / divisor))
            
            // If the velocity is very low (e.g. slowed down by obstacle), increase it to a normal velocity
            // Otherwise, increase it by a random velocity
            if -100...0 ~= ballVelocity.dx || -100...0 ~= ballVelocity.dy {
                ball.physicsBody?.velocity.dx += -300
                ball.physicsBody?.velocity.dy += -300
            } else if 0...100 ~= ballVelocity.dx || 0...100 ~= ballVelocity.dy {
                ball.physicsBody?.velocity.dx += 300
                ball.physicsBody?.velocity.dy += 300
            } else {
                // Choose a random velocity to increase by
                let increase = CGFloat.random(in: 5...10)

                // Increase the velocity based on whether it's negative or not
                ball.physicsBody?.velocity.dx  += (ballVelocity.dx < CGFloat(0)) ? -increase : increase
                ball.physicsBody?.velocity.dy  += (ballVelocity.dy < CGFloat(0)) ? -increase : increase
            }
        }

        // The ball has hit one of the edges of the game boundary
        if firstContactedBody == nil {
            if lives > 1 {
                // Player still has more than 1 life, remove one life and update the label
                lives = lives - 1
            } else {
                endGame()
            }
        }
    }
}
