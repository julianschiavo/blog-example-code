//
//  IntentHandler.swift
//  IntentsExtension
//
//  Created by Julian Schiavo on 8/9/2019.
//  Copyright © 2019 Julian Schiavo. All rights reserved.
//

import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
}
