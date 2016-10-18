//
//  MoveableView.swift
//  extandableView-test
//
//  Created by Robin Somlette on 16-Oct-2016.
//  Copyright © 2016 Robin Somlette. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

class MoveableView: UIView {
    
    enum Position {
        case miniMode, notificationMode, fullMode
    }
    enum States {
        case moving, ending, none
    }
    
    private(set) var originalHeight: CGFloat?
    private(set) var currentheight: CGFloat = 0
    
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
    private var minDif: CGFloat {
        return (mediumSize - miniSize) / 2
    }
    private var fullDif: CGFloat {
        return (fullSize - mediumSize) / 2
    }
    private var currentState = BehaviorSubject<States>(value: .none)
    var currentPosition = PublishSubject<Position>()

    let disposeBag = DisposeBag()
    let animationTimer = 0.5
    let animations: UIViewAnimationOptions = [.curveEaseInOut]
    var currentVelocity: CGFloat = 0
    let springDamping: CGFloat = 0.2
    

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
        createUI()
        createConstraint()
        createActions()
    }
    
    func dragged(gestureRecognizer: UIPanGestureRecognizer) {
        let distance = gestureRecognizer.translation(in: self)
        currentVelocity = abs(gestureRecognizer.velocity(in: self).y)
//        print("Distance x:\(distance.x) y:\(distance.y)")
        print("CurrentHeigth: ", currentheight, " OriginalHeight: ", originalHeight, " Velocity: ", currentVelocity)
        
        switch gestureRecognizer.state {
        case .began:
            originalHeight = frame.height
        case .changed:
            self.currentheight = distance.y * -1 + originalHeight!
            currentState.onNext(.moving)
        case .ended:
            currentState.onNext(.ending)
            
        default:
            print("Default triggered Gesture")
        }
    }
    
    func scaleView(position: Position) {
        switch position {
        case .miniMode:
            showminiMode()
        case .notificationMode:
            showNotification()
        case .fullMode:
            showFullScreen()
        }

    }
    
    func showminiMode() {
         animateUI(wantedSize: miniSize, color: .yellow)
    }
    func showNotification() {
         UIView.animate(withDuration: animationTimer, delay: 0, usingSpringWithDamping: springDamping, initialSpringVelocity: currentVelocity, options: animations, animations: {
            print("Notification is Displaying")
            self.snp.updateConstraints({ (make) in
                make.height.equalTo(self.mediumSize)
            })
            self.backgroundColor = .orange
            self.superview?.layoutIfNeeded()
            
            }, completion: { (completed) in
                if completed {
                    print("Notification is gonna go")
                    Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { (timer) in
                        print("Notification leaving", timer)
                        self.currentPosition.onNext(.miniMode)
                    })

                }
        })
    }
    func showFullScreen() {
         animateUI(wantedSize: fullSize, color: .red)
    }
    
    func resetViewPositionAndTransformation() {
       animateUI(wantedSize: miniSize, color: .yellow)
    }
    
    func animateUI(wantedSize: CGFloat, color: UIColor) {
//        UIView.animate(withDuration: animationTimer, delay: 0, usingSpringWithDamping: springDamping, initialSpringVelocity: currentVelocity, options: animations, animations: {
        UIView.animate(withDuration: animationTimer, delay: 0, options: [.curveEaseInOut], animations: {
            self.snp.updateConstraints({ (make) in
                    make.height.equalTo(wantedSize)
            })
            self.backgroundColor = color
            self.superview?.layoutIfNeeded()
            }, completion: nil)
    }
    
    func createUI() {
        // TODO: Add UI Element
    }
    func createConstraint() {
        // TODO: Add Constraints
    }
    func createActions() {
        //On Release, adjust view to key Value
        self.currentPosition.subscribe(onNext: { (position) in
            print(position)

            switch position {
            case .miniMode:
                self.showminiMode()
            case .notificationMode:
                self.showNotification()
            case .fullMode:
                self.showFullScreen()

            }

            
        }).addDisposableTo(disposeBag)
        
        //When moved, change size + Color
        self.currentState.subscribe(onNext: { (state) in
            if self.currentheight <= self.miniSize + 50 {
                self.backgroundColor = .yellow
            } else if (self.mediumSize - 50) <= self.currentheight  && self.currentheight <= (self.mediumSize + 50) {
                self.backgroundColor = .orange
            } else if (self.fullSize - 50) <= self.currentheight {
                self.backgroundColor = .red
            }
            
            switch state {
            case .moving:
                self.snp.updateConstraints({ (make) in
                    make.height.equalTo(self.currentheight)
                })
            case .ending:
                
                if self.currentheight <= self.mediumSize {
                    self.currentPosition.onNext(.miniMode)
//                }
//                else if (self.mediumSize - self.minDif) <= self.currentheight  && self.currentheight <= (self.mediumSize + self.fullDif) {
//                    self.currentPosition.onNext(.notificationMode)
                } else if self.mediumSize < self.currentheight {
                    self.currentPosition.onNext(.fullMode)
                } else {
                    print("RESETING VALUE")
                    self.resetViewPositionAndTransformation()
                }
            default:
                break
            }
            
            }).addDisposableTo(disposeBag)
        
        
        
    }

    
}
