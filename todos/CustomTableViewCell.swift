//
//  CustomTableViewCell.swift
//  todos
//
//  Created by keisuke on 2018/10/28.
//  Copyright (c) 2018年 Keisuke Ito. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet var checkImage: UIImageView!
    @IBOutlet var label: UILabel!
    
    var check = false
    
    var viewType: String = "All"
    var todoTableView: UITableView!
    var indexItem = 0  // todoItemのインデックス

    let checkOn:UIImage = UIImage(named:"checkOn.jpg")!
    let checkOff:UIImage = UIImage(named:"checkOff.jpg")!
    
    /* カスタムセルをセット */
    func setCellData(viewType: String, tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath){

        // 引数を保持（tapCheckImageでビュー更新に利用）
        todoTableView = tableView
        
        /* Check有無によりセル表示内容を制御 */
        indexItem = indexPath.row

        // todoItemDBのCheckを取得
        indexItem = (indexPath.row)
        var indexDB = findIndex(indexItem)
        check = NSString(string: todoItemDB[indexDB][1]).boolValue
    }
    
    /* CheckアイコンのGestureを設定 */
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("tapCheckImage:"))
        tapGesture.delegate = self;
        checkImage.addGestureRecognizer(tapGesture)
    }
    
    /* Checkアイコンのタップ時 */
    func tapCheckImage(sender: UITapGestureRecognizer) {
         
        // todoItemDBのインデックスを取得
        var indexDB = findIndex(indexItem)
        
        // todoItemDBのCheckを取得
        check = NSString(string: todoItemDB[indexDB][1]).boolValue
        
        // todoItemDBのCheckを更新
        if !check {
            todoItemDB[indexDB][1] = "true"
        }
        else{
            todoItemDB[indexDB][1] = "false"
        }
        check = !check

        // タップ直後にビュー更新が必要: tableView() ⇒ setCellData()
        reloadType = 2
        todoTableView.reloadData()
    }
}
