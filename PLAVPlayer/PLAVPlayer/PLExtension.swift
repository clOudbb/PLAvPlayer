//
//  PLExtension.swift
//  PLAVPlayer
//
//  Created by 张征鸿 on 2017/5/3.
//  Copyright © 2017年 张征鸿. All rights reserved.
//

import Foundation
import SnapKit
import ObjectiveC

public let kPLScreenWidth = UIScreen.main.bounds.size.width
public let kPLScreenHeight = UIScreen.main.bounds.size.height
public let kPLObserverLoadedTimeRanges = "loadedTimeRanges"
public let kPLStartCountDownTime : DispatchTimeInterval = DispatchTimeInterval.seconds(3)

@objc public enum kPLStatus : Int
{
    case Stop = 0, Playing, Pause
}

public enum kPLImage : String {
    case play = "toolbar_play_h"
    case pause = "toolbar_pause_h"
    case backBtn = "btn_back_n"
    case progressDot = "playProcessDot_n"
    case clarityBtn = "toolbar_playinglist_h_p"
    case fullBtn = "videoplayer_expand"
    case shrinkBtn = "videoplayer_shrink"
}
//MARK: -- Set plImage function
@discardableResult public
func plImage(imageStyle : kPLImage) -> UIImage? {
    return UIImage.init(named: imageStyle.rawValue)
}
//MARK: -- UIView Extension
public extension UIView
{
    var width : CGFloat {
        return self.frame.size.width
    }
    
    var heigth : CGFloat {
        return self.frame.size.height
    }
}
//MARK: -- Dispatch_Once Extension
public extension DispatchQueue {
    
    private static var _onceTracker = [String]()
    
    public class func once(token: String, block:(Void)->Void) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        
        if _onceTracker.contains(token) {
            return
        }
        
        _onceTracker.append(token)
        block()
    }
}

//MARK: -- Control Delegate
@objc public
protocol PLAVPlayControlDelegate : class, NSObjectProtocol{
    func plPlay() -> Void
    func plPause() -> Void
    func plSlider() -> Void
    func fullScreen(_ button : UIButton) -> Void
}

@objc public
protocol PLBottomControlDelegate : class, NSObjectProtocol {
    func plSliderChange() -> Void
    func fullScreen(_ button : UIButton) -> Void
}

