//
//  PhotoEditor+Controls.swift
//  Pods
//
//  Created by Mohamed Hamed on 6/16/17.
//
//

import Foundation
import UIKit

extension PhotoEditorViewController {

    // MARK: - Controls
    public enum Controls: UInt, CaseIterable {
        case save = 0
        case share
        case crop
        case sticker
        case draw
        case text
        case clear
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        photoEditorDelegate?.canceledEditing()
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func cropButtonTapped(_ sender: Any) {
        let controller = CropViewController()
        controller.delegate = self
        controller.image = image
        let navController = UINavigationController(rootViewController: controller)

        navController.navigationBar.tintColor = navigationController?.navigationBar.tintColor
        navController.navigationBar.barTintColor = navigationController?.navigationBar.barTintColor
        navController.navigationBar.isTranslucent = navigationController?.navigationBar.isTranslucent ?? false

        navController.toolbar.tintColor = navigationController?.toolbar.tintColor
        navController.toolbar.barTintColor = navigationController?.toolbar.barTintColor
        navController.toolbar.isTranslucent = navigationController?.toolbar.isTranslucent ?? false

        present(navController, animated: true, completion: nil)
    }

    @IBAction func stickersButtonTapped(_ sender: Any) {
        addStickersViewController()
    }

    @IBAction func drawButtonTapped(_ sender: Any) {
        isDrawing = true
        canvasImageView.isUserInteractionEnabled = false
        showToolbar(show: false)
        showDoneButton(show: true)
        showColorPicker(show: true)
    }

    @IBAction func textButtonTapped(_ sender: Any) {
        let textView = UITextView(frame: CGRect(x: 0, y: canvasImageView.center.y,
                                                width: UIScreen.main.bounds.width, height: 30))
        
        textView.textAlignment = .center
        textView.font = UIFont(name: "Helvetica", size: 30)
        textView.textColor = textColor
        textView.layer.shadowColor = UIColor.black.cgColor
        textView.layer.shadowOffset = CGSize(width: 1.0, height: 0.0)
        textView.layer.shadowOpacity = 0.2
        textView.layer.shadowRadius = 1.0
        textView.layer.backgroundColor = UIColor.clear.cgColor
        textView.autocorrectionType = .no
        textView.isScrollEnabled = false
        textView.delegate = self
        self.canvasImageView.addSubview(textView)
        addGestures(view: textView)
        textView.becomeFirstResponder()
    }    
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        view.endEditing(true)
        showDoneButton(show: false)
        showColorPicker(show: false) {
            self.showToolbar(show: true)
        }
        canvasImageView.isUserInteractionEnabled = true
        isDrawing = false
    }
    
    @IBAction func saveButtonTapped(_ sender: AnyObject) {
        UIImageWriteToSavedPhotosAlbum(canvasView.toImage(),self, #selector(PhotoEditorViewController.image(_:withPotentialError:contextInfo:)), nil)
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        let activity = UIActivityViewController(activityItems: [canvasView.toImage()], applicationActivities: nil)
        present(activity, animated: true, completion: nil)
        
    }
    
    @IBAction func clearButtonTapped(_ sender: AnyObject) {
        //clear drawing
        canvasImageView.image = nil
        //clear stickers and textviews
        for subview in canvasImageView.subviews {
            subview.removeFromSuperview()
        }
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        let img = self.canvasView.toImage()
        photoEditorDelegate?.doneEditing(image: img)
        self.dismiss(animated: true, completion: nil)
    }

    //MAKR: helper methods
    
    @objc func image(_ image: UIImage, withPotentialError error: NSErrorPointer, contextInfo: UnsafeRawPointer) {
        let alert = UIAlertController(title: "Image Saved", message: "Image successfully saved to Photos library", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func addControls(animated: Bool = true) {
        var barButtonItems = [UIBarButtonItem]()
        let visibleControls = Set(PhotoEditorViewController.Controls.allCases).subtracting(Set(hiddenControls))
                .sorted { $0.rawValue < $1.rawValue  }
        for control in visibleControls {
            switch control {
            case .save:
                barButtonItems.append(flexibleSpaceBarButtonItem())
                barButtonItems.append(saveButton)
            case .share:
                barButtonItems.append(flexibleSpaceBarButtonItem())
                barButtonItems.append(shareButton)
            case .crop:
                barButtonItems.append(flexibleSpaceBarButtonItem())
                barButtonItems.append(cropButton)
            case .sticker:
                barButtonItems.append(flexibleSpaceBarButtonItem())
                barButtonItems.append(stickerButton)
            case .draw:
                barButtonItems.append(flexibleSpaceBarButtonItem())
                barButtonItems.append(drawButton)
            case .text:
                barButtonItems.append(flexibleSpaceBarButtonItem())
                barButtonItems.append(textButton)
            case .clear:
                barButtonItems.append(flexibleSpaceBarButtonItem())
                barButtonItems.append(clearButton)
            }
        }

        if barButtonItems.isEmpty { return }
        barButtonItems.append(flexibleSpaceBarButtonItem())

        setToolbarItems(barButtonItems, animated: animated)
    }

    private func flexibleSpaceBarButtonItem() -> UIBarButtonItem {
        UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }
}
