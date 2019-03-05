//
//  YGAlert.swift
//  Pods-YGAlert_Example
//
//  Created by Yonatan Giventer on 02/10/2018.
//

import UIKit

public class YGAlert: UIView {
    
    public typealias YGAlertAction = ((YGAlert, UIView?)->())
    public typealias YGAlertButton = (title: String, action: YGAlertAction?)
    public enum YGAlertAlignment { case leading, trailing, left, right, center }
    
    // add overflow stratey - scroll or hide
    
    private static let alertWidthPadding: CGFloat = 15
    private static let alertTopPadding: CGFloat = 40
    private var centerYCnst: NSLayoutConstraint?
    private static var centerYinitialValue: CGFloat = -120
    private var alertWidth: CGFloat {
        return UIApplication.shared.keyWindow!.frame.width - 2 * (YGAlert.alertWidthPadding)
    }
    
    private var alertView:UIView? // the whole allert (without the rest of the screen)
    private var frameMetrics:AlertFrameMetrics?
    
    private var ivIcon:UIImageView?
    private var vIconContainer:UIView?
    
    private var lblTtl:UILabel?
    private var vTtlContainer:UIView?
    
    
    private var lblMsg:UILabel?
    private var vMsgContainer:UIView?
    
    private var vContent:UIView? // the view holding any custom view the user may add
    
    
    private var btnLeft:UIButton?
    private var btnRight:UIButton?
    private var btnMid:UIButton?
    private var vBtnContainer:UIView?
    private var btnMetrics: ButtonsMetrics?
    
    
    private var ivCloseBtn:UIImageView?
    
    private var leftAction:YGAlertAction?
    private var rightAction:YGAlertAction?
    private var midAction:YGAlertAction?
    private var closeAction: YGAlertAction?
    private var extraDismissAction:YGAlertAction?
    
    private var backgroundView:UIView!
    private var backgroundOpacity:CGFloat = 0.7
    private var backgroundViewColor:UIColor = .black
    
    
    private var closeOnExternalTouch = false
    
    
    public static let builder = Builder()
    
