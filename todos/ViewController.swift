//
//  ViewController.swift
//  todos
//
//  Created by keisuke on 2018/10/28.
//  Copyright (c) 2018年 Keisuke Ito. All rights reserved.
//

import UIKit

/* セルのhidden=trueではtabeleViewでセルが空行表示され、
   空行を詰めることができなかったため、やむ得ず表示用配列を使用 */
var todoItem = [String]()      // 表示用
var todoItemDB = [[String]]()  // 全データ [ラベル値, Check, todoItemインデックス]
var reloadType = 0             // 0:初期値, 1:UITextField改行時, 2:ボタン・Checkアイコンタップ時

/* 今後、カスタムセル配列を用いたよりシンプルな実装の可能性有り */
//var customCellArry = [CustomTableViewCell]()  // カスタムセル配列


/* todoItemのインデックスからtodoItemDBのインデックスを取得 */
func findIndex(index: Int) -> Int {
    var i = 0
    var subArray = [String]()
    
    for i = 0; i < todoItemDB.count; i++ {
        subArray = todoItemDB[i]
        if subArray[2].toInt()==index {
            break
        }
    }
    return i
}

/* セル削除前にtodoItemDBのtodoItemインデックスを更新 */
func updateIndexItem(index: Int) { // indexは削除セルのインデックス
    var i = 0
    var j = 0
    var subArray = [String]()
    var updateCount = 0
    
    if index < todoItem.count-1 {
        for i = index+1; i < todoItem.count; i++ {
            for j = 0; j < todoItemDB.count; j++ {
                subArray = todoItemDB[j]
            
                if subArray[2].toInt()==i {
                    todoItemDB[j][2] = (index + updateCount).description
                    updateCount += 1
                }
            }
        }
    }
}

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    /* view切り替え用 */
    var viewType: String = "All"
    
    /* todosアプリ画面 */
    @IBOutlet var itemText: UITextField!
    @IBOutlet var itemsLeft: UILabel!
    @IBOutlet var tableView: UITableView!
    //↓使用しないがランタイムエラーが発生するため残す
    @IBOutlet var todoTableView: UITableView!
    
    @IBOutlet var allButtonStyle: UIButton!
    @IBOutlet var activeButtonStyle: UIButton!
    @IBOutlet var completedButtonStyle: UIButton!
    @IBOutlet var clearButtonStyle: UIButton!
    
    @IBAction func checkAll(sender: AnyObject) {

        var tmpViewType = viewType
        viewType = "All"
        reloadType = 2
        tableView.reloadData()
        
        var i = 0
        var allChecked = true
        
        for i = 0; i < todoItemDB.count; i++ {
            if todoItemDB[i][1]=="false" {
                todoItemDB[i][1] = "true"
                allChecked = false
            }
        }
        
        // ボタン押下前にすべてチェックされている場合、
        // すべてのチェックを外す
        if allChecked {
            for i = 0; i < todoItemDB.count; i++ {
                todoItemDB[i][1] = "false"
            }
        }

        switch tmpViewType {
        case "All":
            allButton(sender)
        case "Active":
            activeButton(sender)
        case "Completed":
            completedButton(sender)
        default:
            allButton(sender)
        }
    }
    
    @IBAction func allButton(sender: AnyObject) {
        viewType = "All"
        allButtonStyle.titleLabel!.font = UIFont(name: "Helvetica-Bold",size: CGFloat(18))
        activeButtonStyle.titleLabel!.font = UIFont(name: "Helvetica",size: CGFloat(14))
        completedButtonStyle.titleLabel!.font = UIFont(name: "Helvetica",size: CGFloat(12))
        reloadType = 2
        tableView(tableView, numberOfRowsInSection: 0)
        tableView.reloadData()
    }
    @IBAction func activeButton(sender: AnyObject) {
        viewType = "Active"
        allButtonStyle.titleLabel!.font = UIFont(name: "Helvetica",size: CGFloat(14))
        activeButtonStyle.titleLabel!.font = UIFont(name: "Helvetica-Bold",size: CGFloat(18))
        completedButtonStyle.titleLabel!.font = UIFont(name: "Helvetica",size: CGFloat(12))
        reloadType = 2
        tableView(tableView, numberOfRowsInSection: 0)
        tableView.reloadData()
    }
    @IBAction func completedButton(sender: AnyObject) {
        viewType = "Completed"
        allButtonStyle.titleLabel!.font = UIFont(name: "Helvetica",size: CGFloat(14))
        activeButtonStyle.titleLabel!.font = UIFont(name: "Helvetica",size: CGFloat(14))
        completedButtonStyle.titleLabel!.font = UIFont(name: "Helvetica-Bold",size: CGFloat(16))
        reloadType = 2
        tableView(tableView, numberOfRowsInSection: 0)
        tableView.reloadData()
    }
    @IBAction func clearButton(sender: AnyObject) {
 
        var tmpViewType = viewType
        viewType = "All"
        reloadType = 2
        tableView.reloadData()
        
        var i = 0
        var j = i
        var subArray = [String]()
    
        // check有りのアイテムを１つずつupdateIndexItem⇒削除していく
        for i = 0; i < todoItemDB.count; i++ {
            subArray = todoItemDB[i]
            if subArray[1]=="true" {
                updateIndexItem(i)
                todoItem.removeAtIndex(subArray[2].toInt()!)
                todoItemDB.removeAtIndex(i)
                
                // 再帰呼び出し
                clearButton(sender)
            }
        }
        
        switch tmpViewType {
        case "All":
            allButton(sender)
        case "Active":
            activeButton(sender)
        case "Completed":
            completedButton(sender)
        default:
            allButton(sender)
        }
        buttonsHidden()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buttonsHidden()
        
        /* UITextField設定 */
        itemText.delegate = self
        itemText.placeholder = "What needs to be done?"
        itemText.font = UIFont.italicSystemFontOfSize(UIFont.labelFontSize())
        itemText.backgroundColor = UIColor(white: 0.98, alpha: 1)
        // 左の余白設定
        itemText.leftViewMode = UITextFieldViewMode.Always
        itemText.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        // テキスト全消去ボタン表示
        itemText.clearButtonMode = UITextFieldViewMode.Always
        // 改行ボタン種類変更
        itemText.returnKeyType = UIReturnKeyType.Done
        
        /* カスタムセル設定 */
        tableView.registerNib(UINib(nibName: "CustomTableViewCell", bundle: nil),forCellReuseIdentifier:"reuseCell")
    }
    
    /* アイテム数0の時、ボタン等非表示 */
    func buttonsHidden() {
        if todoItemDB.count == 0 {
            tableView.hidden = true
            itemsLeft.hidden = true
            allButtonStyle.hidden = true
            activeButtonStyle.hidden = true
            completedButtonStyle.hidden = true
            clearButtonStyle.hidden = true
        }else{
            tableView.hidden = false
            itemsLeft.hidden = false
            allButtonStyle.hidden = false
            activeButtonStyle.hidden = false
            completedButtonStyle.hidden = false
            clearButtonStyle.hidden = false
        }
    }
    
    /* UITextField改行時 */
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        
        // キーボードを隠す
        itemText.resignFirstResponder()
        
        // UITextFieldの値を保持
        todoItemDB.append([itemText.text!, "false", (todoItem.count.description)])
        
        switch viewType {
        case "All":
            todoItem.append(itemText.text!)
        case "Active":
            todoItem.append(itemText.text!)
        case "Completed":
            break
        default:
            todoItem.append(itemText.text!)
        }
        
        reloadType = 1
        itemText.text = ""
        NSUserDefaults.standardUserDefaults().setObject(todoItem, forKey: "todoList")
        tableView.reloadData()
        buttonsHidden()
        return true
    }
    
    /* セルのアイテム表示 */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // セルのアイテム数表示
        var i = 0
        var itemCount = 0
        
        for i = 0; i < todoItemDB.count; i++ {
            if todoItemDB[i][1]=="false" {
                itemCount += 1
            }
        }
        itemsLeft.text = itemCount.description + " items left"
        
        // 表示するセルのtodoItemを生成: todoItemDB[ラベル値, Check有無, todoItemインデックス]
        i = 0
        var subArray = [String]()
        var label = ""
        var check = false
        
        if (reloadType == 0) || (reloadType == 1) {  // 0:初期値, 1:UITextField改行時
            return todoItem.count
        }
        
        todoItem = []
        var indexItem = 0  // todoItemのインデックス
        
        for i = 0; i < todoItemDB.count; i++ {
            subArray = todoItemDB[i]
            label = todoItemDB[i][0]
            check = NSString(string: todoItemDB[i][1]).boolValue  // Check有無
        
            switch viewType {
            case "All":
                todoItem.append(label)
                todoItemDB[i][2] = indexItem.description
                indexItem += 1
            case "Active":
                if check {
                    todoItemDB[i][2] = ""
                } else {
                    todoItem.append(label)
                    todoItemDB[i][2] = indexItem.description
                    indexItem += 1
                }
            case "Completed":
                if check {
                    todoItem.append(label)
                    todoItemDB[i][2] = indexItem.description
                    indexItem += 1
                } else {
                    todoItemDB[i][2] = ""
                }
            default:
                break
            }
        }
        reloadType = 0
        return todoItem.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellValue = tableView.dequeueReusableCellWithIdentifier("reuseCell", forIndexPath: indexPath) as CustomTableViewCell
        
        // カスタムセルをセット
        cellValue.setCellData(viewType, tableView: tableView, cellForRowAtIndexPath: indexPath)
        
        // 引数を保持（tapCheckImageでビュー更新に利用）
        todoTableView = tableView
        
