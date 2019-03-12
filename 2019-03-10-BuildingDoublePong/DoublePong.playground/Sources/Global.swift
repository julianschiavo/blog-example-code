import AppKit
import SpriteKit

public let scene = Scene()

/// Main Game Variables
public var score = 0 {
    didSet {
        scoreLabel.stringValue = String(score)
    }
}

public var lives = 5 {
    didSet {
        livesLabel.stringValue = String(repeating: "❤️", count: lives)
    }
}

public var isPlaying = true
public let themeColor = NSColor.red
public let buttonColor = NSColor(red: 0.0, green: 0.478431, blue: 1.0, alpha: 1.0)

// Bit Masks
public let Ball: UInt32 = 0x1 << 0
public let topPaddleI: UInt32 = 0x1 << 1
public let leftPaddleI: UInt32 = 0x1 << 2
public let rightPaddleI: UInt32 = 0x1 << 3
public let bottomPaddleI: UInt32 = 0x1 << 4
public let randomObstacleI: UInt32 = 0x1 << 5

// SKNode variables (paddles and ball)
public var ball = SKShapeNode(circleOfRadius: 30)
public var topPaddle = SKSpriteNode()
public var leftPaddle = SKSpriteNode()
public var rightPaddle = SKSpriteNode()
public var bottomPaddle = SKSpriteNode()
public var randomObstacle = SKSpriteNode()

// Control elements
public var overLabel = NSTextField()
public var scoreLabel = NSTextField()
public var livesLabel = NSTextField()
public var curScoreLabel = NSTextField()
public var restartButtonBig = NSButton()
