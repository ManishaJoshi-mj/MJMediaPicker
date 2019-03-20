//
//  ChooseMediaVC.swift
//  CameraVideoHelperDemo
//
//  Created by Manisha Joshi on 19/03/19.
//  Copyright © 2019 Manisha. All rights reserved.
//

import UIKit

class ChooseMediaVC: UIViewController {
  
  //MARK:-  Outlets
  @IBOutlet weak var btnPlayVideo: UIButton!
  @IBOutlet weak var imgMediaView: UIImageView!
  
  
  //MARK:-  Propeties
  //Store video url in order to play video when user click on play button
  var selectedVideoUrl : URL!
  
  //MARK:-  View Life Cycle Method
  override func viewDidLoad() {
    super.viewDidLoad()
  }
}

// MARK: - Button Actions
extension ChooseMediaVC {
  
  /// Called when user clicked on gallery option
  ///
  /// - Parameter sender: object of button gallery
  @IBAction func btnGalleryClicked(_ sender: UIButton) {
    
    MJMediaPicker.sharedInstance.chooseImageFromGallery(viewController: self) { (aImg, videoUrl, selectedType) in
      self.congiureaImageViewWithImage(img: aImg, videoUrl: videoUrl, selectedMediaType: selectedType)
    }
  }
  /// Called when user clicked on video option
  ///
  /// - Parameter sender: object of button video
  @IBAction func btnVideoClicked(_ sender: UIButton) {
    MJMediaPicker.sharedInstance.openCamera(self, isVideo: true, showVideoOption: true){ (aImg, videoUrl, selectedType) in
      self.congiureaImageViewWithImage(img: aImg, videoUrl: videoUrl, selectedMediaType: selectedType)
    }
  }
  /// Called when user clicked on camera option
  ///
  /// - Parameter sender: object of button camera
  @IBAction func btnCameraClicked(_ sender: UIButton) {
    MJMediaPicker.sharedInstance.openCamera(self, isVideo: false, showVideoOption: true) { (aImg, videoUrl, selectedType) in
      self.congiureaImageViewWithImage(img: aImg, videoUrl: videoUrl, selectedMediaType: selectedType)
    }
  }
  /// Called when user clicked on show actionsheet option
  ///
  /// - Parameter sender: object of button
  @IBAction func btnSelectMediaClicked(_ sender: UIButton) {
    MJMediaPicker.sharedInstance.showCameraVideoActionSheeet(self, showVideo: true) { (aImg, videoUrl, selectedType) in
      self.congiureaImageViewWithImage(img: aImg, videoUrl: videoUrl, selectedMediaType: selectedType)
    }
  }
  /// Called when user clicked on play button after selecting video
  ///
  /// - Parameter sender: object of button play
  @IBAction func btnPlayVideoClicked(_ sender: UIButton) {
    if let videoUrl = selectedVideoUrl {
      MJMediaPicker.sharedInstance.playVideo(self, videoUrl: videoUrl)
    }
  }
}

//MARK:-  Private Methods
extension ChooseMediaVC{
  
  /// Called after image or video has been selected by user
  ///This message display image on imageview
  /// - Parameters:
  ///   - img: The image selected by user or else nil
  ///   - videoUrl: Video url if video is selected by user else nil
  ///   - selectedMediaType: type : image / video
  func congiureaImageViewWithImage(img : UIImage? , videoUrl : URL? , selectedMediaType : FileType?) {
    DispatchQueue.main.async {
      self.btnPlayVideo.isHidden = true
      self.imgMediaView.image = UIImage(named: "")
      
      if let aSelectedFileType = selectedMediaType{
        switch aSelectedFileType {
        // called if  image is been selected by user
        case .image:
          if let aImg = img {
            self.imgMediaView.image = aImg
          }
        //called when video is been selected by user
        case .video :
          if let aVideoThumbnailImg = img , let aVideoUrl  = videoUrl{
            self.imgMediaView.image = aVideoThumbnailImg
            self.selectedVideoUrl = aVideoUrl
            self.btnPlayVideo.isHidden = false
          }
        }
      }
    }
  }
}
