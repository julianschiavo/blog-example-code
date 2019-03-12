import AppKit
import SpriteKit

public extension NSImage {
    /// Inverts the colors of the image
    public func inverted() -> NSImage {
        let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil)
        let ciImage = CoreImage.CIImage(cgImage: cgImage!)
        
        guard let filter = CIFilter(name: "CIColorInvert") else { return self }
        filter.setDefaults()
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        let context = CIContext(options: nil)
        
        guard let outputImage = filter.outputImage,
            let outputImageCopy = context.createCGImage(outputImage, from: outputImage.extent) else { return self }
        return NSImage(cgImage: outputImageCopy, size: NSSize(width: outputImageCopy.width, height: outputImageCopy.height))
    }
}

public extension SKNode {
    /// Creates a SKSpriteNode with the specified parameters.
    public func createNode(color: NSColor, size: CGSize, name: String, dynamic: Bool, friction: CGFloat, restitution: CGFloat, cBM: UInt32, cTBM: UInt32?, position: CGPoint? = nil) -> SKSpriteNode {
        let node = SKSpriteNode(color: color, size: size)
        node.name = name
        
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody?.isDynamic = dynamic
        node.physicsBody?.friction = friction
        node.physicsBody?.restitution = restitution
        node.physicsBody?.categoryBitMask = cBM
        
        if let cTBM = cTBM {
            node.physicsBody?.contactTestBitMask = cTBM
        }
        
        if let position = position {
            node.position = position
        }
        
        return node
    }
}

public extension SKScene {
    /// Adds multiple childs at once
    public func addChilds(_ childs: SKNode...) {
        for child in childs { self.addChild(child) }
    }
    
    /// Removes multiple childs at once
    public func removeChilds(_ childs: SKNode...) {
        for child in childs { child.removeFromParent() }
    }
    
    /// Adds multiple subviews at once
    public func addSubviews(_ views: NSView...) {
        for view in views { self.view?.addSubview(view) }
    }
    
    /// Removes multiple subviews at once
    public func removeSubviews(_ views: NSView...) {
        for view in views { view.removeFromSuperview() }
    }
    
    /// Creates a NSButton with the specified parameters
    public func createButton(title: String = "Empty", size: Int = 18, color: NSColor = NSColor.clear, image: NSImage? = nil, action: Selector, transparent: Bool = true, x: CGFloat = 0, y: CGFloat = 0, width: CGFloat = 0, height: CGFloat = 0, hidden: Bool = false, radius: Int = 0) -> NSButton {
        let button = image != nil ? NSButton(image: image!, target: self, action: action) : NSButton(title: title, target: self, action: action)
        button.isHidden = hidden
        button.isTransparent = transparent
        button.frame = NSRect(x: x, y: y, width: width, height: height)
        
        if (title != "Empty") {
            button.wantsLayer = true
            button.isBordered = false
            button.layer?.cornerRadius = CGFloat(radius)
            button.layer?.masksToBounds = true
            button.layer?.backgroundColor = color.cgColor
            if let mutableAttributedTitle = button.attributedTitle.mutableCopy() as? NSMutableAttributedString {
                mutableAttributedTitle.addAttribute(.foregroundColor, value: NSColor.white, range: NSRange(location: 0, length: mutableAttributedTitle.length))
                mutableAttributedTitle.addAttribute(.font, value: NSFont.systemFont(ofSize: CGFloat(size)), range: NSRange(location: 0, length: mutableAttributedTitle.length))
                button.attributedTitle = mutableAttributedTitle
            }
        }
        
        let buttonCell = button.cell as! NSButtonCell
        buttonCell.bezelStyle = NSButton.BezelStyle.rounded
        
        return button
    }
    
    /// Updates the NSButton with the specified parameters
    public func updateButton(button: NSButton, title: String, size: Int = 18) {
        button.title = title
        if let mutableAttributedTitle = button.attributedTitle.mutableCopy() as? NSMutableAttributedString {
            mutableAttributedTitle.addAttribute(.foregroundColor, value: NSColor.white, range: NSRange(location: 0, length: mutableAttributedTitle.length))
            mutableAttributedTitle.addAttribute(.font, value: NSFont.systemFont(ofSize: CGFloat(size)), range: NSRange(location: 0, length: mutableAttributedTitle.length))
            button.attributedTitle = mutableAttributedTitle
        }
    }
    
    /// Creates a quick NSTextField with the specified parameters
    public func createLabel(title: String, alignment: NSTextAlignment = .center, size: CGFloat, color: NSColor, hidden: Bool = false, bold: Bool = false, x: Double? = nil, y: Double? = nil, width: Double? = nil, height: Double? = nil) -> NSTextField {
        let label = NSTextField()
        label.font = bold ? NSFont.boldSystemFont(ofSize: size) : NSFont.systemFont(ofSize: size)
        label.isHidden = hidden
        label.isBezeled = false
        label.textColor = color
        label.alignment = alignment
        label.isEditable = false
        label.stringValue = title
        label.drawsBackground = false
        
        if let x = x, let y = y {
            if let width = width, let height = height {
                label.frame = CGRect(x: x, y: y, width: width, height: height)
            } else {
                label.sizeToFit()
                label.frame.origin = CGPoint(x: x, y: y)
            }
        } else {
            label.sizeToFit()
        }
        
        return label
    }
}

