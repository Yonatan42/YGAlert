//
//  ViewController.swift
//  YGAlert
//
//  Created by Yonatan42 on 10/02/2018.
//  Copyright (c) 2018 Yonatan42. All rights reserved.
//

import UIKit
import YGAlert

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        


    }

    @IBAction func btnOpenTapped(_ sender: UIButton) {
        
        let view = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 350, height: 200)))
        view.backgroundColor = .red
        
        //YGAlert.builder.setCloseOnExternalTouch(true).setTitle("Hi there").setMessage("the msg!!!!").setIcon(#imageLiteral(resourceName: "location")).setView(view).create().show()
        
        
        let nibView = TestView.loadViewFromNib()
        
        let alert = YGAlert.builder
//            .setCloseOnTouchOutside(true)
            .setIcon(#imageLiteral(resourceName: "location"), dimension: 50)
            .setTitle("hi there dfgjsnlf dfs fsgfds ghsgfhdg hdfgjhdhj dghjdhg djhjfgh jf", numberOfLines: 1, textAlignment: .left, color: .red)
            .setMessage("this is a relatively long message line. it goes on a little longer", font: UIFont.init(name: UIFont.familyNames[72], size: 13) )
            //            .setView(view)
            .setView(nibView, stretchesInFullScreen: true)
//            .setCornerRadius(10)
//            .setAlertBackgroundColor(UIColor.orange)
//            .setAlertShadowColor(UIColor.purple)
//            .setAlertShadowOpacity(0.3)
            .setCloseButton(#imageLiteral(resourceName: "close_icon"), action: { (_, _) in
                print("close action")
            }, alignment: .right)
//            .setDismissAction({ (_, _) in
//                print("dismiss action")
//            })
            .setButtonsFill(true)
//            .setCenterActionButton("the center dfg dsfgsdfg dfgs  dfgdsf ", action: { (alert, _) in
//                print("center action")
////                alert.close()
//            }, font: UIFont.init(name: UIFont.familyNames[72], size: 13), textColor: .purple, backgroundColor: .cyan)
            .setLeadingActionButton("leading", action: { (_, _) in
                print("leading action")
            })
//            .setTrailingActionButton("trailing", action: { (_, _) in
//                print("trailing action")
//            })
//            .setVerticalElevation(0)
            //            .setButtonsSemanticMode(false)
            .setFullScreen(true, withInsets: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0))
            .create()
        alert.show()
        
        
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        //            alert.close()
        //        }
        
    }
}

