//
//  PLAVPlayControl.swift
//  PLAVPlayer
//
//  Created by 张征鸿 on 2017/5/5.
//  Copyright © 2017年 张征鸿. All rights reserved.
//

import UIKit

public final class PLAVPlayControl: UIView, PLBottomControlDelegate{
    
    public weak var delegate : PLAVPlayControlDelegate?
    public lazy var topView : PLAVPlayTopControl = { return PLAVPlayTopControl() }()
    public lazy var bottomView : PLAVPlayBottomControl = { return PLAVPlayBottomControl() }()
    public lazy var playButton : UIButton = {
        let button = UIButton.init(type: .custom)
        button.setImage(plImage(imageStyle: .play), for: .normal)
        button.setImage(plImage(imageStyle: .pause), for: .selected)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 4
        button.layer.borderColor = UIColor.orange.cgColor
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(play), for: .touchUpInside)
        return button
    }()
    
    public var topViewHeight : Float = 50
    public var bottomViewHeight : Float = 30
    
    public
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.topView)
        self.addSubview(self.bottomView)
        bottomView.delegate = self
        self.addSubview(self.playButton)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.topView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            make.height.equalTo(topViewHeight)
        }
        
        self.bottomView.snp.makeConstraints { (make) in
            make.bottom.left.right.equalTo(0)
            make.height.equalTo(bottomViewHeight)
        }
        
        self.playButton.snp.makeConstraints { (make) in
            make.right.equalTo(-5)
            make.bottom.equalTo(self.bottomView.snp.top).offset(-5)
            make.size.equalTo(CGSize.init(width: 35, height: 35))
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

extension PLAVPlayControl
{
    @objc fileprivate
    func play() -> Void {
        if playButton.isSelected {
            if (self.delegate?.responds(to: NSSelectorFromString("plPause")))! {
                self.delegate?.plPause()
            }
        } else {
            if (self.delegate?.responds(to: NSSelectorFromString("plPlay")))! {
                self.delegate?.plPlay()
            }
        }
//MARK: -- 监听了button，在kvo中统一管理button状态 所以暂时不在这里改变button状态
//        self.playButton.isSelected = !self.playButton.isSelected
    }
}
//MARK: -- Bottom Control Delegate
extension PLAVPlayControl
{
    public
    func plSliderChange() {
        if (self.delegate?.responds(to: NSSelectorFromString("plSlider")))! {
            self.delegate?.plSlider()
        }
    }
    
    public
    func fullScreen(_ button: UIButton) {
        guard (self.delegate?.responds(to: NSSelectorFromString("fullScreen:")))! else { return }
        self.delegate?.fullScreen(button)
    }
}
