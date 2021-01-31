//
//  ViewController.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 4/23/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//

import UIKit

public final class PhotoEditorViewController: UIViewController {
    
    /** holding the 2 imageViews original image and drawing & stickers */
    @IBOutlet weak var canvasView: UIView!
    //To hold the image
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    //To hold the drawings and stickers
    @IBOutlet weak var canvasImageView: UIImageView!

    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var continueButton: UIBarButtonItem!
    @IBOutlet var doneButton: UIBarButtonItem!

    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var colorsCollectionView: UICollectionView!
    @IBOutlet weak var colorPickerView: UIView!
    @IBOutlet weak var colorPickerViewBottomConstraint: NSLayoutConstraint!
    
    //Controls
    @IBOutlet weak var cropButton: UIBarButtonItem!
    @IBOutlet weak var stickerButton: UIBarButtonItem!
    @IBOutlet weak var drawButton: UIBarButtonItem!
    @IBOutlet weak var textButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var clearButton: UIBarButtonItem!
    
    public var image: UIImage?
    /**
     Array of Stickers -UIImage- that the user will choose from
     */
    public var stickers : [UIImage] = []
    /**
     Array of Colors that will show while drawing or typing
     */
    public var colors  : [UIColor] = []
    
    public weak var photoEditorDelegate: PhotoEditorDelegate?
    var colorsCollectionViewDelegate: ColorsCollectionViewDelegate!
    
    // list of controls to be hidden
    public var hiddenControls : [PhotoEditorViewController.Controls] = []
    
    var drawColor: UIColor = UIColor.black
    var textColor: UIColor = UIColor.white
    var isDrawing: Bool = false
    var lastPoint: CGPoint!
    var swiped = false
    var lastPanPoint: CGPoint?
    var lastTextViewTransform: CGAffineTransform?
    var lastTextViewTransCenter: CGPoint?
    var lastTextViewFont:UIFont?
    var activeTextView: UITextView?
    var imageViewToPan: UIImageView?

    weak var stickersViewController: StickersViewController?

    deinit {
        print("deinit")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.setImageView(image: image!)
        
        deleteView.layer.cornerRadius = deleteView.bounds.height / 2
        deleteView.layer.borderWidth = 2.0
        deleteView.layer.borderColor = UIColor.white.cgColor
        deleteView.clipsToBounds = true
        deleteView.tintColor = UIColor.white

        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
        edgePan.edges = .bottom
        edgePan.delegate = self
        self.view.addGestureRecognizer(edgePan)
        
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardWillChangeFrame(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        
        configureCollectionView()
        navigationItem.rightBarButtonItems = [continueButton]
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showToolbar(show: true, animated: false)
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(
                alongsideTransition: { _ in self.colorsCollectionView.collectionViewLayout.invalidateLayout() },
                completion: { _ in }
        )
    }
    
    func configureCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 30, height: 30)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        colorsCollectionView.collectionViewLayout = layout
        colorsCollectionViewDelegate = ColorsCollectionViewDelegate()
        colorsCollectionViewDelegate.colorDelegate = self
        if !colors.isEmpty {
            colorsCollectionViewDelegate.colors = colors
        }
        colorsCollectionView.delegate = colorsCollectionViewDelegate
        colorsCollectionView.dataSource = colorsCollectionViewDelegate
        
        colorsCollectionView.register(
            UINib(nibName: String(describing: ColorCollectionViewCell.self), bundle: Bundle.iOSPhotoEditorResourceBundle),
            forCellWithReuseIdentifier: String(describing: ColorCollectionViewCell.self))
    }
    
    func setImageView(image: UIImage) {
        imageView.image = image
        let size = image.suitableSize(widthLimit: UIScreen.main.bounds.width)
        imageViewHeightConstraint.constant = (size?.height)!
    }
    
    func showToolbar(show: Bool, animated: Bool = true) {
        let toolbarIsHidden = navigationController?.toolbar.isHidden ?? false
        if show {
            addControls(animated: animated && !toolbarIsHidden)
        }
        guard toolbarIsHidden == show else { return }
        navigationController?.setToolbarHidden(!show, animated: animated)
    }

    func showDoneButton(show: Bool) {
        if show {
            if navigationItem.rightBarButtonItem == doneButton { return }
            navigationItem.setLeftBarButton(nil, animated: true)
            navigationItem.setRightBarButton(doneButton, animated: true)
        }
        else {
            if navigationItem.rightBarButtonItem == continueButton { return }
            navigationItem.setLeftBarButton(cancelButton, animated: true)
            navigationItem.setRightBarButton(continueButton, animated: true)
        }
    }

    func showDeleteView(show: Bool, completion: (() -> Void)? = nil) {
        guard deleteView.isHidden == show else {
            completion?()
            return
        }
        if show {
            deleteView.alpha = 0.0
            deleteView.isHidden = false
            UIView.animate(withDuration: 0.3,
                    delay: 0.2,
                    options: [.beginFromCurrentState, .curveEaseIn],
                    animations: {
                self.deleteView.alpha = 1.0
            }, completion: { _ in completion?() })
        }
        else {
            UIView.animate(withDuration: 0.3,
                    delay: 0,
                    options: [.beginFromCurrentState, .curveEaseOut],
                    animations: {
                        self.deleteView.alpha = 0.0
            }, completion: { _ in
                self.deleteView.isHidden = true
                completion?()
            })
        }
    }

    func showColorPicker(show: Bool, completion: (() -> Void)? = nil) {
        guard colorPickerView.isHidden == show else {
            completion?()
            return
        }
        if show {
            colorPickerView.alpha = 0.0
            colorPickerView.isHidden = false
            UIView.animate(withDuration: 0.3,
                    delay: 0.2,
                    options: [.beginFromCurrentState, .curveEaseIn],
                    animations: {
                        self.colorPickerView.alpha = 1.0
                    }, completion: { _ in completion?() })
        }
        else {
            UIView.animate(withDuration: 0.3,
                    delay: 0,
                    options: [.beginFromCurrentState, .curveEaseOut],
                    animations: {
                        self.colorPickerView.alpha = 0.0
                    }, completion: { _ in
                self.colorPickerView.isHidden = true
                completion?()
            })
        }
    }
}

extension PhotoEditorViewController: ColorDelegate {
    func didSelectColor(color: UIColor) {
        if isDrawing {
            self.drawColor = color
        } else if activeTextView != nil {
            activeTextView?.textColor = color
            textColor = color
        }
    }
}