//        // カスタムセルを配列に格納
//        if todoItem.count==indexPath.row+1 {
//            customCellArry.append(cellValue)
//        }
        
        /* ラベル設定は、カスタムセルクラスではなく、ここでをしないと
           取り消し線等、ラベル表示がおかしくなる                 */
        cellValue.label.text = todoItem[indexPath.row]
        
         // 取消し線の準備
        let strLabel = cellValue.label.text!
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: strLabel)
        
        switch viewType {
        case "All":
            if cellValue.check {
                cellValue.checkImage.image = UIImage(named: "checkOn.jpg")
                // 取消し線を引く
                attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 1, range: NSMakeRange(0, attributeString.length))
                cellValue.label.textColor = UIColor.lightGrayColor()
                cellValue.label.attributedText = attributeString
            } else {
                cellValue.checkImage.image = UIImage(named: "checkOff.jpg")
                cellValue.label.textColor = UIColor.blackColor()
            }
        case "Active":
            if cellValue.check {
            } else {
                println("Active-!check")
                cellValue.checkImage.image = UIImage(named: "checkOff.jpg")
                cellValue.label.textColor = UIColor.blackColor()
            }
        case "Completed":
            if cellValue.check {
                println("Completed-check")
                cellValue.checkImage.image = UIImage(named: "checkOn.jpg")
                // 取消し線を引く
                attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 1, range: NSMakeRange(0, attributeString.length))
                cellValue.label.textColor = UIColor.lightGrayColor()
                cellValue.label.attributedText = attributeString
            } else {
            }
        default:
            break
        }
        
        return cellValue
    }
    
    /* スライプ時の削除 */
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath){
        
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            // todoItemDBのtodoItemインデックスを更新
            updateIndexItem(indexPath.row)
            
            // todoItemDBのインデックスを取得
            var indexDB = findIndex(indexPath.row)
            
            todoItem.removeAtIndex(indexPath.row)
            todoItemDB.removeAtIndex(indexDB)
            NSUserDefaults.standardUserDefaults().setObject(todoItem, forKey: "todoList")
        }
        reloadType = 1
        NSUserDefaults.standardUserDefaults().setObject(todoItem, forKey: "todoList")
        tableView.reloadData()
    }
    
    /* スライプ時の削除ボタンを"x"に変更 */
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {

        return "×"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

