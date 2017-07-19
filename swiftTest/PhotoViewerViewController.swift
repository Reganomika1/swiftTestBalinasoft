//
//  PhotoViewerViewController.swift
//  swiftTest
//
//  Created by Zakhar on 7/19/17.
//  Copyright © 2017 BalinaSoft. All rights reserved.
//

import UIKit
import CoreData
import SDWebImage

class PhotoViewerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var imageView: UIImageView!    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var objectImageEntity: Item!
    var page: Int = 0
    
    var comments = [Comment]()
    
    let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
    var context : NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 60
        
        tableView.tableFooterView = UIView()
        
        self.imageView.sd_setImage(with: URL(string: objectImageEntity.imageUrl!))
        
        context = appDelegate.persistentContainer.viewContext
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Comment")
            let sort = NSSortDescriptor(key: "date", ascending: false)
            request.sortDescriptors = [sort]
            
            let result = try  context.fetch(request)
            comments = result as! [Comment]
        } catch {}
        
        let date = Date(timeIntervalSince1970: TimeInterval(objectImageEntity.date))
        let fomatter = DateFormatter()
        fomatter.dateFormat = "dd.MM.yyyy"
        self.dateLabel.text = fomatter.string(from: date)
        
        loadCommentsFromPage(page: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Number of rows in section table view
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    //MARK: - Cell for row at indexPath
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! CommentTableViewCell
        let objectCommentEntity = self.objectImageEntity.comment?.allObjects[indexPath.row] as! Comment
        
        cell.commentTextLabel.text = objectCommentEntity.text
        let date = Date(timeIntervalSince1970: TimeInterval(objectCommentEntity.date))
        let fomatter = DateFormatter()
        fomatter.dateFormat = "dd.MM HH:mm"
        cell.commentDateLabel.text = fomatter.string(from: date)
        
        return cell
    }
    
    //MARK: - Height for row at indexPath
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
        
    }
    
    //MARK: - Pagination comments
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
//        if (comments.count - indexPath.row - 3) == 0 {
//            
//            self.page += 1
//            
//            loadCommentsFromPage(page: self.page)
//        }
    }
    
    //MARK: - Load comments from server
    
    func loadCommentsFromPage(page: Int) {
        ServerManager.shared.getComments(page: page, imageId: Int(objectImageEntity.itemId), complition: { success, response, error in
            if success == true {
                let commentsArray = response?["data"].arrayValue
                
                
                label: for comment in commentsArray! {
                    
                    let massCommentsFromImage = self.objectImageEntity.comment?.allObjects as! [Comment]
                    for object in massCommentsFromImage {
                        if object.commentId == comment["id"].int32! {
                            continue label
                        }
                    }
                    let commentItem = Comment(context : self.context)
                    commentItem.text = comment["text"].stringValue
                    commentItem.date = comment["date"].int32Value
                    commentItem.commentId = Int32(comment["id"].intValue)
                    commentItem.item = self.objectImageEntity
                    self.appDelegate.saveContext()
                }
                do {
                    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Comment")
                    let sort = NSSortDescriptor(key: "date", ascending: false)
                    request.sortDescriptors = [sort]
                    
                    let result = try  self.context.fetch(request)
                    self.comments = result as! [Comment]
                } catch {}
            }
            
            self.tableView.reloadData()
        })
    }
    
    //MARK: - Close keyboard when user tap to screen
    
    func closeKeyboard() {
        view.endEditing(true)
    }
    
    func tableView(_: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Удалить") { (UITableViewRowAction, NSIndexPath) -> Void in
            let objectCommentEntity = self.objectImageEntity.comment?.allObjects[indexPath.row] as! Comment
            
            let alert = UIAlertController(title: "", message: "Do you want to delete this comment?", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { action in
                
                ServerManager.shared.removeComment(commentId: Int(objectCommentEntity.commentId), imageId:  Int(self.objectImageEntity.itemId), complition:{ success, response, error in
                    if success == true {
                        self.context.delete(objectCommentEntity)
                        self.appDelegate.saveContext()
                        do {
                            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Comment")
                            let sort = NSSortDescriptor(key: "date", ascending: false)
                            request.sortDescriptors = [sort]
                            
                            let result = try  self.context.fetch(request)
                            self.comments = result as! [Comment]
                        } catch {}
                        self.tableView.deleteRows(at: [indexPath as IndexPath], with: .fade)
                    }
                })
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        deleteAction.backgroundColor = UIColor.red
        return [deleteAction]
    }
    
    
    //MARK: - Actions
    
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        ServerManager.shared.postComment(imageId: Int(objectImageEntity.itemId), text: commentTextField.text!, complition:{ success, response, error in
            
            if success == true{
                let commentItem = Comment(context: self.context)
                commentItem.text = response?["data"]["text"].stringValue
                commentItem.date = (response?["data"]["date"].int32Value)!
                commentItem.commentId = Int32((response?["data"]["id"].intValue)!)
                commentItem.item = self.objectImageEntity
                self.appDelegate.saveContext()
                self.commentTextField.text = ""
                
                do {
                    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Comment")
                    let sort = NSSortDescriptor(key: "date", ascending: false)
                    request.sortDescriptors = [sort]
                    
                    let result = try  self.context.fetch(request)
                    self.comments = result as! [Comment]
                } catch {}
                
                self.tableView.reloadData()
            }
        })
    }

}
