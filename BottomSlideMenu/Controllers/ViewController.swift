//
//  ViewController.swift
//  BottomSlideMenu
//
//  Created by Даниил on 24/06/2019.
//  Copyright © 2019 Даниил. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    enum BottomSlideMenuState {
        case expanded
        case collapsed
    }
    
    var bottomSlideMenuVisible = false
    var nextState: BottomSlideMenuState {
        return bottomSlideMenuVisible ? .collapsed : .expanded
    }
    
    var bottomSlideMenu = BottomSlideMenu(currentPosition: .bottom)
    var bottomSlideMenuViewController: BottomSlideMenuMediator!
    var visualEffectView: UIVisualEffectView!
    
    var bottomSlideMenuHeight: CGFloat = 0
    var bottomSlideMenuHandleAreaHeight: CGFloat = 0
    
    var launchedAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBottomSlideMenu()
    }
    
    func setupBottomSlideMenu(){
        setupAndAddVisualEffectView()
        createAndAddBottomSlideMenuViewController()
        tuningBottomSlideMenuViewController()
        createAndAddPanRecognizerOnBottomSlideMenuHandleArea()
    }
    
    func setupAndAddVisualEffectView(){
        visualEffectView = UIVisualEffectView()
        visualEffectView.frame = self.view.frame
        self.view.addSubview(visualEffectView)
    }
    
    func createAndAddBottomSlideMenuViewController(){
        bottomSlideMenuViewController = BottomSlideMenuMediator(nibName:"BottomSlideMenuViewController", bundle:nil)
        bottomSlideMenuViewController.bottomSlideMenu = bottomSlideMenu
        self.addChild(bottomSlideMenuViewController)
        self.view.addSubview(bottomSlideMenuViewController.view)
    }
    
    func tuningBottomSlideMenuViewController(){
        bottomSlideMenuHandleAreaHeight = 0.07 * self.view.frame.height
        bottomSlideMenuHeight = self.view.frame.height * 0.5
        bottomSlideMenuViewController.view.frame = CGRect(x: 0, y: self.view.frame.height - bottomSlideMenuHandleAreaHeight, width: self.view.bounds.width, height: bottomSlideMenuHeight)
        bottomSlideMenuViewController.view.clipsToBounds = true
    }
    
    func createAndAddPanRecognizerOnBottomSlideMenuHandleArea(){
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ViewController.handleBottomSlideMenuPan(recognizer:)))
        bottomSlideMenuViewController.handleArea.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc
    func handleBottomSlideMenuPan (recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            startInteractiveTransition(state: nextState, duration: 0.9)
        case .changed:
            let translation = recognizer.translation(in: self.bottomSlideMenuViewController.handleArea)
            var fractionComplete = translation.y / bottomSlideMenuHeight
            fractionComplete = bottomSlideMenuVisible ? fractionComplete : -fractionComplete
            updateInteractiveTransition(fractionCompleted: fractionComplete)
        case .ended:
            continueInteractiveTransition()
        default:
            break
        }
    }
    
    func startInteractiveTransition(state: BottomSlideMenuState, duration:TimeInterval) {
        if launchedAnimations.isEmpty {
            animateTransitionIfNeeded(state: state, duration: duration)
        }
        for animator in launchedAnimations {
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }
    
    func updateInteractiveTransition(fractionCompleted: CGFloat) {
        for animator in launchedAnimations {
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }
    
    func continueInteractiveTransition (){
        for animator in launchedAnimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
    
    func animateTransitionIfNeeded (state: BottomSlideMenuState, duration: TimeInterval) {
        if launchedAnimations.isEmpty {
            createAndStartBottomSlideMenuAnimator(state: state, duration: duration)
            createAndStartCornerRadiusAnimator(state: state, duration: duration)
            createAndStartBlurAnimator(state: state, duration: duration)
        }
    }
    
    func createAndStartBottomSlideMenuAnimator(state: BottomSlideMenuState, duration: TimeInterval){
        let bottomSlideMenuAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
            switch state {
            case .expanded:
                self.bottomSlideMenuViewController.view.frame.origin.y = self.view.frame.height - self.bottomSlideMenuHeight
            case .collapsed:
                self.bottomSlideMenuViewController.view.frame.origin.y = self.view.frame.height - self.bottomSlideMenuHandleAreaHeight
            }
        }
        
        bottomSlideMenuAnimator.addCompletion { _ in
            self.bottomSlideMenuVisible = !self.bottomSlideMenuVisible
            self.launchedAnimations.removeAll()
        }
        
        bottomSlideMenuAnimator.startAnimation()
        launchedAnimations.append(bottomSlideMenuAnimator)
    }
    
    func createAndStartCornerRadiusAnimator(state: BottomSlideMenuState, duration: TimeInterval){
        let cornerRadiusAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
            switch state {
            case .expanded:
                self.bottomSlideMenuViewController.view.layer.cornerRadius = 12
            case .collapsed:
                self.bottomSlideMenuViewController.view.layer.cornerRadius = 0
            }
        }
        
        cornerRadiusAnimator.startAnimation()
        launchedAnimations.append(cornerRadiusAnimator)
    }
    
    func createAndStartBlurAnimator(state: BottomSlideMenuState, duration: TimeInterval){
        let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
            switch state {
            case .expanded:
                self.visualEffectView.effect = UIBlurEffect(style: .dark)
            case .collapsed:
                self.visualEffectView.effect = nil
            }
        }
        
        blurAnimator.startAnimation()
        launchedAnimations.append(blurAnimator)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        if bottomSlideMenuViewController.searchField.isEditing{
            startInteractiveTransition(state: nextState, duration: 0.9)
        }
        
        createAndAddTapRecognizerOnVisualEffectView()
    }
    func createAndAddTapRecognizerOnVisualEffectView(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleBottomSlideMenuTap(recognizer:)))
        self.visualEffectView.addGestureRecognizer(tapGestureRecognizer)
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
