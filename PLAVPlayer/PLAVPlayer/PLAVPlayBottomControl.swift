//
//  PLAVPlayBottomControl.swift
//  PLAVPlayer
//
//  Created by 张征鸿 on 2017/5/3.
//  Copyright © 2017年 张征鸿. All rights reserved.
//

import UIKit

public final class PLAVPlayBottomControl: UIView {

    public weak var delegate : PLBottomControlDelegate?
    public lazy var slider : UISlider = {
        let sli = UISlider()
        sli.value = 0
        sli.maximumTrackTintColor = UIColor.clear
        sli.setThumbImage(plImage(imageStyle: .progressDot), for: .normal)
        sli.addTarget(self, action: #selector(sliderValueChange), for: .valueChanged)
        return sli
    }()
    public lazy var cacheProgress : UIProgressView = {
        let cache = UIProgressView.init(progressViewStyle: .default)
        cache.trackTintColor = UIColor.darkGray
        cache.progressTintColor = UIColor.lightGray
        return cache
    }()
    public lazy var timeLabel : UILabel = {
        let label = UILabel()
        label.text = "00:00/00:00"
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    public lazy var fullButton : UIButton = {
        let button = UIButton.init(type: .custom)
        button.setImage(plImage(imageStyle: .fullBtn), for: .normal)
        button.setImage(plImage(imageStyle: .shrinkBtn), for: .selected)
        button.addTarget(self, action: #selector(fullScreen(_:)), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = kPLRGBA(red: 0, green: 0, blue: 0, alpha: 0.7)
        self.addSubview(slider)
        self.addSubview(cacheProgress)
        self.insertSubview(cacheProgress, belowSubview: slider)
        self.addSubview(timeLabel)
        self.addSubview(fullButton)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        timeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(5)
            make.width.equalTo(85)
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        fullButton.snp.remakeConstraints{ (make) in
            make.right.equalTo(-5)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize.init(width: self.heigth, height: self.heigth))
        }
        
        slider.snp.makeConstraints { (make) in
            make.left.equalTo(timeLabel.snp.right).offset(5)
            make.right.equalTo(fullButton.snp.left).offset(-5)
            make.centerY.height.equalToSuperview()
        }
        
        cacheProgress.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(1)
            make.height.equalTo(2)
            make.left.equalTo(slider.snp.left).offset(1)
            make.right.equalTo(slider.snp.right).offset(-1)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

extension PLAVPlayBottomControl
{
    @objc fileprivate
    func sliderValueChange() -> Void {
        guard (self.delegate?.responds(to: NSSelectorFromString("plSliderChange")))! else { return }
        self.delegate?.plSliderChange()
    }
    
    @objc fileprivate
    func fullScreen(_ button : UIButton) -> Void {
        guard (self.delegate?.responds(to: NSSelectorFromString("fullScreen:")))! else { return }
        self.delegate?.fullScreen(button)
        fullButton.isSelected = !fullButton.isSelected
    }
}
