# iOS Photo Editor

## Features
- [x] Cropping 
- [x] Adding images -Stickers-
- [x] Adding Text with colors
- [x] Drawing with colors
- [x] Scaling and rotating objects 
- [x] Deleting objects 
- [x] Saving to photos and Sharing 
- [x] Cool animations 
- [x] Uses iOS Taptic Engine feedback 

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```
To integrate iOS Photo Editor into your Xcode project using CocoaPods, specify it in your `Podfile`:
```ruby
platform :ios, '10.0'

target '<Your Target Name>' do
    pod 'iOSPhotoEditor', '~> 1.0'
end
```

Then, run the following command:

```bash
$ pod install
```

## Usage

### Photo

The `PhotoEditorViewController`.

```swift
guard let photoEditor = UIStoryboard(name: "PhotoEditor", bundle: Bundle.iOSPhotoEditorResourceBundle)
        .instantiateViewController(withIdentifier: String(describing: PhotoEditorViewController.self)) as? PhotoEditorViewController
        else { return }


//PhotoEditorDelegate
photoEditor.photoEditorDelegate = self

//The image to be edited 
photoEditor.image = image

//Stickers that the user will choose from to add on the image         
photoEditor.stickers.append(UIImage(named: "sticker" )!)

//Optional: To hide controls - array of enum control
photoEditor.hiddenControls = [.crop, .draw, .share]

//Optional: Colors for drawing and Text, If not set default values will be used
photoEditor.colors = [.red,.blue,.green]

// Wrap in an UINavigationController
let navigationController = UINavigationController(rootViewController: photoEditor)
navigationController.modalPresentationStyle = UIModalPresentationStyle.currentContext //or .overFullScreen for transparency

// Present
present(navigationController, animated: true, completion: nil)
```
The `PhotoEditorDelegate` methods.

```swift
func doneEditing(image: UIImage) {
    // the edited image
}
    
func canceledEditing() {
    print("Canceled")
}

```

<img src="Assets/screenshot.PNG" width="350" height="600" />

# Live Demo appetize.io
[![Demo](Assets/appetize.png)](https://appetize.io/app/jtanmwtzbz1favhvhw5g24n7b0?device=iphone7plus&scale=50&orientation=portrait&osVersion=10.3)


# Demo Video 
[![Demo](https://img.youtube.com/vi/9VeIl9i30dI/0.jpg)](https://youtu.be/9VeIl9i30dI)

## Credits

Written by [Mohamed Hamed](https://github.com/M-Hamed).
<br>With contributions by [Mickey Knox](https://github.com/knox).
<br>Includes [PhotoCropEditor](https://github.com/sprint84/PhotoCropEditor) by [Guilherme Moura](https://github.com/sprint84).

Initially sponsored by [![Eventtus](http://assets.eventtus.com/logos/eventtus/standard.png)](http://eventtus.com)

## License

Released under the [MIT License](http://www.opensource.org/licenses/MIT).
