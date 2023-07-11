//
//  ViewController.swift
//  MyAlbum
//
//  Created by 陈毅琦 on 2022/12/30.
//

import CoreMedia
import CoreML
import UIKit
import Vision
import EasyStash

class ViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    lazy var visionModel: VNCoreMLModel = {
        do {
            //       let coreMLWrapper = SnackLocalizationModel()
            let coreMLWrapper = SnackDetector()
            let visionModel = try VNCoreMLModel(for: coreMLWrapper.model)
            
            if #available(iOS 13.0, *) {
                visionModel.inputImageFeatureName = "image"
                visionModel.featureProvider = try MLDictionaryFeatureProvider(dictionary: [
                    "iouThreshold": MLFeatureValue(double: 0.45),
                    "confidenceThreshold": MLFeatureValue(double: 0.25),
                ])
            }
            
            return visionModel
        } catch {
            fatalError("Failed to create VNCoreMLModel: \(error)")
        }
    }()
    lazy var visionRequest: VNCoreMLRequest = {
        let request = VNCoreMLRequest(model: visionModel, completionHandler: {
            [weak self] request, error in
            self?.processObservations(for: request, error: error)
        })
        
        // NOTE: If you choose another crop/scale option, then you must also
        // change how the BoundingBoxView objects get scaled when they are drawn.
        // Currently they assume the full input image is used.
        request.imageCropAndScaleOption = .scaleFill
        return request
    }()
    let maxBoundingBoxViews = 10
    var boundingBoxViews = [BoundingBoxView]()
    var colors: [String: UIColor] = [:]
    var CurrentImage:UIImage!
    var getimage:[UIImage]=[]
    @IBOutlet weak var Gallery: UIButton!
    
    @IBOutlet weak var Add: UIButton!
    
    
    
    
    
    //
    



    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpBoundingBoxViews()
        Gallery.layer.cornerRadius=10
        Add.layer.cornerRadius=10
        flag=true
        readimage()
        flag=false

        

    }
    
    
    //
    
    func setUpBoundingBoxViews() {
        for _ in 0..<maxBoundingBoxViews {
            boundingBoxViews.append(BoundingBoxView())
        }
        
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
        ]
        
        // Make colors for the bounding boxes. There is one color for
        // each class, 20 classes in total.
        var i = 0
        for r: CGFloat in [0.5, 0.6, 0.75, 0.8, 1.0] {
            for g: CGFloat in [0.5, 0.8] {
                for b: CGFloat in [0.5, 0.8] {
                    colors[labels[i]] = UIColor(red: r, green: g, blue: b, alpha: 1)
                    i += 1
                }
            }
        }
    }
    
    func processObservations(for request: VNRequest, error: Error?) {
        //call show function
        DispatchQueue.main.async {
            if let results=request.results as?[VNRecognizedObjectObservation]{
                self.show(predictions: results)
            }
            else{self.show(predictions: [])}
        }
    }
    func show(predictions: [VNRecognizedObjectObservation]) {
        //process the results, call show function in BoundingBoxView
        var sort:String="unknow"
        var currentconfidence :Float=0
        var temp:[Detection]=[]
        for i in 0..<boundingBoxViews.count{
            if i < predictions.count{
                let prediction=predictions[i]
                let width=view.bounds.width
                let height = width * 16/9
                let offsetY=(view.bounds.height-height)/2
                let scale=CGAffineTransform.identity.scaledBy(x: width, y: height)
                let transform=CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -height-offsetY)
                let rect=prediction.boundingBox.applying(scale).applying(transform)
                
                let bestClass=prediction.labels[0].identifier
                let confidence=prediction.labels[0].confidence
                
                if(currentconfidence<confidence){
                    sort=bestClass
                    currentconfidence=confidence
                }

                
                
                let label=String(format: "%@ %.1f", bestClass,confidence*100)
                let color=colors[bestClass] ?? UIColor.red
                
                let newbox=Detection(box: prediction.boundingBox, confidence: confidence, label: label, color: color)
                temp.append(newbox)

            }
        }
            store(type: sort, img: CurrentImage,detections: temp)



        
        
        
    }
    func classify(image: UIImage) {
        //TODO: use VNImageRequestHandler to perform a classification request
        guard let ciImage=CIImage(image: image)else{
            print("cannot creat ciimg")
            return
        }
        let orientation=CGImagePropertyOrientation(image.imageOrientation)
        DispatchQueue.global(qos: .userInitiated).async {
            let handler=VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do{
                try handler.perform([self.visionRequest])
            }catch{
                print("fail to perform:\(error)")
            }
            
        }
    }
    
    
    //



    
    
    @IBAction func chooseImage(_ sender: Any) {
        let imagePickerController=UIImagePickerController()
        imagePickerController.delegate=self
        
        let actionSheet=UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default,handler: {(action:UIAlertAction)in
            imagePickerController.sourceType = .camera
            self.present(imagePickerController,animated: true,completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default,handler: {(action:UIAlertAction)in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController,animated: true,completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel,handler: nil))
        
        actionSheet.popoverPresentationController?.sourceView=self.view
        actionSheet.popoverPresentationController?.sourceRect=self.Add.frame

        
        self.present(actionSheet,animated: true,completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        let image=info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        CurrentImage=image!
        //imageview.image=image
        classify(image: image!)
        /*for box in self.boundingBoxViews {
            box.addToLayer(self.box.layer)
        }*/
        picker.dismiss(animated: true,completion: nil )
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true,completion: nil )
    }
    
    
    
}

