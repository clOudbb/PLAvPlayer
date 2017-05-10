//
//  PLAVPlayView.swift
//  PLAVPlayer
//
//  Created by 张征鸿 on 2017/5/3.
//  Copyright © 2017年 张征鸿. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
public final class PLAVPlayView: UIView, PLAVPlayControlDelegate {
    
    private var _playUrl : String = ""
    public var playUrl : String {
        set {
            _playUrl = newValue
            self.initPlayer(url: newValue)
        } get {
            return _playUrl
        }
    }
    private var _title : String = ""
    public var title : String {
        set {
            _title = newValue
        }
        get {
            return _title
        }
    }
    
    public fileprivate(set) var avPlayer : AVPlayer?
    fileprivate var avPlayerItem : AVPlayerItem?
    fileprivate var avPlayerLayer : AVPlayerLayer?
    
    public fileprivate(set) var totalDuration : CGFloat = 0
    fileprivate var _status : PLStatus = PLStatus()
    public fileprivate(set) var status : kPLStatus {
        set { _status.status = newValue }
        get { return _status.status }
    }
    fileprivate var timer : DispatchSourceTimer?
    public fileprivate(set) var currentOrientationStatus : kPLScreenStatus = .gerneral
    fileprivate var generalFrame : CGRect?
    
//MARK: -- control
    fileprivate lazy var controlView : PLAVPlayControl = {
        let control = PLAVPlayControl()
        control.delegate = self
        return control
    }()
    fileprivate var topView : PLAVPlayTopControl { get { return self.controlView.topView } }
    fileprivate var bottomView : PLAVPlayBottomControl { get { return self.controlView.bottomView } }
    fileprivate var slider : UISlider { get { return self.controlView.bottomView.slider } }
    fileprivate var playButton : UIButton { get { return self.controlView.playButton } }
    fileprivate var fullButton : UIButton { get { return self.controlView.bottomView.fullButton } }
    public var topViewHeight : Float {
        set { self.controlView.topViewHeight = newValue }
        get { return self.controlView.topViewHeight }
    }
    public var bottomViewHeight : Float {
        set { self.controlView.bottomViewHeight = newValue}
        get { return self.controlView.bottomViewHeight }
    }
    
    //MARK: -- Bool
    public fileprivate(set) var controlShowing = true
    
    static let shareInstance = PLAVPlayView()
    private convenience init () {
        self.init(frame: .zero)
        self.addSubview(controlView)
        self.addTapGestureR()
        self.addNotification()
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        controlView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0))
        }
        DispatchQueue.once(token: "") { () in
            generalFrame = self.frame
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.removeAllObserver()
        NotificationCenter.default.removeObserver(self)
    }
  
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

