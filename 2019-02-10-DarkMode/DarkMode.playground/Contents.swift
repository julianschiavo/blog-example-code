//: ## **A playground demonstrating the use of observers to implement dark mode across an iOS app.**
//: ### [https://schiavo.me/2019/implementing-dark-mode/](https://schiavo.me/2019/implementing-dark-mode/)
//: Copyright (c) 2019 Julian Schiavo. All rights reserved. Licensed under the MIT License.
//:
//: Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//:
//: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//:
//: THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
import UIKit
import PlaygroundSupport

// Useful extension to `CaseIterable` to allow easily toggling of a 2 case enum
// Credit: Paul Hudson https://twitter.com/twostraws/status/1092229498601422848
extension CaseIterable where Self: Equatable {
    mutating func toggle() {
        self = Self.allCases.first(where: { $0 != self }) ?? self
    }
}

enum Theme: CaseIterable {
    case light
    case dark
    
    // If the current theme is changed, we notify all observers about it
    static var current: Theme = .light {
        didSet {
            Observation.themeDidChange(to: current)
        }
    }
}

class DemoViewController: UIViewController, AppearanceObserver {
    
    let button = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register ourselves as an AppearanceObserver so we get notified when the theme changes
        Observation.addObserver(self)
        
        // Set the view controller theme to the current theme
        themeDidChange(to: Theme.current)
        
        // Add a simple button to quickly change themes (in a real app, this could be more advanced, and use a `UISwitch`)
        button.frame = CGRect(x: 0, y: 300, width: 384, height: 20)
        button.setTitle("Switch Theme", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(switchTheme), for: .touchUpInside)
        
        view.addSubview(button)
    }
    
    // Toggles the current theme between light and dark
    @objc func switchTheme() {
        Theme.current.toggle()
    }
    
    // Updates colors based on the new theme
    func themeDidChange(to theme: Theme) {
        // Animate the transition to make it look better
        // To make the animation quicker or slower, just change the duration in seconds
        UIView.animate(withDuration: 0.6) {
            switch Theme.current {
            case .light:
                self.button.setTitleColor(.blue, for: .normal)
                self.view.backgroundColor = .groupTableViewBackground
            case .dark:
                self.button.setTitleColor(.orange, for: .normal)
                self.view.backgroundColor = .black
            }
        }
    }
}

struct Observation {
    weak var observer: AppearanceObserver?
    static var observations = [ObjectIdentifier: Observation]()
    
    // Adds an observer
    static func addObserver(_ observer: AppearanceObserver) {
        let id = ObjectIdentifier(observer)
        Observation.observations[id] = Observation(observer: observer)
    }
    
    // Removes an observer
    static func removeObserver(_ observer: AppearanceObserver) {
        let id = ObjectIdentifier(observer)
        Observation.observations.removeValue(forKey: id)
    }
    
    // Tells each observer that the theme changed
    // (If an observer is no longer available, we remove it from the list)
    static func themeDidChange(to theme: Theme) {
        for (id, observation) in Observation.observations {
            guard let observer = observation.observer else {
                Observation.observations.removeValue(forKey: id)
                continue
            }
            
            observer.themeDidChange(to: theme)
        }
    }
}

// Lightweight protocol classes such as view controllers can implement to handle theme changes
protocol AppearanceObserver: class {
    func themeDidChange(to theme: Theme)
}

// Present the demo view controller in the Assistant Editor
PlaygroundPage.current.liveView = DemoViewController()
