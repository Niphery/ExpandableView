//
//  MoveableView.swift
//  extandableView-test
//
//  Created by Robin Somlette on 16-Oct-2016.
//  Copyright © 2016 Robin Somlette. All rights reserved.
//

import UIKit
import SnapKit

class MoveableView: UIView {
    
    enum Direction {
        case none, top, bottom
    }
    
    enum Position {
        case minimazed, medium, fullSized
    }
    
    private(set) var originalHeight: CGFloat?
    private(set) var originalPoint: CGPoint?
    
    private(set) var currentPosition: Position?
    private(set) var currentheight: CGFloat?
    
    private var miniSize: CGFloat {
        if let sup = superview {
            return sup.frame.height / 4
        } else {
            return 150
        }
    }
    private var mediumSize: CGFloat {
        if let sup = superview {
            return sup.frame.height / 2.2
        } else {
            return 300
        }
    }
    private var fullSize: CGFloat {
        if let sup = superview {
            return sup.frame.height / 1.5
        } else {
            return 450
        }
    }

    init() {
        super.init(frame: CGRect.zero)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initView() {
        backgroundColor = .yellow
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(dragged)))
    }
    
    func dragged(gestureRecognizer: UIPanGestureRecognizer) {
        
        let distance = gestureRecognizer.translation(in: self)
//        print("Distance x:\(distance.x) y:\(distance.y)")
        print("CurrentHeigth: ", currentheight, " Original Height: ", originalHeight)
        
        switch gestureRecognizer.state {
        case .began:
            self.originalHeight = frame.height
        case .changed:
                currentheight = distance.y * -1 + originalHeight!
                
                if currentheight! <= miniSize + 50 {
                    backgroundColor = .yellow
                } else if (mediumSize - 50) <= currentheight!  && currentheight! <= (mediumSize + 50) {
                    backgroundColor = .orange
                } else if (fullSize - 50) <= currentheight! {
                    backgroundColor = .red
                }
                
                
                self.snp.updateConstraints({ (make) in
                    make.height.equalTo(currentheight!)
                })
        case .ended:
            if currentheight! <= miniSize + 50 {
                scaleView(position: .minimazed)
            } else if (mediumSize - 50) <= currentheight!  && currentheight! <= (mediumSize + 50) {
                scaleView(position: .medium)
            } else if (fullSize - 50) <= currentheight! {
                scaleView(position: .fullSized)
            } else {
                print("RESETING VALUE")
                resetViewPositionAndTransformation()
            }
            
        default:
            print("Default triggered Gesture")
        }
    }
    
    func scaleView(position: Position) {
        let animations: UIViewAnimationOptions = [.curveEaseInOut]
        switch position {
        case .minimazed:
            UIView.animate(withDuration: 5, delay: 0, options: animations, animations: {
                    self.snp.updateConstraints({ (make) in
                        make.height.equalTo(self.miniSize)
                    })
                }, completion: nil)
        case .medium:
            UIView.animate(withDuration: 5, delay: 0, options: animations, animations: {

                    self.snp.updateConstraints({ (make) in
                        make.height.equalTo(self.mediumSize)
                    })

                }, completion: nil)
        case .fullSized:
            UIView.animate(withDuration: 5, delay: 0, options: animations, animations: {

                    self.snp.updateConstraints({ (make) in
                        make.height.equalTo(self.fullSize)
                    })

                }, completion: nil)
        }

    }

    
    func resetViewPositionAndTransformation() {
        UIView.animate(withDuration: 5, delay: 0, options: [.curveEaseInOut], animations: {
                self.snp.updateConstraints({ (make) in
                    make.height.equalTo(self.miniSize)
                })
            }, completion: nil)
    }
    
    func createUI() {
        
    }
    func createConstraint() {
        
    }

    
}