// MARK: -- init AvPlayer
extension PLAVPlayView
{
    fileprivate
    func initPlayer(url : String) -> Void {
        guard url != "" else {return}
        avPlayerItem = AVPlayerItem.init(url: URL.init(string: url)!)
        avPlayer = AVPlayer.init(playerItem: avPlayerItem)
        avPlayerLayer = AVPlayerLayer.init(player: avPlayer)
        avPlayerLayer?.frame = self.bounds
        avPlayerLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.layer.insertSublayer(avPlayerLayer!, at: 0)
        self.addObserver()
    }
}
//MARK: -- notification
extension PLAVPlayView
{
    fileprivate
    func addNotification() {
        //锁屏状态全屏调用该通知
        NotificationCenter.default.addObserver(self, selector: #selector(handleStatusBarOrientation(_:)), name: .UIApplicationDidChangeStatusBarOrientation, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appEnterBackground), name: .UIApplicationDidEnterBackground, object: nil)
    }
    
    @objc private
    func handleStatusBarOrientation(_ notification : Notification) -> Void {
        let orientation = UIApplication.shared.statusBarOrientation
        guard orientation == .landscapeLeft ||
            orientation == .landscapeRight ||
            orientation == .portrait else { return }
        if orientation == .portrait {
            handleOrientation(.portrait)
        } else {
            handleOrientation(orientation)
        }
    }
    
    fileprivate
    func handleOrientation(_ orientation : UIInterfaceOrientation) {
        guard orientation != .unknown else { return }
        //关键步骤，使用kvc对orientation赋值，避免调用私有api
        UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
        if orientation == .portrait {
            guard (generalFrame != nil) else { return }
            self.snp.remakeConstraints({ (remake) in
                remake.top.equalTo((generalFrame?.origin.y)!)
                remake.left.equalTo((generalFrame?.origin.x)!)
                remake.size.equalTo(CGSize.init(width: (generalFrame?.width)!, height: (generalFrame?.height)!))
            })
            currentOrientationStatus = .gerneral
        } else {
            self.snp.remakeConstraints({ (remake) in
                remake.top.left.right.bottom.equalToSuperview()
            })
            currentOrientationStatus = .full
        }
    }

    @objc private
    func appEnterBackground() {
        guard avPlayer != nil else { return }
        avPlayer?.pause()
    }
}
//MARK: --  observer
extension PLAVPlayView
{
    fileprivate
    func addObserver() -> Void {
        _status.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        self.avPlayer?.currentItem?.addObserver(self, forKeyPath: kPLObserverLoadedTimeRanges, options: .new, context: nil)
        self.avPlayer?.addPeriodicTimeObserver(forInterval: CMTime.init(value: 1, timescale: 1), queue: .global(), using: {[weak self] (cmTime) in
            guard let strongSelf = self else { return }

            let duration = CMTimeGetSeconds((strongSelf.avPlayerItem?.duration)!);
            let current = CMTimeGetSeconds(strongSelf.avPlayerItem!.currentTime());
            let durationT = NSString.init(format: "%02d:%02d", (Int)(duration) / 60, (Int)(duration) % 60)
            let currentT = NSString.init(format: "%02d:%02d", (Int)(current) / 60, (Int)(current) % 60)
            let timeStr = "\(currentT)/\(durationT)"
            
            DispatchQueue.main.async(execute: {
                strongSelf.bottomView.timeLabel.text = timeStr
                
                //总时间
                strongSelf.totalDuration = CGFloat(duration)
                //slider的value
                strongSelf.bottomView.slider.value = Float(current / duration)
                
                if (current == duration) {
                    strongSelf.playOver()
                }
            })
        })
    }
    
    fileprivate
    func playOver() -> Void {
        self.avPlayer?.pause()
        self.avPlayer?.seek(to: CMTime.init(value: 0, timescale: 1))
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard change != nil else { return }
        if keyPath == kPLObserverLoadedTimeRanges {
            let loadedTimeRanges = self.avPlayer?.currentItem?.loadedTimeRanges
            let range = loadedTimeRanges?.first?.timeRangeValue /**< 获取缓冲区域 */
            let start = CMTimeGetSeconds((range?.start)!)
            let duration = CMTimeGetSeconds((range?.duration)!)
            let cacheDuration = start + duration
            let totalDuration = CMTimeGetSeconds((self.avPlayer?.currentItem?.duration)!)
            self.bottomView.cacheProgress.setProgress(Float(cacheDuration / totalDuration), animated: true)
        } else if keyPath == "status" {
            let value : Int = change![.newKey] as! Int
            switch value {
            case kPLStatus.Stop.rawValue: playButton.isSelected = false
                break
            case kPLStatus.Playing.rawValue: playButton.isSelected = true
                break
            case kPLStatus.Pause.rawValue: playButton.isSelected = false
                break
            default:break
            }
        }
    }
    
    fileprivate
    func removeAllObserver() -> Void {
        self.avPlayer?.currentItem?.removeObserver(self, forKeyPath: kPLObserverLoadedTimeRanges, context: nil)
        self.avPlayer?.removeTimeObserver(self)
    }
}
//MARK: -- PLAVPlayControl Delegate
extension PLAVPlayView
{
    public func plPlay() {
        guard (avPlayer != nil) else { return }
        avPlayer?.play()
        status = .Playing
    }
    
    public func plPause() {
        guard (avPlayer != nil) else { return }
        avPlayer?.pause()
        status = .Pause
    }
    
    public func plSlider() {
        guard (avPlayer != nil) else { return }
        let change = Float(totalDuration) * slider.value
        avPlayer?.seek(to: CMTime.init(value: CMTimeValue(change), timescale: 1), completionHandler: {[weak self] (finish) in
            guard let StrongSelf = self else { return }
            StrongSelf.avPlayer?.play()
            StrongSelf.status = .Playing
        })
    }
    
