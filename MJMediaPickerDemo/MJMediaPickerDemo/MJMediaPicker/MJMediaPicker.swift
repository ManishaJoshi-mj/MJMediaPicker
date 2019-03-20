//
//  MJPicker.swift
//  MJPickerDemo
//
//  Created by Manisha Joshi on 19/03/19.
//  Copyright © 2019 Manisha. All rights reserved.
//


import UIKit
import AVFoundation
import MobileCoreServices
import Photos
import MediaPlayer
import AVKit
import AssetsLibrary


/// Enum to know  user selected media type
///
/// - image: User has selected image
/// - video: User has selected video
enum FileType {
  case image
  case video
}


class MJMediaPicker: NSObject, UIImagePickerControllerDelegate , UINavigationControllerDelegate {
  
  static let sharedInstance = MJMediaPicker()
  
  //MARK:- Properties
  
  //Store the object of controller from which the method gets called
  var objVC : UIViewController?
  
  //Block which will be return at completion
  typealias completionBlock = (UIImage?, URL? ,FileType? ) -> Void
  var block : completionBlock?
  
  
  // MARK: - Show Action sheet
  // MARK: -
  
  /// This method show action sheet with options to select media type
  ///
  /// - Parameters:
  ///   - controller: The object of controller from where the method gets called
  ///   - showVideo: True , if need to show video option else false
  ///   - completionHandler: block which will give selected image , video url and type of media selected
  func showCameraVideoActionSheeet(_ controller : UIViewController ,showVideo : Bool,completionHandler:@escaping completionBlock){
    
    var arrOptions = ["Capture Photo", "Capture Video" , "Import from library" ]//["Capture Photo", "Capture Video"]   //
    
    if showVideo == false{
      arrOptions = ["Camera", "Import from library"]
    }
    
    DispatchQueue.main.async(execute: {
      
      UIAlertController.showAlertForCameraHelper(controller: controller,style: .actionSheet ,aCancelBtn: "Cancel", aStrMessage: nil, otherButtonArr: arrOptions, completion: { (index, strButtonTitle) in
        
        if index == 0 {
          // "Capture Photo" selcted
          self.openCamera(controller, isVideo: false , showVideoOption: showVideo, completionBlock: completionHandler)
        }
        else if index == 1 {
          // "Capture Video" selected
          if showVideo == true{
            // user tapped on video actionPerform action related to video
            self.openCamera(controller, isVideo: true ,  showVideoOption: showVideo, completionBlock: completionHandler)
          }
          else{
            self.chooseImageFromGallery(viewController :controller, completionBlock: completionHandler )
          }
        }
        else if  showVideo &&  index == 2{
          // If user selected gallery
          self.chooseImageFromGallery(viewController :controller, completionBlock: completionHandler )
        }
      })
    } )
    
    objVC = controller
    block = completionHandler
  }
  
  
  /// This method gets called when user select camera or video option
  ///
  /// - Parameters:
  ///   - VC: The object of controller from where the method gets called
  ///   - isVideo: True , if called for video
  ///   - showVideoOption: True if user can select video option even though clicked camera else false
  ///   - completionBlock:block which will give selected image , video url and type of media selected
  func openCamera (_ VC : UIViewController , isVideo : Bool , showVideoOption : Bool , completionBlock:@escaping completionBlock ) {
    
    let cameraMediaType = AVMediaType.video
    let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType)
    
    objVC = VC
    block = completionBlock
    
    
    let imagePicker = UIImagePickerController()
    
