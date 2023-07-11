//
//  detailViewController.swift
//  MyAlbum
//
//  Created by 陈毅琦 on 2023/1/1.
//

import UIKit
import Vision

class detailViewController: UIViewController {
    @IBOutlet weak var Image: UIImageView!
    var sendimage:Photo!
    override func viewDidLoad() {
        super.viewDidLoad()
        for index in sendimage.detections.indices
        {
            sendimage.detections[index].box.origin.y=1-sendimage.detections[index].box.origin.y
            sendimage.detections[index].box.size.height = -1*sendimage.detections[index].box.size.height
            sendimage.detections[index].box=VNImageRectForNormalizedRect(sendimage.detections[index].box, Int(sendimage.image.size.width), Int(sendimage.image.size.height))
        }
        self.Image.image=drawDetectionsOnImage(sendimage.detections, sendimage.image)


        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