    public func fullScreen(_ button: UIButton) {
        let currentOrientation = UIApplication.shared.statusBarOrientation
        if currentOrientation != .portrait && currentOrientationStatus == .full {
            handleOrientation(.portrait)
        } else {
            handleOrientation(.landscapeRight)
        }
    }
}

//MARK: -- 播放状态
private final class PLStatus: NSObject {
    dynamic var status : kPLStatus = .Stop
}
//MARK: --  Hide Control CountDown
extension PLAVPlayView
{
    fileprivate
    func startCountDown() -> Void {
        stopTimer()
        timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: 0), queue: DispatchQueue.global(qos: .default))
        timer?.scheduleRepeating(deadline: .now() + kPLStartCountDownTime, interval: kPLStartCountDownTime)
        timer?.setEventHandler(handler: {
            weak var weakSelf = self
            DispatchQueue.main.async(execute: {
                guard let strongSelf = weakSelf else { return }
                strongSelf.stopTimer()
                strongSelf.hideControlView()
            })
        })
        timer?.resume()
    }
//MARK: show control
    fileprivate
    func showControlView() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.controlView.alpha = 1
            strongSelf.controlShowing = true
        }
    }
    
    fileprivate
    func hideControlView() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.controlView.alpha = 0
            strongSelf.controlShowing = false
        }
    }
    
    fileprivate
    func stopTimer() -> Void {
        guard (timer != nil) else { return }
        timer?.cancel()
        timer = nil
    }
    
}
//MARK: -- Handle GestureRecognizer
extension PLAVPlayView : UIGestureRecognizerDelegate
{
    fileprivate
    func addTapGestureR() {
        
        let doubleT = UITapGestureRecognizer.init(target: self, action: #selector(doubleTap))
        doubleT.numberOfTapsRequired = 2
        doubleT.delegate = self
        self.addGestureRecognizer(doubleT)
        
        let panPres = UIPanGestureRecognizer.init(target: self, action: #selector(panDir(_:)))
        self.addGestureRecognizer(panPres)
        
        let oneT = UITapGestureRecognizer.init(target: self, action: #selector(oneTap))
        oneT.require(toFail: doubleT)
        oneT.require(toFail: panPres)
        oneT.delegate = self
        self.addGestureRecognizer(oneT)
        

        
//        oneT.delaysTouchesBegan = true
//        doubleT.delaysTouchesBegan = true
        oneT.delaysTouchesEnded = false
        doubleT.delaysTouchesEnded = false
    }
    
    @objc private
    func oneTap() {
        if controlShowing {
            stopTimer()
            hideControlView()
        } else {
            showControlView()
            startCountDown()
        }
    }
    
    @objc private
    func doubleTap() {
        if self.status == .Playing {
            self.plPause()
        } else {
            self.plPlay()
        }
    }
    
    @objc private
    func panDir(_ pan : UIPanGestureRecognizer) {
        let locationX = pan.location(in: self).x
        let transY = fabs(pan.translation(in: self).y)
        //还缺少左右滑动，需先判断方向
        let transX = fabs(pan.translation(in: self).x)
        switch pan.state {
        case .began:
            break
        case .changed:
            guard fabs(transY) != 0 else { return }
            if locationX <= self.width / 2 {
                //-- 控制亮度
                UIScreen.main.brightness -= CGFloat(transY) / CGFloat(10000)
            } else {
                //-- 控制音量
                let volume = MPVolumeView()
                for v in volume.subviews {
                    if v.isKind(of: UISlider.self) {
                        (v as! UISlider).value = Float(transY) / Float(10000)
                        break
                    }
                }
            }
            break
        case .ended:
            break
        default:
            break
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isKind(of: UIButton.self))! ||
        (touch.view?.isKind(of: UISlider.self))! {
            startCountDown()
            return false
        }
        return true
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        stopTimer()
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard controlShowing else { return }
        startCountDown()
    }
}
//MARK: -- gerneral

@discardableResult public
func kPLRGBA(red : Float, green : Float, blue : Float, alpha : Float) -> UIColor {
    return UIColor.init(red: CGFloat(red / 255.0), green: CGFloat(green / 255.0), blue: CGFloat(blue / 255.0), alpha: CGFloat(alpha))
}

public enum kPLScreenStatus {
    case full, gerneral
}
