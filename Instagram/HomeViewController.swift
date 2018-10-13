//
//  HomeViewController.swift
//  Instagram
//
//  Created by 高坂将大 on 2018/09/29.
//  Copyright © 2018年 shota.kohsaka. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var postArray: [PostData] = []
    
    // DatabaseのobserveEventの登録状態を表す
    var observing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setTableView()
    
        //Database中身確認
        print("Database.database().reference().child(Const.PostPath) = \(Database.database().reference().child(Const.PostPath))")
    }
    override func viewWillAppear(_ animated: Bool) {
        SVProgressHUD.show(withStatus: "読み込み中")
        self.tableView.reloadData()
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        
        if Auth.auth().currentUser != nil {
            if self.observing == false {
                // 要素が追加されたらpostArrayに追加してTableViewを再表示する
                let postsRef = Database.database().reference().child(Const.PostPath)
                postsRef.observe(.childAdded, with: { snapshot in
                    print("DEBUG_PRINT: .childAddedイベントが発生しました。")
                    // PostDataクラスを生成して受け取ったデータを設定する
                    if let uid = Auth.auth().currentUser?.uid {
                        let postData = PostData(snapshot: snapshot, myId: uid)
                        self.postArray.insert(postData, at: 0)
                        
                        // TableViewを再表示する
                        self.tableView.reloadData()
                    }
                })
                // 要素が変更されたら該当のデータをpostArrayから一度削除した後に新しいデータを追加してTableViewを再表示する
                postsRef.observe(.childChanged, with: { snapshot in
                    print("DEBUG_PRINT: .childChangedイベントが発生しました。")
                    
                    if let uid = Auth.auth().currentUser?.uid {
                        // PostDataクラスを生成して受け取ったデータを設定する
                        let postData = PostData(snapshot: snapshot, myId: uid)
                        
                        // 保持している配列からidが同じものを探す
                        var index: Int = 0
                        for post in self.postArray {
                            if post.id == postData.id {
                                index = self.postArray.index(of: post)!
                                break
                            }
                        }
                        
                        // 差し替えるため一度削除する
                        self.postArray.remove(at: index)
                        
                        // 削除したところに更新済みのデータを追加する
                        self.postArray.insert(postData, at: index)
                        // TableViewを再表示する
                        self.tableView.reloadData()
                    }
                })
                
                // DatabaseのobserveEventが上記コードにより登録されたため
                // trueとする
                
                observing = true
            }
        } else {
            if observing == true {
                // ログアウトを検出したら、一旦テーブルをクリアしてオブザーバーを削除する。
                // テーブルをクリアする
                postArray = []
                tableView.reloadData()
                // オブザーバーを削除する
                Database.database().reference().removeAllObservers()
                
                // DatabaseのobserveEventが上記コードにより解除されたため
                // falseとする
                observing = false
            }
        }
        SVProgressHUD.dismiss()
    }
    
    func setTableView (){
        tableView.delegate = self
        tableView.dataSource = self
        
        // テーブルセルのタップを無効にする
        tableView.allowsSelection = false
        
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        // テーブル行の高さをAutoLayoutで自動調整する
        tableView.rowHeight = UITableViewAutomaticDimension
        // テーブル行の高さの概算値を設定しておく
        // 高さ概算値 = 「縦横比1:1のUIImageViewの高さ(=画面幅)」+「いいねボタン、キャプションラベル、その他余白の高さの合計概算(=100pt)」
        tableView.estimatedRowHeight = UIScreen.main.bounds.width + 100
    }
    
    // セル内のボタンがタップされた時に呼ばれるメソッド(コメント投稿)
    @objc func commentsPostButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: 投稿ボタンがタップされました。-----------------")
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        let cell = tableView.cellForRow(at: indexPath!) as! PostTableViewCell
        cell.setPostData(postArray[indexPath!.row])

        let comments = cell.commentsTextField.text!
        print("cell.caption.text = \(cell.captionLabel.text!)")
        print("cell.commentsTextField.text = \(cell.commentsTextField.text!)")
        
        // コメント名が入力されていない時はHUDを出して何もしない
        if comments.isEmpty {
            SVProgressHUD.showError(withStatus: "コメントを入力して下さい")
            return
        }
        //コメント投稿者のユーザー名とコメント内容を取得
        let user = Auth.auth().currentUser
        let postData = postArray[indexPath!.row]
        if let user = user{
            let postRef = Database.database().reference().child(Const.PostPath).child(postData.id!)
            let commentCount = postData.comments.count
            let commentValue = "\(user.displayName!) : \(comments)"
            //Firebaseにコメント内容を保存
            let inputComment = ["\(commentCount)" : "\(commentValue)"]
            postRef.child("comments").updateChildValues(inputComment)
        }
        SVProgressHUD.showSuccess(withStatus: "コメントを投稿しました")
        cell.commentsTextField.text = ""
    }
    
    // セル内のボタンがタップされた時に呼ばれるメソッド(Likeプッシュ)
    @objc func handleButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。----------------")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        print(postData)
        
        // Firebaseに保存するデータの準備
        if let uid = Auth.auth().currentUser?.uid {
            if postData.isLiked {
                // すでにいいねをしていた場合はいいねを解除するためIDを取り除く
                var index = -1
                for likeId in postData.likes {
                    if likeId == uid {
                        // 削除するためにインデックスを保持しておく
                        index = postData.likes.index(of: likeId)!
                        break
                    }
                }
                postData.likes.remove(at: index)
            } else {
                postData.likes.append(uid)
            }
            
            // 増えたlikesをFirebaseに保存する
            let postRef = Database.database().reference().child(Const.PostPath).child(postData.id!)
            print("Database.database().reference().child(Const.PostPath).child(postData.id!) = \(Database.database().reference().child(Const.PostPath).child(postData.id!))")
            let likes = ["likes": postData.likes]
            postRef.updateChildValues(likes)
            
        }
    }
    // セル内のボタンがタップされた時に呼ばれるメソッド(CommentAllDisplayプッシュ)
    @objc func goCommentAll(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: CommetAllボタンがタップされました。----------------")
        let storyboard: UIStoryboard = self.storyboard!
        let commentViewController = storyboard.instantiateViewController(withIdentifier: "Comment") as! CommentViewController
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        let postData = postArray[indexPath!.row]
        
        commentViewController.commentAll = postData.comments
        commentViewController.commentCount = postData.comments.count
        let nameText = "\(postData.name!)"
        let captionText = "\(postData.caption!)"
        commentViewController.caption = "\(nameText) : \(captionText)"
        
        self.present(commentViewController, animated: true, completion: nil)
        
    }
}

extension HomeViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        cell.setPostData(postArray[indexPath.row])
        
        // セル内のボタンのアクションをソースコードで設定する
        cell.likeButton.addTarget(self, action:#selector(handleButton(_:forEvent:)), for: .touchUpInside)
        cell.commentsPostButton.addTarget(self, action:#selector(commentsPostButton(_:forEvent:)), for: .touchUpInside)
        cell.commentAllDisplay.addTarget(self, action:#selector(goCommentAll(_:forEvent:)), for: .touchUpInside)
        return cell
    }
}
