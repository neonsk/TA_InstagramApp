//
//  LoginViewController.swift
//  Instagram
//
//  Created by 高坂将大 on 2018/09/29.
//  Copyright © 2018年 shota.kohsaka. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD

class CommentViewController: UIViewController {
    @IBOutlet weak var commentAllLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var captionLabel: UILabel!
    var commentAll : [String] = []
    var commentCount : Int = 0
    var caption = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelSet()
        
        var sum : String = ""
        for i in 0 ..< commentCount {
            if i != 0{
                sum += "\n\n"
            }
            sum += "\(commentAll[i])"
        }
        print("sum = \(sum)")
        commentAllLabel.text = sum
        captionLabel.text = caption
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func back(_ sender: Any) {
        print("DEBUG_PRINT: Backボタンがタップされました。----------------")
        self.dismiss(animated: true, completion: nil)
        print("commentAll = \(commentAll)")
        print("commentCount = \(commentCount)")
    }
    
    func labelSet(){
        //表示可能最大行数を指定
        captionLabel.numberOfLines = 0
        commentAllLabel.numberOfLines = 0
        //contentsのサイズに合わせてobujectのサイズを変える
        captionLabel.sizeToFit()
        commentAllLabel.sizeToFit()
        
    }
}
