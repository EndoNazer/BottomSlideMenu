//
//  File.swift
//  BottomSlideMenu
//
//  Created by Даниил on 24/06/2019.
//  Copyright © 2019 Даниил. All rights reserved.
//

import Foundation
import UIKit

class BottomSlideMenuMediator: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var handleArea: UIView!
    
    enum State {
        case expanded
        case collapsed
    }
    var nextState: State {
        return bottomSlideMenu.visible ? .collapsed : .expanded
    }
    
    var bottomSlideMenu = BottomSlideMenu(currentPosition: .bottom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setupAndAddVisualEffectView(){
        bottomSlideMenu.visualEffectView = UIVisualEffectView()
        bottomSlideMenu.visualEffectView.frame = self.view.frame
        self.view.addSubview(bottomSlideMenu.visualEffectView)
    }
    
    func tuning(){
        bottomSlideMenu.handleAreaHeight = 0.07 * self.view.frame.height
        bottomSlideMenu.height = self.view.frame.height * 0.5
        self.view.frame = CGRect(x: 0, y: self.view.frame.height - bottomSlideMenu.handleAreaHeight, width: self.view.bounds.width, height: bottomSlideMenu.height)
        self.view.clipsToBounds = true
    }
    
    func createAndAddPanRecognizerOnBottomSlideMenuHandleArea(){
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ViewController.handleBottomSlideMenuPan(recognizer:)))
        self.handleArea.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc
    func handleBottomSlideMenuPan (recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            startInteractiveTransition(state: nextState, duration: 0.9)
        case .changed:
            let translation = recognizer.translation(in: self.handleArea)
            var fractionComplete = translation.y / bottomSlideMenu.height
            fractionComplete = bottomSlideMenu.visible ? fractionComplete : -fractionComplete
            updateInteractiveTransition(fractionCompleted: fractionComplete)
        case .ended:
            continueInteractiveTransition()
        default:
            break
        }
    }
    
    func startInteractiveTransition(state: State, duration:TimeInterval) {
        if bottomSlideMenu.launchedAnimations.isEmpty {
            animateTransitionIfNeeded(state: state, duration: duration)
        }
        for animator in bottomSlideMenu.launchedAnimations {
            animator.pauseAnimation()
            bottomSlideMenu.animationProgressWhenInterrupted = animator.fractionComplete
        }
    }
    
    func updateInteractiveTransition(fractionCompleted: CGFloat) {
        for animator in bottomSlideMenu.launchedAnimations {
            animator.fractionComplete = fractionCompleted + bottomSlideMenu.animationProgressWhenInterrupted
        }
    }
    
    func continueInteractiveTransition (){
        for animator in bottomSlideMenu.launchedAnimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
    
    func animateTransitionIfNeeded (state: State, duration: TimeInterval) {
        if bottomSlideMenu.launchedAnimations.isEmpty {
            createAndStartBottomSlideMenuAnimator(state: state, duration: duration)
            createAndStartCornerRadiusAnimator(state: state, duration: duration)
            createAndStartBlurAnimator(state: state, duration: duration)
        }
    }
    
    func createAndStartBottomSlideMenuAnimator(state: State, duration: TimeInterval){
        let bottomSlideMenuAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
            switch state {
            case .expanded:
                self.view.frame.origin.y = self.view.frame.height - self.bottomSlideMenu.height
            case .collapsed:
                self.view.frame.origin.y = self.view.frame.height - self.bottomSlideMenu.handleAreaHeight
            }
        }
        
        bottomSlideMenuAnimator.addCompletion { _ in
            self.bottomSlideMenu.visible = !self.bottomSlideMenu.visible
            self.bottomSlideMenu.launchedAnimations.removeAll()
        }
        
        bottomSlideMenuAnimator.startAnimation()
        bottomSlideMenu.launchedAnimations.append(bottomSlideMenuAnimator)
    }
    
    func createAndStartCornerRadiusAnimator(state: State, duration: TimeInterval){
        let cornerRadiusAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
            switch state {
            case .expanded:
                self.view.layer.cornerRadius = 12
            case .collapsed:
                self.view.layer.cornerRadius = 0
            }
        }
        
        cornerRadiusAnimator.startAnimation()
        bottomSlideMenu.launchedAnimations.append(cornerRadiusAnimator)
    }
    
    func createAndStartBlurAnimator(state: State, duration: TimeInterval){
        let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
            switch state {
            case .expanded:
                self.bottomSlideMenu.visualEffectView.effect = UIBlurEffect(style: .dark)
            case .collapsed:
                self.bottomSlideMenu.visualEffectView.effect = nil
            }
        }
        
        blurAnimator.startAnimation()
        bottomSlideMenu.launchedAnimations.append(blurAnimator)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        if self.searchField.isEditing{
            startInteractiveTransition(state: nextState, duration: 0.9)
        }
        
        createAndAddTapRecognizerOnVisualEffectView()
    }
    
    func createAndAddTapRecognizerOnVisualEffectView(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleBottomSlideMenuTap(recognizer:)))
        bottomSlideMenu.visualEffectView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc
    func handleBottomSlideMenuTap(recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            animateTransitionIfNeeded(state: nextState, duration: 0.9)
        default:
            break
        }
    }
}
