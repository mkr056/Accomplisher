//
//  ProgressViewController.swift
//  Accomplisher
//
//  Created by Artem Mkr on 15.08.2022.
//

import UIKit

class ProgressViewController: UIViewController {
    
    var selectedGoal: Goal?
    var percentage: Double = 0.0
    
    var percentageLabel: UILabel!
    var shapeLayer: CAShapeLayer!
    var pulsatingLayer: CAShapeLayer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupNotificationObservers()
        view.backgroundColor = UIColor(red: 21 / 225, green: 22 / 225, blue: 33 / 225, alpha: 1)
        
        
        percentageLabel = UILabel()
        percentageLabel.numberOfLines = 0
        percentageLabel.textColor = .white
        percentageLabel.textAlignment = .center
        percentageLabel.font = UIFont.boldSystemFont(ofSize: 22)
        
        
        
        
        if let goal = selectedGoal {
            if goal.percentComplete >= 100 || goal.percentComplete == -1 {
                percentage = 1
            } else {
                percentage = Double(goal.percentComplete) / 100
            }
            percentageLabel.text = "\(Int(percentage * 100))% complete"
        } else {
            fatalError("Selected Goal not found")
        }
        
    
        setupCircleLayers()
        animateCircleShapeLayer(shapeLayer)
        setupPercentageLabel()
        
    }
    func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    func setupCircleLayers() {
        
        pulsatingLayer = createCircleShapeLayer(strokeColor: .clear, fillColor: UIColor(red: 86 / 225, green: 30 / 225, blue: 63 / 225, alpha: 1))
        view.layer.addSublayer(pulsatingLayer)
        animatePulsatingLayer()
        
        let trackLayer = createCircleShapeLayer(strokeColor: UIColor(red: 56 / 225, green: 25 / 225, blue: 49 / 225, alpha: 1), fillColor: UIColor(red: 21 / 225, green: 22 / 225, blue: 33 / 225, alpha: 1))
        view.layer.addSublayer(trackLayer)
        
        shapeLayer = createCircleShapeLayer(strokeColor: UIColor(red: 234 / 225, green: 46 / 225, blue: 111 / 225, alpha: 1), fillColor: .clear)
        shapeLayer.transform = CATransform3DMakeRotation(-.pi / 2, 0, 0, 1)
        shapeLayer.strokeEnd = 0
        view.layer.addSublayer(shapeLayer)
    }
    

    func animateCircleShapeLayer(_ shapeLayer: CAShapeLayer) {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.toValue = percentage
        basicAnimation.duration = 1.5
        basicAnimation.fillMode = .forwards
        basicAnimation.isRemovedOnCompletion = false
        shapeLayer.add(basicAnimation, forKey: "urSoBasic")
    }
    
    func setupPercentageLabel() {
        view.addSubview(percentageLabel)
        percentageLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        percentageLabel.center = view.center
    }
    
    
    func createCircleShapeLayer(strokeColor: UIColor, fillColor: UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 100, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        layer.path = circularPath.cgPath
        layer.strokeColor = strokeColor.cgColor
        layer.lineWidth = 20
        layer.fillColor = fillColor.cgColor
        layer.lineCap = .round
        layer.position = view.center
        return layer
    }
   
    
    func animatePulsatingLayer() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = 1.5
        animation.duration = 0.5
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        pulsatingLayer.add(animation, forKey: "pulsing")
    }
    
    
    
    @objc func handleEnterForeground() {
        animatePulsatingLayer()
    }
    
    
    
    
}