    switch cameraAuthorizationStatus {
      
    case .denied:
      //display alert to open setting if camera permission is denied
      alertPromptToAllowCameraAccessViaSettings(controller: VC, strType: "Camera")
    case .authorized:
      presentImagePicker(imagePicker, showVideoOption, isVideo, VC)
    case .restricted:
      break
    case .notDetermined:
      if !UIImagePickerController.isSourceTypeAvailable(.camera) {
        //show error
        print("CAMERA_NOT_SUPPORTED")
        //show alert to allow access photo library
        UIAlertController.showAlertForCameraHelper(controller: VC, aStrMessage: "Unable to access the Camera,  Camera  not available", otherButtonArr: ["OK"], completion: { (aInt, strMsg) in
        })
        return
      }
      AVCaptureDevice.requestAccess(for: cameraMediaType) { granted in
        if granted {
          self.presentImagePicker(imagePicker, showVideoOption, isVideo, VC)
        }
      }
    }
  }
  
  /// Called when user select gallery option to choose media
  ///
  /// - Parameters:
  ///   - viewController: The object of controller from which user has selected the option
  ///   - completionBlock: block which will give selected image , video url and type of media selected
  func chooseImageFromGallery(viewController :UIViewController , completionBlock:@escaping completionBlock ) {
    // If user selected gallery
    
    objVC = viewController
    block = completionBlock
    
    let imagePicker =   UIImagePickerController()
    imagePicker.delegate = self
    imagePicker.sourceType = .savedPhotosAlbum
    imagePicker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String , kUTTypeMPEG4 as String]
    imagePicker.allowsEditing = true
    imagePicker.isEditing = true
    viewController.present(imagePicker, animated: true, completion: nil)
  }
  
  //MARK:- Show Alert to Open settings Page
  func alertPromptToAllowCameraAccessViaSettings(controller : UIViewController, strType : String) {
    UIAlertController.showAlertForCameraHelper(controller: controller, style: .alert, aCancelBtn: "Cancel", aStrMessage: " Would Like To Access the \(strType) Please grant permission to use the \(strType).", otherButtonArr: ["Settings"]) { (aInt, aStrMsg) in
      if aInt == 0 {
        if !UIApplication.openSettingsURLString.isEmpty {
          UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }
      }
    }
  }
  
  //check if user has allowed for photo library permission
  
  func checkPhotoLibraryPermission(_ VC : UIViewController) {
    
    let status = PHPhotoLibrary.authorizationStatus()
    
    if (status == PHAuthorizationStatus.authorized) {
      // Access has been granted.
    }
    else if (status == PHAuthorizationStatus.denied) {
      // Access has been denied.
      alertPromptToAllowCameraAccessViaSettings(controller: VC, strType: "Photo Library")
    }
    else if (status == PHAuthorizationStatus.notDetermined) {
      
      // Access has not been determined.
      PHPhotoLibrary.requestAuthorization({ (newStatus) in
        
        if (newStatus == PHAuthorizationStatus.authorized) {
          
        }else {
          //show alert to allow access photo library
          UIAlertController.showAlertForCameraHelper(controller: VC, aStrMessage: "Photo library access is required to record Video", otherButtonArr: ["OK"], completion: { (aInt, strMsg) in
          })
        }
      })
    }
    else if (status == PHAuthorizationStatus.restricted) {
      // Restricted access - normally won't happen.
    }
  }
  
  //MARK:- Open video Controller
  //MARK:-
  
  func playVideo (_ controller : UIViewController , videoUrl : URL)
  {
    let player = AVPlayer(url: videoUrl)
    let playerViewController = AVPlayerViewController()
    playerViewController.player = player
    controller.present(playerViewController, animated: true)
    {
      DispatchQueue.main.async {
        playerViewController.player!.play()
      }
    }
  }
  
  // perform Camera or Video action Methods
  fileprivate func presentImagePicker(_ imagePicker: UIImagePickerController, _ showVideoOption: Bool, _ isVideo: Bool, _ VC: UIViewController) {
    
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      imagePicker.delegate = self
      imagePicker.sourceType = .camera
      imagePicker.cameraCaptureMode = .photo
      imagePicker.allowsEditing = true
      imagePicker.isEditing = true
      imagePicker.mediaTypes = showVideoOption ? [kUTTypeMovie as String , kUTTypeImage as String] : [kUTTypeImage as String]
      
      //Check photo library permission
      self.checkPhotoLibraryPermission(VC)
      
      if isVideo {
        //set quality of video for compress size
        imagePicker.videoQuality = .type640x480
        if #available(iOS 11.0, *) {
          imagePicker.videoExportPreset = AVAssetExportPreset640x480
        }
        imagePicker.cameraCaptureMode = .video
        imagePicker.mediaTypes = [kUTTypeMovie as String ,  kUTTypeImage as String ]
      }
      VC.present(imagePicker, animated: true, completion: nil)
      
    } else {
      //show error to user for allowing access from settings
      print("ALLOW_CAMERA_ACCESS_FROM_SETTINGS" , "Denied access to Camera")
      UIAlertController.showAlertForCameraHelper(controller: VC, aStrMessage: "Please allow camera access from  settings.", otherButtonArr: ["OK"], completion: { (aInt, strMsg) in
      })
    }
  }
  
  /// Called to get thumbnail image for video
  ///
  /// - Parameter url: Url of video which is selected by user
  /// - Returns: image genrated by the url
  func getThumbnailImage(forUrl url: URL) -> UIImage? {
    let asset: AVAsset = AVAsset(url: url)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    //set property to get thumbnail the way video has taken
    imageGenerator.appliesPreferredTrackTransform = true
    do {
      let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
      return UIImage(cgImage: thumbnailImage)
    } catch let error {
      print(error)
    }
    return nil
  }
  
  func deleteFile(_ filePath:URL) {
    guard FileManager.default.fileExists(atPath: filePath.path) else{
      return
    }
    do {
      try FileManager.default.removeItem(atPath: filePath.path)
    }catch{
      fatalError("Unable to delete file: \(error) : \(#function).")
    }
  }
}


// MARK: - UIImagePickerControllerDelegate Methods
extension MJMediaPicker {
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
    //Shoow indicator till the video or image get proceed
    guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String else {
      return
    }
    
