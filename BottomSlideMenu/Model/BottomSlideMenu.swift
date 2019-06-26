//
//  BottomSlideMenu.swift
//  BottomSlideMenu
//
//  Created by Даниил on 26/06/2019.
//  Copyright © 2019 Даниил. All rights reserved.
//

import Foundation
import UIKit

class BottomSlideMenu{
    
    enum PositionOnScreen: CGFloat{
        case top = 1
        case middle = 0.5
        case bottom = 0.07
    }
    
    public var currentPosition: PositionOnScreen
    
    
    enum State {
        case expanded
        case collapsed
    }
    
    var visible = false
    var nextState: State {
        return bottomSlideMenuVisible ? .collapsed : .expanded
    }
    
    var visualEffectView: UIVisualEffectView!
    
    var height: CGFloat = 0
    var handleAreaHeight: CGFloat = 0
    
    var launchedAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted: CGFloat = 0
    
    init(currentPosition: PositionOnScreen) {
        self.currentPosition = currentPosition
    }
    
    public func changePosition(newPosition: PositionOnScreen){
        switch newPosition {
        case .top:
            self.currentPosition = .top
        case .middle:
            self.currentPosition = .middle
        case .bottom:
            self.currentPosition = .bottom
        }
    }
}
