//
//  photoTableViewController.swift
//  MyAlbum
//
//  Created by 陈毅琦 on 2022/12/30.
//

import UIKit
class photoTableViewController: UITableViewController {
    var items:[String]=["All",
                        "apple",
                        "banana",
                        "cake",
                        "candy",
                        "carrot",
                        "cookies",
                        "doughnut",
                        "grape",
                        "hot dog",
                        "ice cream",
                        "juice",
                        "muffin",
                        "orange",
                        "pineapple",
                        "popcorn",
                        "pretzel",
                        "salad",
                        "strawberry",
                        "waffle",
                        "watermelon",
                        "unknow"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 22
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "list", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text=items[indexPath.row]
        cell.textLabel?.textColor=UIColor .white
        cell.detailTextLabel?.textColor=UIColor .white
        cell.textLabel?.font=UIFont .boldSystemFont(ofSize: 14)
        if(indexPath.row==0){
            var cnt=0
            for iter in ImageData
            {
                cnt=cnt+iter.count
            }
            cell.detailTextLabel?.text=String(cnt)
        }else
        {
            cell.detailTextLabel?.text=String(ImageData[indexPath.row-1].count)
            
        }
        return cell
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier=="toshow",
           let cv=segue.destination as? showCollectionViewController{
            let index = tableView.indexPathForSelectedRow?.row
            cv.select=items[index!]
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