    if mediaType.isEqual(kUTTypeImage as String) {
      
      guard var image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
      
      let currentTimeStamp = String(Int(NSDate().timeIntervalSince1970))
      
      // Get the Original Image.
      
      // Check If editing was enabled or not. If it was enabled then get the editted image.
      if picker.allowsEditing {
        image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage ?? image
      }
      
      // get the documents directory url
      let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
      // choose a name for your image
      var fileName =  "\(currentTimeStamp)\("Img.jpg")"
      if let referenceUrl = info[UIImagePickerController.InfoKey.referenceURL] as? NSURL {
        fileName = "\(currentTimeStamp)\(referenceUrl.lastPathComponent ?? "Img.jpg")"
      }
      // create the destination file url to save your image
      
      let fileURL = documentsDirectory.appendingPathComponent(fileName)
      // get your UIImage jpeg data representation and check if the destination file url already exists
      if let data = image.jpegData(compressionQuality: 1.0),!FileManager.default.fileExists(atPath: fileURL.path) {
        do {
          // writes the image data to disk
          try data.write(to: fileURL)
          print("file saved")
        } catch {
          print("error saving file:", error)
        }
      }
      //Hide indicator and Call  completion block to pass the image and continue the further process.
      block?(image, nil , .image)
      
    } else if mediaType.isEqual(kUTTypeMovie as String) {
      
      if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL{
        let aVideoImage = self.getThumbnailImage(forUrl: videoURL)
        
        let avAsset = AVURLAsset(url: videoURL)
        let startDate = Date()
        let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPreset640x480)
        
        let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let myDocPath = NSURL(fileURLWithPath: docDir).appendingPathComponent("temp.mp4")?.absoluteString
        
        let docDir2 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
        
        let filePath = docDir2.appendingPathComponent("rendered-Video.mp4")
        deleteFile(filePath!)
        
        if FileManager.default.fileExists(atPath: myDocPath!){
          do{
            try FileManager.default.removeItem(atPath: myDocPath!)
          }catch let error{
            print(error)
          }
        }
        
        exportSession?.outputURL = filePath
        exportSession?.outputFileType = AVFileType.mp4
        exportSession?.shouldOptimizeForNetworkUse = true
        // exportSession?.maxDuration =  TimeInterval(300.0)
        let start = CMTimeMakeWithSeconds(0.0, preferredTimescale: 0)
        let range = CMTimeRange(start: start, duration: avAsset.duration)
        exportSession?.timeRange = range
        
        exportSession!.exportAsynchronously{() -> Void in
          switch exportSession!.status{
          case .failed:
            print("\(exportSession!.error!)")
            //Hide indicator
            self.block?(aVideoImage,nil, .video )
          case .cancelled:
            print("Export cancelled")
            //Hide indicator
            self.block?(aVideoImage,nil, .video)
          case .completed:
            let endDate = Date()
            let time = endDate.timeIntervalSince(startDate)
            print(time)
            print("Successful")
            print(exportSession?.outputURL ?? "")
            //Hide indicator
            self.block?(aVideoImage,exportSession?.outputURL , .video)
          default:
            break
          }
        }
      }
    }
    objVC?.dismiss(animated: true, completion: nil)
  }
  
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    block?(nil, nil , .image)
    objVC?.dismiss(animated: true, completion: nil)
  }
}

// MARK: - AlertController Methods
extension UIAlertController {
  
  
  /// Display Alert or Actionsheet
  ///
  /// - Parameters:
  ///   - controller: Controller object in which alert will be displayed
  ///   - style: Style of alert .Alert / .Actionsheet
  ///   - aCancelBtn: Title you need to display on cancel button
  ///   - aStrMessage: Message to be displayed
  ///   - otherButtonArr: Array of Other buttonn title
  ///
  class func showAlertForCameraHelper(controller : AnyObject ,
                                      style : UIAlertController.Style = .alert ,
                                      aCancelBtn :String? = nil ,
                                      aStrMessage :String? ,
                                      otherButtonArr : Array<String>?,
                                      completion : ((Int, String) -> Void)?) -> Void {
    let alert = UIAlertController.init(title: nil, message: aStrMessage, preferredStyle: style)
    if let strCancelBtn = aCancelBtn {
      let aStrCancelBtn = strCancelBtn
      alert.addAction(UIAlertAction.init(title: aStrCancelBtn, style: .cancel, handler: { (UIAlertAction) in
        completion?(otherButtonArr != nil ? otherButtonArr!.count : 0, strCancelBtn)
      }
      ))
    }
    
    if let arr = otherButtonArr {
      
      for (index, value) in arr.enumerated() {
        let aValue = value
        alert.addAction(UIAlertAction.init(title: aValue, style: .default, handler: { (UIAlertAction) in
          completion?(index, value)
        }))
      }
    }
    controller.present(alert, animated: true, completion: nil)
  }
}
