# MJMediaPicker
A Custom Class to select media from camera ,video  or photo library .

# Usage
Just Drag and Drop MJMediaPicker class into your project and you are done.You can download and run the demo app for refrence.

How to use:

1.  If you need to capture image from Camera 
 ```bash
 MJMediaPicker.sharedInstance.openCamera(self, isVideo: false, showVideoOption: true) { (aImg, videoUrl, selectedType)  in
      //Perform your work accordingly
 } 
 ```
2. If you need to capture video
  ```bash
  MJMediaPicker.sharedInstance.openCamera(self, isVideo: true, showVideoOption: true) { (aImg, videoUrl, selectedType) in
      //Perform your work accordingly
  }
  ```
3. If you need to choose media from photo library
  ```bash
  MJMediaPicker.sharedInstance.chooseImageFromGallery(viewController: self) { (aImg, videoUrl, selectedType) in
      //Perform your work accordingly
  }
  ```
default:
```bash
MJMediaPicker.sharedInstance.showCameraVideoActionSheeet(self, showVideo: true) { (aImg, videoUrl, selectedType) in
    //Perform your work accordingly
    }
 ```
# HappyCoding !!
