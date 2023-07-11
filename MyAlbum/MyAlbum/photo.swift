//
//  photo.swift
//  MyAlbum
//
//  Created by 陈毅琦 on 2022/12/30.
//

import Foundation
import UIKit
import EasyStash
var storage: Storage? = nil
var options: Options = Options()
var flag=false

struct  Detection{
    var box:CGRect
    var confidence:Float
    var label:String?
    var color:UIColor=UIColor.systemBlue
}
   
    

    
struct Photo {
    var image:UIImage
    var label:String = ""
    var detections:[Detection]
    init(image: UIImage, label: String,detections:[Detection]){
        self.image = image
        self.label = label
        self.detections=detections
    }
}
struct Rect:Codable{
    var x:Float
    var y:Float
    var width:Float
    var height:Float
    var confidence:Float
}
var ImageData:[[Photo]]=[
    [],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]
]

func store(type:String,img:UIImage,detections:[Detection]){
    let labels = [
        "apple",
        "banana",
        "cake",
        "candy",
        "carrot",
        "cookie",
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
    for item in labels.enumerated(){
        if (type==item.element){
            let newimage=Photo(image: img, label: type,detections: detections)
            ImageData[item.offset].append(newimage)
            //
            if(flag==false)
            {
                let name=type+String(ImageData[item.offset].count-1)
                saveimage(image: img, name: name,label:type,detections:detections)
                
            }
            //
            break
            }
            
        }
    }
func saveimage(image:UIImage,name:String,label:String,detections:[Detection]){
    
    
    if let data = image.pngData() {
        // Create URL
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documents.appendingPathComponent(name+".png")
        
        do {
            // Write to Disk
            try data.write(to: url)
            
            // Store URL in User Defaults
            UserDefaults.standard.set(url, forKey: name)
            //rect
            
             var rects=[Rect]()
            for i in detections.indices
            {
                let box=detections[i].box
                rects.append(Rect(x:Float(box.origin.x), y:Float( box.origin.y), width: Float(box.width), height: Float(box.height), confidence: detections[i].confidence))
            }
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(rects) {
                let defaults = UserDefaults.standard
                defaults.set(encoded, forKey: name+"json")
            }
             
             
        
            
        } catch {
            print("Unable to Write Data to Disk (\(error))")
        }
    }
    
}
func readimage()
{
    let labels = [
        "apple",
        "banana",
        "cake",
        "candy",
        "carrot",
        "cookie",
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
    var getimage=UIImage()
    var getdetections=[Detection]()
    for type in labels.indices
    {
        //resetDefaults()
        var cnt=0
        while(true){
            let name=labels[type]+String(cnt)
            let url=UserDefaults.standard.url(forKey: name)
            if((url) != nil)
            {
                if let data = try? Data(contentsOf: url!)
                {
                    getimage=UIImage(data: data)!
                    
                    let defaults = UserDefaults.standard
                    if let rectsdata = defaults.object(forKey: name+"json") as? Data {
                        let decoder = JSONDecoder()
                        if let rects = try? decoder.decode([Rect].self, from: rectsdata) {
                            for item in rects.enumerated()
                            {
                                getdetections.append(Detection(box: CGRect(x: CGFloat(item.element.x), y: CGFloat(item.element.y), width: CGFloat(item.element.width), height: CGFloat(item.element.height)), confidence: item.element.confidence,label: labels[type]))
                            }
                        }
                    }
                    
                    
                    
                    store(type: labels[type], img: getimage, detections: getdetections)
                    cnt=cnt+1
                    
                }
                
            }else{
                break
            }
        }
    }
    //flag=false
}

func resetDefaults() {
    let defaults = UserDefaults.standard
    let dictionary = defaults.dictionaryRepresentation()
    dictionary.keys.forEach { key in
        defaults.removeObject(forKey: key)
    }
}
    
func drawDetectionsOnImage(_ detections: [Detection], _ image: UIImage) -> UIImage? {
    let imageSize = image.size
    let scale: CGFloat = 0.0
    UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)

    image.draw(at: CGPoint.zero)
    let ctx = UIGraphicsGetCurrentContext()
    var rects:[CGRect] = []
    for detection in detections {
        rects.append(detection.box)
        if let labelText = detection.label {
        let text = "\(labelText) : \(round(detection.confidence*100))"
            let textRect  = CGRect(x: detection.box.minX + imageSize.width * 0.01, y: detection.box.minY + imageSize.width * 0.01, width: detection.box.width, height: detection.box.height)
                    
        let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
                    
        let textFontAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: textRect.width * 0.1, weight: .bold),
            NSAttributedString.Key.foregroundColor: detection.color,
            NSAttributedString.Key.paragraphStyle: textStyle
        ]
                    
        text.draw(in: textRect, withAttributes: textFontAttributes)
        ctx?.addRect(detection.box)
        ctx?.setStrokeColor(detection.color.cgColor)
        ctx?.setLineWidth(9.0)
        ctx?.strokePath()
        }
    }

    guard let drawnImage = UIGraphicsGetImageFromCurrentImageContext() else {
        fatalError()
    }

    UIGraphicsEndImageContext()
    return drawnImage
}
