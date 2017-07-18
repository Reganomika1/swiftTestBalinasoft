//
//  SideMenuViewController.swift
//  TestForBalinaSoft(Swift)
//
//  Created by Zakhar on 7/18/17.
//  Copyright © 2017 BalinaSoft. All rights reserved.
//

import UIKit

class SideMenuViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var identifiers = [String]()
    var names = [String]()
    var images = [UIImage]()
    var selectedIndex = -1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        names = ["Photos", "Map"]
        identifiers = ["photosCell", "mapCell"]
        images = [#imageLiteral(resourceName: "person"), #imageLiteral(resourceName: "map2")]
        tableView.backgroundColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 237/255.0, alpha: 1.0)
        
        nameLabel.text = UserDefaults.standard.value(forKey: "login") as? String
        
        tableView.tableFooterView = UIView()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension SideMenuViewController: UITableViewDataSource {
    
    //MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return identifiers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifiers[indexPath.row])
        cell?.textLabel?.text = names[indexPath.row]
        cell?.imageView?.image = images[indexPath.row]
        
        let itemSize = CGSize(width: 25, height: 25)
        UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale);
        let imageRect = CGRect(x: 0, y: 0, width: itemSize.width, height: itemSize.height)
        cell?.imageView?.image!.draw(in: imageRect)
        cell?.imageView?.image! = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        
        cell?.imageView?.layer.cornerRadius = (cell?.imageView?.frame.size.width)!/2
        cell?.imageView?.clipsToBounds = true
        
        if selectedIndex == indexPath.row {
            cell?.contentView.backgroundColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 218/255.0, alpha: 1.0)
        } else {
            cell?.contentView.backgroundColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 237/255.0, alpha: 1.0)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}

extension SideMenuViewController: UITableViewDelegate {
    
    //MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        tableView.reloadData()
    }
    
}



