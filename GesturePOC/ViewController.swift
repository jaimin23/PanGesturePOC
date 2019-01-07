//
//  ViewController.swift
//  GesturePOC
//
//  Created by Jaimin Patel on 2018-12-27.
//  Copyright © 2018 Jaimin Patel. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let interactor  = Interactor()
    var modalView: ModalViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.modalView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "modalView") as? ModalViewController
        self.modalView.transitioningDelegate = self
        self.modalView.interactor = interactor
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //self.present(self.modalView, animated: true, completion: nil)
        if let modalViewController = segue.destination as? ModalViewController {
            modalViewController.transitioningDelegate = self
            modalViewController.interactor = interactor
        }
    }
    @IBAction func handleGesture(_ sender: UIPanGestureRecognizer) {
        let percentTreshold:CGFloat = 0.3
        
        let translation = sender.translation(in: view)
        let verticalMovement = translation.y / self.view.bounds.height
        let upwardMovement = fminf(Float(verticalMovement), 0.0)
        let upwardMovementPercent = fminf(Float(upwardMovement), 1.0)
        let progress = CGFloat(upwardMovementPercent)
        switch sender.state{
        case .began:
            interactor.hasStarted = true
            self.present(self.modalView, animated: true, completion: nil)
        
        case .changed:
            interactor.shouldFinish = progress > percentTreshold
            interactor.update(progress)
        
        case .cancelled:
            interactor.hasStarted = false
            interactor.cancel()
            
        case .ended:
            interactor.hasStarted = false
            interactor.shouldFinish ? interactor.finish() : interactor.cancel()
        default:
            break
        }
        
        
        
    }
    

}
extension ViewController: UIViewControllerTransitioningDelegate{
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}

extension UIPanGestureRecognizer{
    enum DirectionOfGesture{
        case Up
        case Down
    }
    
    func verticalDirection(target: UIView) -> DirectionOfGesture{
        return self.velocity(in: target).y > 0 ? .Down : .Up
    }
}
