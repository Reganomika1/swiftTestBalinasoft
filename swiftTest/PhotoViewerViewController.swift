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

class PhotoViewerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var fetchedItem: Item!
    var page: Int = 0
    
    var fetchedControl: NSFetchedResultsController<NSFetchRequestResult>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 60
        
        tableView.tableFooterView = UIView()
        
        self.imageView.sd_setImage(with: URL(string: fetchedItem.imageUrl!) , placeholderImage: #imageLiteral(resourceName: "person"))
        
        fetchedControl = CoreDataManager.shared.getFetchedResultController(entityName: "Comment", sortDescriptor: "date", ascending: true)
        fetchedControl.delegate = self
        
        do {
            try fetchedControl.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }

        
        let date = Date(timeIntervalSince1970: TimeInterval(fetchedItem.date))
        let fomatter = DateFormatter()
        fomatter.dateFormat = "dd.MM.yyyy"
        self.dateLabel.text = fomatter.string(from: date)
        
        loadCommentsFromPage(page: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.fetchedItem.comment?.allObjects.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! CommentTableViewCell
        let fetchedComent = self.fetchedItem.comment?.allObjects[indexPath.row] as! Comment
        
        cell.commentTextLabel.text = fetchedComent.text
        let date = Date(timeIntervalSince1970: TimeInterval(fetchedComent.date))
        let fomatter = DateFormatter()
        fomatter.dateFormat = "dd.MM HH:mm"
        cell.commentDateLabel.text = fomatter.string(from: date)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    //MARK: - Pagination comments
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if (fetchedControl.sections!.first?.numberOfObjects)!-1 == indexPath.row && (fetchedControl.sections!.first?.numberOfObjects)!%10 == 0{
            self.page += 1
            loadCommentsFromPage(page: self.page)
        }
    }
    
    //MARK: - Close keyboard when user tap to screen
    
    func closeKeyboard() {
        view.endEditing(true)
    }
    
    //MARK: - UITableViewDelegate
    
    func tableView(_: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Удалить") { (UITableViewRowAction, NSIndexPath) -> Void in
            let fetchedComent = self.fetchedItem.comment?.allObjects[indexPath.row] as! Comment
            
            let alert = UIAlertController(title: "", message: "Do you want to delete this comment?", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { action in
                
                ServerManager.shared.removeComment(commentId: Int(fetchedComent.commentId), imageId:  Int(self.fetchedItem.itemId), complition:{ success, response, error in
                    if success == true {
                        CoreDataManager.shared.managedObjectContext.delete(fetchedComent)
                        CoreDataManager.shared.saveContext()
                    }
                })
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        deleteAction.backgroundColor = UIColor.red
        return [deleteAction]
    }
    
    //MARK: - NSFetchedResultsControllerDelegate
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.reloadData()
    }
    
    
    //MARK: - Actions
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        ServerManager.shared.postComment(imageId: Int(fetchedItem.itemId), text: commentTextField.text!, complition:{ success, response, error in
            
            if success == true{
                let objectCommentEntity = Comment()
                objectCommentEntity.commentId = (response?["data"]["id"].int32!)!
                objectCommentEntity.date = (response?["data"]["date"].int32!)!
                objectCommentEntity.text = response?["data"]["text"].stringValue
                objectCommentEntity.item = self.fetchedItem
                CoreDataManager.shared.saveContext()
                
                self.commentTextField.text = ""
                
                self.tableView.reloadData()
            }
        })
    }
    
    //MARK: - Custom methods
    
    func loadCommentsFromPage(page: Int) {
        ServerManager.shared.getComments(page: page, imageId: Int(fetchedItem.itemId), complition: { success, response, error in
            if success == true {
                let commentsArray = response?["data"].arrayValue
                
                flag: for element in commentsArray! {
                    
                    let fetchedComments = self.fetchedItem.comment?.allObjects as! [Comment]
                    for object in fetchedComments {
                        if object.commentId == element["id"].int32! {
                            continue flag
                        }
                    }
                    
                    let comment = Comment()
                    comment.date = element["date"].int32!
                    comment.commentId = element["id"].int32!
                    comment.text = element["text"].stringValue
                    comment.item = self.fetchedItem
                    CoreDataManager.shared.saveContext()
                }
            }
            self.tableView.scrollToLastRow(animated: true)
        })
    }

}

extension UITableView {
    func setOffsetToBottom(animated: Bool) {
        self.setContentOffset(CGPoint(x:0,y: self.contentSize.height - self.frame.size.height), animated: true)
    }
    
    func scrollToLastRow(animated: Bool) {
        let numberOfSections = self.numberOfSections
        let numberOfRows = self.numberOfRows(inSection: numberOfSections-1)
        if self.numberOfRows(inSection: 0) > 0 {
            let indexPath = NSIndexPath(row: numberOfRows-1, section: numberOfSections-1)
            self.scrollToRow(at: indexPath as IndexPath, at: UITableViewScrollPosition.bottom, animated: animated)
        }
    }
}
