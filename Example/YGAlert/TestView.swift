//
//  TestView.swift
//  YGAlert_Example
//
//  Created by Yonatan Giventer on 04/03/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

class TestView : UIView{
    
    
    @IBOutlet weak var lbl:UILabel!
     @IBOutlet weak var segment:UISegmentedControl!
     @IBOutlet weak var btn:UIButton!
    
    
    static func loadViewFromNib() -> TestView? {
        let bundle = Bundle.main
        let nib = UINib(nibName: "TestView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as? TestView
        
        return view
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl){
        print("segment changed to \(sender.selectedSegmentIndex)")
    }
    
    @IBAction func btnTapped(_ sender: UIButton){
        print("btn tapped")
    }
    
    
    
}
