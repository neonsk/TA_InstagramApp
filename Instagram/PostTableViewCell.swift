//
//  PostTableViewCell.swift
//  Instagram
//
//  Created by 高坂将大 on 2018/09/30.
//  Copyright © 2018年 shota.kohsaka. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import SVProgressHUD

class PostTableViewCell: UITableViewCell,UITextFieldDelegate {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var commentsTextField: UITextField!
    @IBOutlet weak var commentsPostButton: UIButton!
    @IBOutlet weak var commentsAllText: UILabel!
    @IBOutlet weak var commentAllDisplay: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commentsTextField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    func setPostData(_ postData: PostData) {
        
        //コメント欄のDoneとCancel表示
        let toolbar = UIToolbar(frame: CGRectMake(0, 0, 0, 35))
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action:#selector(PostTableViewCell.done))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action:#selector(PostTableViewCell.cancel))
        toolbar.setItems([cancelItem, doneItem], animated: true)
        
        self.commentsTextField.inputAccessoryView = toolbar

        self.postImageView.image = postData.image
        
        let nameText = "\(postData.name!)"
        let captionText = "\(postData.caption!)"
        self.nameLabel.text = nameText
        self.captionLabel.text = "\(nameText) : \(captionText)"
        captionLabel.numberOfLines = 0
        captionLabel.sizeToFit()
        
        let likeNumber = postData.likes.count
        likeLabel.text = "「いいね！」\(likeNumber)件"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString = formatter.string(from: postData.date!)
        self.dateLabel.text = dateString
        
        //Databaseに格納されているcommentsをcommentsAllに格納
        var commentsAll : String = ""
        if postData.comments.count != 0{
            commentsAll = "\(postData.comments[0])"
        }
        //print("commentsAll = \(commentsAll)")
        self.commentsAllText.text = commentsAll
        commentAllDisplay.setTitle("コメント\(postData.comments.count)件すべてを表示", for: .normal)
        
        //コメントが複数の場合はcommentAllDsiplayを表示
        if postData.comments.count < 2 {
            commentAllDisplay.isHidden = true
        }else{
            commentAllDisplay.isHidden = false
        }
        
        //Likeの処理
        if postData.isLiked {
            let buttonImage = UIImage(named: "like_exist")
            self.likeButton.setImage(buttonImage, for: .normal)
        } else {
            let buttonImage = UIImage(named: "like_none")
            self.likeButton.setImage(buttonImage, for: .normal)
        }
    }
    @IBAction func goCommentViewController(_ sender: Any) {
        /*let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let commentViewController = storyboard.instantiateViewController(withIdentifier: "Comment")
        self.present(commentViewController,animated: true, completion: nil)
        commentAllDisplay.setView(commentViewController, at: 0)*/
    }
    
    @objc func cancel() {
        self.commentsTextField.text = ""
        self.commentsTextField.endEditing(true)
    }
    
    @objc func done() {
        self.commentsTextField.endEditing(true)
    }
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
}