    private init(){
        let window = UIApplication.shared.keyWindow!
        super.init(frame: window.frame)

//        alertView = UIView()
//        alertView?.backgroundColor = UIColor.white
//        self.addSubview(alertView!)
//        alertView?.translatesAutoresizingMaskIntoConstraints = false
//        centerYCnst = alertView?.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: YGAlert.centerYinitialValue)
//        centerYCnst?.isActive = true
//        alertView?.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: YGAlert.alertWidthPadding).isActive = true
//        alertView?.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -YGAlert.alertWidthPadding).isActive = true
//        alertView?.clipsToBounds = true
        
        alertView = UIView()
        alertView?.backgroundColor = UIColor.white
        self.addSubview(alertView!)
        centerYCnst = alertView?.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0)
        centerYCnst?.isActive = true
        alertView?.clipsToBounds = true
        frameMetrics = AlertFrameMetrics(self)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:)))
        self.addGestureRecognizer(tapRecognizer)
        
        
    }
    
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let min = self.frame.origin.y + YGAlert.alertTopPadding
        if alertView!.frame.origin.y < min {
            centerYCnst?.constant -= (alertView!.frame.origin.y - min)
        }

        
    }
    
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("YGAlert should not be initialiezed using a coder")
    }
    
    public func show(){
        
        
        
        var finalContainerFrame = self.frame;
        let centerInSelf = self.center
        
        finalContainerFrame.origin.x = (centerInSelf.x - finalContainerFrame.width/2.0);
        finalContainerFrame.origin.y = (centerInSelf.y - finalContainerFrame.height/2.0);
        
        self.alpha = 0.0
        
        let window = UIApplication.shared.keyWindow!
        window.addSubview(self)
        
        // set frame before transform here...
        let startFrame: CGRect = finalContainerFrame
        
        self.frame = startFrame
        self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 15.0, options: [], animations: {() -> Void in
            self.alpha = 1.0
            self.transform = CGAffineTransform.identity
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                
                self.backgroundView = UIView.init(frame: self.frame)
                self.backgroundView.backgroundColor = self.backgroundViewColor
                self.backgroundView.alpha = 0
                
                self.addSubview(self.backgroundView)
                self.sendSubview(toBack: self.backgroundView)
                
                UIView.animate(withDuration: 0.5, animations: {
                    self.backgroundView.alpha = self.backgroundOpacity
                })
                
            })
            
        }, completion:{(true) in
            
        })
        
        
        
    }
    
    public func close(){
        
        
        
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {() -> Void in
            self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.backgroundView.alpha = 0
        }, completion: {(_ finished: Bool) -> Void in
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {() -> Void in
                self.alpha = 0.0
                self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }, completion:{(true) in
                
                self.removeFromSuperview()
                
                self.extraDismissAction?(self, nil)
                
                
                
            })
        })
        
        
        
    }
    
    
    @objc func tapGesture(_ sender: UITapGestureRecognizer){
        
        guard let view = self.alertView else {return}
        
        var shouldClose = false
        
        if closeOnExternalTouch {
            // code to make tapping the content view itself not close the alert
            var point = sender.location(in: self)
            point = view.convert(point, from:self)
            if !view.bounds.contains(point) {
                shouldClose = true
            }
            
        }
        
        if ivCloseBtn != nil {
            var point = sender.location(in: self)
            point = ivCloseBtn!.convert(point, from:self)
            if ivCloseBtn!.bounds.contains(point) {
                closeAction?(self, ivCloseBtn)
                shouldClose = true
            }
        }
        
        if shouldClose {
            close()
        }
    }
    
    @objc func btnMidTapped(_ sender: UIButton){
        midAction?(self, sender)
    }
    
    @objc func btnRightTapped(_ sender: UIButton){
        rightAction?(self, sender)
    }
    
    @objc func btnLeftTapped(_ sender: UIButton){
        leftAction?(self, sender)
    }
    
    
    
    private func setUpContainers(){
        guard let alertView = self.alertView else {return}
        
        vIconContainer = UIView()
        vTtlContainer = UIView()
        vMsgContainer = UIView()
        vContent = UIView()
        vBtnContainer = UIView()
        
        let containers = [alertView, vIconContainer, vTtlContainer, vMsgContainer, vContent, vBtnContainer]
        
        for i in 1..<containers.count {
            let container = containers[i]!
            let containerAbove = containers[i-1]!
            alertView.addSubview(container)
            container.translatesAutoresizingMaskIntoConstraints = false
            
            if i == 1 {
                container.topAnchor.constraint(equalTo: alertView.topAnchor).isActive = true
            }
            else{
                container.topAnchor.constraint(equalTo: containerAbove.bottomAnchor).isActive = true
            }
            container.trailingAnchor.constraint(equalTo: alertView.trailingAnchor).isActive = true
            container.leadingAnchor.constraint(equalTo: alertView.leadingAnchor).isActive = true
            let heightCsnt = container.heightAnchor.constraint(equalToConstant: 0)
            heightCsnt.identifier = "height"
            heightCsnt.isActive = true
            
            if i == containers.count {
                container.bottomAnchor.constraint(equalTo: alertView.bottomAnchor).isActive = true
            }
            alertView.bottomAnchor.constraint(greaterThanOrEqualTo: container.bottomAnchor).isActive = true
            
        }
        
        
    }
    
 
    private func setUpCloseButton(image: UIImage?, action: YGAlertAction?, alignment: YGAlertAlignment = .trailing){
        guard let alertView = self.alertView else {return}
        
        if ivCloseBtn == nil {
            ivCloseBtn = UIImageView()
            
            self.addSubview(ivCloseBtn!)
            ivCloseBtn?.translatesAutoresizingMaskIntoConstraints = false
            ivCloseBtn?.heightAnchor.constraint(equalToConstant: 25).isActive = true
            ivCloseBtn?.widthAnchor.constraint(equalTo: ivCloseBtn!.heightAnchor).isActive = true
            
            frameMetrics?.closeBtnAlinment = alignment
            
//            var centerXAnchor:NSLayoutXAxisAnchor!
//            switch alignment {
//            case .leading:
//                centerXAnchor = alertView.leadingAnchor
//            case .trailing:
//                centerXAnchor = alertView.trailingAnchor
//            case .left:
//                centerXAnchor = alertView.leftAnchor
//            case .right:
//                centerXAnchor = alertView.rightAnchor
//            case .center:
//                centerXAnchor = alertView.centerXAnchor
//            }
//            ivCloseBtn?.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
//            ivCloseBtn?.centerYAnchor.constraint(equalTo: alertView.topAnchor).isActive = true
            
            ivCloseBtn?.contentMode = .scaleAspectFit
            
            
        }
        
        ivCloseBtn?.image = image
        closeAction = action
        
        
    }
    
    
    private func generalSubViewSetup(container: UIView?, subView: inout UIView?, heightMargin: CGFloat = 10, widthMargin: CGFloat = -1){
        guard let container = container, let sub = subView else {return}
        
        let heightCsnt = container.constraints.first(where: { (csnt) -> Bool in
            return csnt.identifier == "height"
        })
        //heightCsnt?.constant = 50
        heightCsnt?.isActive = false
        
        container.addSubview(sub)
        sub.translatesAutoresizingMaskIntoConstraints = false
        if widthMargin == -1 {
            sub.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        }
        else{
            sub.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: widthMargin).isActive = true
            sub.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -widthMargin).isActive = true
        }
        
        
        sub.topAnchor.constraint(equalTo: container.topAnchor, constant: heightMargin).isActive = true
        sub.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -heightMargin).isActive = true
        
        
        
    }
    
    
    private func setUpIcon(image: UIImage, dimension: CGFloat? = 30, contentMode: UIViewContentMode? = .scaleAspectFit){
        if ivIcon == nil {
            var icon = UIImageView() as? UIView
            ivIcon = icon as? UIImageView
            
            generalSubViewSetup(container: self.vIconContainer, subView: &icon)
            
            let height = dimension ?? 30
            ivIcon?.heightAnchor.constraint(equalToConstant: height).isActive = true
            ivIcon?.widthAnchor.constraint(equalTo: ivIcon!.heightAnchor).isActive = true
            
            if contentMode != nil {
                ivIcon?.contentMode = .scaleAspectFit
            }
        }
        
        ivIcon?.image = image
        
        
    }
    
    private func setUpTitle(title: NSAttributedString, font: UIFont? = UIFont.boldSystemFont(ofSize: 18), numberOfLines: Int = 0, textAlignment: NSTextAlignment? = nil, color: UIColor? = nil){
        if lblTtl == nil {
            var ttl = UILabel() as? UIView
            lblTtl = ttl as? UILabel
            
            generalSubViewSetup(container: self.vTtlContainer, subView: &ttl, widthMargin: 15)
            
            prepareLabel(lbl: lblTtl, font: font, numberOfLines: numberOfLines, textAlignment: textAlignment, color: color)
        }
        
        lblTtl?.attributedText = title
        
    }
    
    private func setUpMessage(message: NSAttributedString, font: UIFont? = UIFont.systemFont(ofSize: 16), numberOfLines: Int = 0, textAlignment: NSTextAlignment? = nil, color: UIColor? = nil){
        if lblMsg == nil {
            var msg = UILabel() as? UIView
            lblMsg = msg as? UILabel
            
            
            generalSubViewSetup(container: self.vMsgContainer, subView: &msg, widthMargin: 10)
            
            prepareLabel(lbl: lblMsg, font: font, numberOfLines: numberOfLines, textAlignment: textAlignment, color: color)
        }
        
        lblMsg?.attributedText = message
        
    }
    
    private func prepareLabel(lbl: UILabel?, font: UIFont? = nil, numberOfLines: Int = 0, textAlignment: NSTextAlignment? = nil,  color: UIColor? = nil){
        if textAlignment != nil {
            lbl?.textAlignment = textAlignment!
        }
        else{
            lbl?.textAlignment = .center
        }
        lbl?.numberOfLines = numberOfLines
        lbl?.adjustsFontSizeToFitWidth = true
        if font != nil {
            lbl?.font = font
        }
        if color != nil {
            lbl?.textColor = color
        }
    }
    
    private func setUpContentView(view: UIView, stretchesInFullScreen stretch: Bool){
        guard let vContent = self.vContent else {return}
        for subview in vContent.subviews{
            subview.removeFromSuperview()
        }
        
        
        var contentView = Optional(view)
        generalSubViewSetup(container: vContent, subView: &contentView, heightMargin: 0, widthMargin: 0)
        
//        let viewHeight = view.frame.height / (view.frame.width / alertWidth)
//        contentView?.heightAnchor.constraint(equalToConstant: viewHeight).isActive = true
        
        frameMetrics?.contentView = view
        frameMetrics?.stretchContentView = stretch
        
    }
    
    private func setVerticalElevation(_ elevation: CGFloat){
        //centerYCnst?.constant = -elevation
        frameMetrics?.centerYConst = -elevation
    }
    
    private func setFullScreenMode(_ mode: Bool, withInsets insets: UIEdgeInsets?){
        frameMetrics?.isFullScreen = mode
        frameMetrics?.fullScreenInsets = insets
    }
    
    private func setUpButton(type: YGAlertAlignment, title: String? = nil, action: YGAlertAction? = nil, font: UIFont? = UIFont.systemFont(ofSize: 16), textColor: UIColor? = nil, backgroundColor: UIColor? = nil){
        guard let container = vBtnContainer else {return}
        
        let heightCsnt = container.constraints.first(where: { (csnt) -> Bool in
            return csnt.identifier == "height"
        })
        heightCsnt?.isActive = false
        
        initBtnMetrictIfNeeded()
        
        var wasInitialized = true
        var btn: UIButton!
        
        switch type {
        case .leading, .left:
            if btnLeft == nil {
                btnMetrics?.btnCount += 1
                btnLeft = UIButton()
                leftAction = action
                btnLeft?.addTarget(self, action: #selector(btnLeftTapped(_:)), for: .touchUpInside)
                btnMetrics?.hasLeft = true
                wasInitialized = false
            }
            btn = btnLeft
            
        case .trailing, .right:
            if btnRight == nil {
                btnMetrics?.btnCount += 1
                btnRight = UIButton()
                rightAction = action
                btnRight?.addTarget(self, action: #selector(btnRightTapped(_:)), for: .touchUpInside)
                btnMetrics?.hasRight = true
                wasInitialized = false
            }
            btn = btnRight
            
        case .center:
            if btnMid == nil {
                btnMetrics?.btnCount += 1
                btnMid = UIButton()
                midAction = action
                btnMid?.addTarget(self, action: #selector(btnMidTapped(_:)), for: .touchUpInside)
                btnMetrics?.hasMid = true
                wasInitialized = false
            }
            btn = btnMid
        }
        
        
        if !wasInitialized {
            
            container.addSubview(btn)
            btn.translatesAutoresizingMaskIntoConstraints = false
            
            btn.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
            btn.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
            
            
            btn.contentMode = .scaleAspectFit
        }
        
        
        if title != nil {btn.setTitle(title, for: .normal)}
//        if textColor != nil {btn.setTitleColor(textColor, for: .normal)}
        btn.setTitleColor(textColor ?? .darkText, for: .normal)
        if font != nil {btn.titleLabel?.font = font}
        if backgroundColor != nil {btn.backgroundColor = backgroundColor}
        
        
        func hilightBtn(){
            if let c = btn.titleColor(for: .normal), let argb = YGAlert.argb(c) {
                var changeFactor:CGFloat = 1.2 // assume we will make it lighter
                var changeConst: CGFloat = 20
                if Float(argb.r + argb.b + argb.g) * argb.a > (255.0 / 2) { // the color is light so we want to make it sarker
                    changeFactor = 0.8
                    changeConst *= -1
                }
                btn.setTitleColor(UIColor.init(red: (CGFloat(argb.r) * changeFactor + changeConst) / 255.0, green: (CGFloat(argb.g) * changeFactor  + changeConst) / 255.0, blue: (CGFloat(argb.b) * changeFactor  + changeConst) / 255.0, alpha: CGFloat(argb.a)), for: .highlighted)
            }
        }
        
        hilightBtn()
        
    }
    
    private func setBtnFilled(_ shouldFill: Bool){
        initBtnMetrictIfNeeded()
        btnMetrics?.isFilled = shouldFill
    }
    
    private func setBtnSemnatic(_ mode: Bool){
        initBtnMetrictIfNeeded()
        btnMetrics?.isSemantic = mode
    }
    
    private func initBtnMetrictIfNeeded(){
        if btnMetrics == nil {
            btnMetrics = ButtonsMetrics(self)
        }
    }
    
    private class ButtonsMetrics{
        var isSemantic = true
        var isFilled = false
        
        var hasLeft = false
        var hasMid = false
        var hasRight = false
        
        var btnCount = 0
        
        var alert: YGAlert
        
        init(_ alert: YGAlert){
            self.alert = alert
        }
        
        func construct(){
            guard let container = alert.vBtnContainer else { return }
            if btnCount == 0 { return }
            
            let btns = [alert.btnLeft, alert.btnMid, alert.btnRight]
            
            let padding:CGFloat = isFilled ? 0 : 2
            let multiplier: CGFloat = isFilled ? 1 / CGFloat(btnCount) : 1 / 3
            
            
            for btn in btns {
                if btn == nil { continue }
                NSLayoutConstraint(item: btn, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: container, attribute: NSLayoutAttribute.width, multiplier: multiplier, constant: -(padding*2)).isActive = true
            }
            
            if !isFilled || btnCount == 3 {
                alert.btnMid?.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
                if isSemantic {
                    alert.btnLeft?.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: padding).isActive = true
                    alert.btnRight?.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -padding).isActive = true
                }
                else{
                    alert.btnLeft?.leftAnchor.constraint(equalTo: container.leftAnchor, constant: padding).isActive = true
                    alert.btnRight?.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -padding).isActive = true
                }
            }
            else{
                
                switch btnCount {
                case 1:
                    for btn in btns {
                        // this will only ever be activated to one of them
                        btn?.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
                    }
                case 2:
                    if !hasLeft { // then we must have mid and right
                        if isSemantic {
                            alert.btnMid?.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: padding).isActive = true
                            alert.btnRight?.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -padding).isActive = true
                        }
                        else{
                            alert.btnMid?.leftAnchor.constraint(equalTo: container.leftAnchor, constant: padding).isActive = true
                            alert.btnRight?.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -padding).isActive = true
                        }
                    }
                    else if !hasRight{ // have mid and left
                        if isSemantic {
                            alert.btnLeft?.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: padding).isActive = true
                            alert.btnMid?.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -padding).isActive = true
                        }
                        else{
                            alert.btnLeft?.leftAnchor.constraint(equalTo: container.leftAnchor, constant: padding).isActive = true
                            alert.btnMid?.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -padding).isActive = true
                        }
                    }
                    else{ // there is no mid
                        if isSemantic {
                            alert.btnLeft?.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: padding).isActive = true
                            alert.btnRight?.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -padding).isActive = true
                        }
                        else{
                            alert.btnLeft?.leftAnchor.constraint(equalTo: container.leftAnchor, constant: padding).isActive = true
                            alert.btnRight?.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -padding).isActive = true
                        }
                    }
                default:
                    return
                }
            }
            
            
        }
        
    }
    
    private class AlertFrameMetrics{
        var closeBtnAlinment:YGAlertAlignment? = nil
        var isFullScreen = false
        var fullScreenInsets: UIEdgeInsets? = nil
        var centerYConst:CGFloat = YGAlert.centerYinitialValue
        var stretchContentView = false
        var contentView: UIView? = nil
        
        var alert: YGAlert
        
        init(_ alert: YGAlert){
            self.alert = alert
        }
        
        func construct(){
            guard let alertView = alert.alertView else {return}
            
            if !isFullScreen{
                alertView.translatesAutoresizingMaskIntoConstraints = false
                alert.centerYCnst?.constant = centerYConst
                alertView.leadingAnchor.constraint(equalTo: alert.leadingAnchor, constant: YGAlert.alertWidthPadding).isActive = true
                alertView.trailingAnchor.constraint(equalTo: alert.trailingAnchor, constant: -YGAlert.alertWidthPadding).isActive = true
                
                if let alignment = closeBtnAlinment{
                    var centerXAnchor:NSLayoutXAxisAnchor
                    switch alignment {
                    case .leading:
                        centerXAnchor = alertView.leadingAnchor
                    case .trailing:
                        centerXAnchor = alertView.trailingAnchor
                    case .left:
                        centerXAnchor = alertView.leftAnchor
                    case .right:
                        centerXAnchor = alertView.rightAnchor
                    case .center:
                        centerXAnchor = alertView.centerXAnchor
                    }
                    alert.ivCloseBtn?.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
                    alert.ivCloseBtn?.centerYAnchor.constraint(equalTo: alertView.topAnchor).isActive = true
                }
            }
            else{
                alertView.translatesAutoresizingMaskIntoConstraints = true
                alert.centerYCnst?.isActive = false
                let insets = fullScreenInsets ?? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                alertView.frame = UIScreen.main.bounds -/ insets

                
                if let alignment = closeBtnAlinment{
                    switch alignment {
                    case .leading:
                        alert.ivCloseBtn?.leadingAnchor.constraint(equalTo: alertView.leadingAnchor).isActive = true
                    case .trailing:
                        alert.ivCloseBtn?.trailingAnchor.constraint(equalTo: alertView.trailingAnchor).isActive = true
                    case .left:
                        alert.ivCloseBtn?.leftAnchor.constraint(equalTo: alertView.leftAnchor).isActive = true
                    case .right:
                        alert.ivCloseBtn?.rightAnchor.constraint(equalTo: alertView.rightAnchor).isActive = true
                    case .center:
                        alert.ivCloseBtn?.centerXAnchor.constraint(equalTo: alertView.centerXAnchor).isActive = true
                    }
                    alert.ivCloseBtn?.topAnchor.constraint(equalTo: alertView.topAnchor).isActive = true
                }
            }
            
            if let view = self.contentView {
                
                if !isFullScreen || !stretchContentView {
                    let viewHeight = view.frame.height / (view.frame.width / alert.alertWidth)
                    contentView?.heightAnchor.constraint(equalToConstant: viewHeight).isActive = true
                }
                else{ /* no need to constraint the height, this will be done by the other constraints already*/}
            }
            
        }
        
    }
    
    
    
    
    public class Builder{
        
        private var alert:YGAlert
        
        init(){
            alert = YGAlert()
            alert.setUpContainers()
        }
        
        public func create()->YGAlert{
            self.alert.frameMetrics?.construct()
            self.alert.btnMetrics?.construct()
            if self.alert.frameMetrics?.isFullScreen == true {
                self.alert.backgroundOpacity = 0
            }
            return self.alert
        }
        
        public func setCloseOnTouchOutside(_ shouldClose: Bool)->YGAlert.Builder{
            self.alert.closeOnExternalTouch = shouldClose
            return self
        }
        
        public func setIcon(_ icon: UIImage?, dimension: CGFloat? = 30, contentMode: UIViewContentMode? = .scaleAspectFit)->YGAlert.Builder{
            if let icon = icon {
                self.alert.setUpIcon(image: icon, dimension: dimension, contentMode: contentMode)
            }
            return self
        }
        
        public func setTitle(_ title: String?, font: UIFont? = nil, numberOfLines: Int = 0, textAlignment: NSTextAlignment? = nil, color: UIColor? = nil)->YGAlert.Builder{
            guard let title = title else{ return self }
            return setTitle(NSAttributedString(string: title), font: font, numberOfLines: numberOfLines, textAlignment: textAlignment, color: color)
        }
        
        public func setTitle(_ title: NSAttributedString?, font: UIFont? = nil, numberOfLines: Int = 0, textAlignment: NSTextAlignment? = nil, color: UIColor? = nil)->YGAlert.Builder{
            if let title = title {
                self.alert.setUpTitle(title: title, font: font, numberOfLines: numberOfLines, textAlignment: textAlignment, color: color)
            }
            return self
        }
        
        public func setMessage(_ message: String?, font: UIFont? = nil, numberOfLines: Int = 0, textAlignment: NSTextAlignment? = nil, color: UIColor? = nil)->YGAlert.Builder{
            guard let message = message else{ return self }
            return setMessage(NSAttributedString(string: message), font: font, numberOfLines: numberOfLines, textAlignment: textAlignment, color: color)
        }
        
        public func setMessage(_ message: NSAttributedString?, font: UIFont? = nil, numberOfLines: Int = 0, textAlignment: NSTextAlignment? = nil, color: UIColor? = nil)->YGAlert.Builder{
            if let message = message {
                self.alert.setUpMessage(message: message, font: font, numberOfLines: numberOfLines, textAlignment: textAlignment, color: color)
            }
            return self
        }
        
        public func setView(_ view: UIView?, stretchesInFullScreen stretch: Bool = false)->YGAlert.Builder{
            if let view = view {
                self.alert.setUpContentView(view: view, stretchesInFullScreen: stretch)
            }
            return self
        }
        
        public func setCornerRadius(_ radius: CGFloat?)->YGAlert.Builder{
            if let radius = radius {
                self.alert.alertView?.layer.cornerRadius = radius
            }
            return self
        }
        
        public func setAlertBackgroundColor(_ color: UIColor?)->YGAlert.Builder{
            if let color = color {
                self.alert.alertView?.backgroundColor = color
            }
            return self
        }
        
        public func setAlertShadowColor(_ color: UIColor?)->YGAlert.Builder{
            if let color = color {
                self.alert.backgroundViewColor = color
            }
            return self
        }
        
        public func setAlertShadowOpacity(_ opacity: CGFloat?)->YGAlert.Builder{
            if let opacity = opacity {
                self.alert.backgroundOpacity = opacity
            }
            return self
        }
        
        public func setCloseButton(_ image: UIImage?, action: YGAlertAction? = nil, alignment: YGAlertAlignment = .trailing)->YGAlert.Builder{
            if let image = image {
                self.alert.setUpCloseButton(image: image, action: action, alignment: alignment)
            }
            return self
        }
        
        public func setDismissAction(_ action: YGAlertAction?)->YGAlert.Builder{
            self.alert.extraDismissAction = action
            return self
        }
        
        
        public func setCenterActionButton(_ title: String?, action: YGAlertAction? = nil, font: UIFont? = nil, textColor: UIColor? = nil, backgroundColor: UIColor? = nil)->YGAlert.Builder{
            self.alert.setUpButton(type: .center, title: title, action: action, font: font, textColor: textColor, backgroundColor: backgroundColor)
            return self
        }
        
        public func setLeadingActionButton(_ title: String?, action: YGAlertAction? = nil, font: UIFont? = nil, textColor: UIColor? = nil, backgroundColor: UIColor? = nil)->YGAlert.Builder{
            self.alert.setUpButton(type: .leading, title: title, action: action, font: font, textColor: textColor, backgroundColor: backgroundColor)
            return self
        }
        
        public func setTrailingActionButton(_ title: String?, action: YGAlertAction? = nil, font: UIFont? = nil, textColor: UIColor? = nil, backgroundColor: UIColor? = nil)->YGAlert.Builder{
            self.alert.setUpButton(type: .trailing, title: title, action: action, font: font, textColor: textColor, backgroundColor: backgroundColor)
            return self
        }
        
        public func setButtonsFill(_ shouldFill: Bool)->YGAlert.Builder{
            self.alert.setBtnFilled(shouldFill)
            return self
        }
        
        public func setButtonsSemanticMode(_ mode: Bool)->YGAlert.Builder{
            self.alert.setBtnSemnatic(mode)
            return self
        }
        
        public func setVerticalElevation(_ elevation: CGFloat)->YGAlert.Builder{
            self.alert.setVerticalElevation(elevation)
            return self
        }
        
        public func setFullScreen(_ mode: Bool, withInsets insets: UIEdgeInsets? = nil)->YGAlert.Builder{
            self.alert.setFullScreenMode(mode, withInsets: insets)
            return self
        }
        
        
    }
    
    
    
    
    
    
    
    
    private static func argb(_ color:UIColor) -> (r:Int,g:Int,b:Int,a:Float)? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if color.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = Int(fRed * 255.0)
            let iGreen = Int(fGreen * 255.0)
            let iBlue = Int(fBlue * 255.0)
            let iAlpha = Int(fAlpha * 255.0)
            
            //            //  (Bits 24-31 are alpha, 16-23 are red, 8-15 are green, 0-7 are blue).
            //            let rgb = (iAlpha << 24) + (iRed << 16) + (iGreen << 8) + iBlue
            return (r:iRed,g:iGreen,b:iBlue,a:Float(fAlpha))
        } else {
            // Could not extract RGBA components:
            return nil
        }
    }
    
    
}

infix operator -/ : AdditionPrecedence
func -/ (lhs: CGRect?, rhs: UIEdgeInsets?) -> CGRect?{
    guard let lhs = lhs, let rhs = rhs else {return nil}
    return CGRect(x: lhs.origin.x + rhs.left, y: lhs.origin.y + rhs.top, width: lhs.size.width - (rhs.left + rhs.right), height: lhs.size.height - (rhs.top + rhs.bottom))
}
func -/ (lhs: CGRect, rhs: UIEdgeInsets) -> CGRect{
    return (lhs -/ rhs)!
}
