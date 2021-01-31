//
//  StickersViewController.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 4/23/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//  Credit https://github.com/AhmedElassuty/IOS-BottomSheet

import UIKit

class StickersViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var holdView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var stickerCollectionView: UICollectionView!
    var emojisCollectionView: UICollectionView!
    
    var emojisDelegate: EmojisCollectionViewDelegate!
    
    var stickers : [UIImage] = []
    weak var stickersViewControllerDelegate : StickersViewControllerDelegate?
    
    let screenSize = UIScreen.main.bounds.size
    
    let fullView: CGFloat = 100 // remainder of screen height
    var partialView: CGFloat {
        return UIScreen.main.bounds.height - 380
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionViews()
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        pageControl.numberOfPages = 2

        holdView.layer.cornerRadius = 3
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(StickersViewController.panGesture))
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
    }
    
    func configureCollectionViews() {

        let contentView = UIView()
        contentView.backgroundColor = .clear
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true

        if #available(iOS 11.0, *) {
            contentView.widthAnchor.constraint(equalTo:view.safeAreaLayoutGuide.widthAnchor, multiplier: 2).isActive = true
        }
        else {
            contentView.widthAnchor.constraint(equalTo:view.widthAnchor, multiplier: 2).isActive = true
        }
        contentView.heightAnchor.constraint(equalTo:view.heightAnchor, constant: -headerView.frame.size.height).isActive = true

        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        var interfaceOrientation: UIInterfaceOrientation
        if #available(iOS 13.0, *) {
            interfaceOrientation = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.windowScene?.interfaceOrientation
                    ?? UIInterfaceOrientation.unknown
        }
        else {
            interfaceOrientation = UIApplication.shared.statusBarOrientation
        }
        var width: CGFloat
        if interfaceOrientation == .landscapeLeft || interfaceOrientation == .landscapeRight {
            width =  (CGFloat) ((screenSize.height - layout.sectionInset.left - layout.sectionInset.right) / 3.0)
        }
        else {
            width =  (CGFloat) ((screenSize.width - layout.sectionInset.left - layout.sectionInset.right) / 3.0)
        }
        layout.itemSize = CGSize(width: width, height: 100)

        stickerCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        stickerCollectionView.backgroundColor = .clear
        contentView.addSubview(stickerCollectionView)
        stickerCollectionView.translatesAutoresizingMaskIntoConstraints = false
        stickerCollectionView.leadingAnchor.constraint(equalTo:contentView.leadingAnchor).isActive = true
        stickerCollectionView.topAnchor.constraint(equalTo:contentView.topAnchor).isActive = true
        stickerCollectionView.bottomAnchor.constraint(equalTo:contentView.bottomAnchor).isActive = true
        stickerCollectionView.widthAnchor.constraint(equalTo:contentView.widthAnchor, multiplier: 0.5).isActive = true

        stickerCollectionView.delegate = self
        stickerCollectionView.dataSource = self
        
        stickerCollectionView.register(
            UINib(nibName: String(describing: StickerCollectionViewCell.self), bundle: Bundle.iOSPhotoEditorResourceBundle),
            forCellWithReuseIdentifier: String(describing: StickerCollectionViewCell.self))
        
        //-----------------------------------
        
        let emojislayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        emojislayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        emojislayout.itemSize = CGSize(width: 70, height: 70)
        
        emojisCollectionView = UICollectionView(frame: .zero, collectionViewLayout: emojislayout)
        emojisCollectionView.backgroundColor = .clear
        contentView.addSubview(emojisCollectionView)
        emojisCollectionView.translatesAutoresizingMaskIntoConstraints = false
        emojisCollectionView.leadingAnchor.constraint(equalTo:stickerCollectionView.trailingAnchor).isActive = true
        emojisCollectionView.topAnchor.constraint(equalTo:contentView.topAnchor).isActive = true
        emojisCollectionView.trailingAnchor.constraint(equalTo:contentView.trailingAnchor).isActive = true
        emojisCollectionView.bottomAnchor.constraint(equalTo:contentView.bottomAnchor).isActive = true

        emojisDelegate = EmojisCollectionViewDelegate()
        emojisDelegate.stickersViewControllerDelegate = stickersViewControllerDelegate
        emojisCollectionView.delegate = emojisDelegate
        emojisCollectionView.dataSource = emojisDelegate
        
        emojisCollectionView.register(
            UINib(nibName: String(describing: EmojiCollectionViewCell.self), bundle: Bundle.iOSPhotoEditorResourceBundle),
            forCellWithReuseIdentifier: String(describing: EmojiCollectionViewCell.self))
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareBackgroundView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let frame = self.view.frame
        let yComponent = self.partialView
        let height = UIScreen.main.bounds.height - self.partialView
        UIView.animate(withDuration: 0.6) { [weak self] in
            guard let self = self else { return }
            self.view.frame = CGRect(x: 0,
                                     y: yComponent,
                                     width: frame.width,
                                     height: height)
        }
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(
                alongsideTransition: { [weak self] _ in
                    self?.stickerCollectionView.collectionViewLayout.invalidateLayout()
                    self?.emojisCollectionView.collectionViewLayout.invalidateLayout()
                },
                completion: { [weak self] _ in
                    self?.stickerCollectionView.collectionViewLayout.invalidateLayout()
                    self?.emojisCollectionView.collectionViewLayout.invalidateLayout()
                }
        )
    }
    
    //MARK: Pan Gesture
    
    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: self.view)
        let velocity = recognizer.velocity(in: self.view)
        
        let y = self.view.frame.minY
        if y + translation.y >= fullView {
            let newMinY = y + translation.y
            self.view.frame = CGRect(x: 0, y: newMinY, width: view.frame.width, height: UIScreen.main.bounds.height - newMinY )
            self.view.layoutIfNeeded()
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        }
        
        if recognizer.state == .ended {
            var duration =  velocity.y < 0 ? Double((y - fullView) / -velocity.y) : Double((partialView - y) / velocity.y )
            duration = duration > 1.3 ? 1 : duration
            //velocity is direction of gesture
            UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: {
                if  velocity.y >= 0 {
                    if y + translation.y >= self.partialView  {
                        self.removeBottomSheetView()
                    } else {
                        self.view.frame = CGRect(x: 0, y: self.partialView, width: self.view.frame.width, height: UIScreen.main.bounds.height - self.partialView)
                        self.view.layoutIfNeeded()
                    }
                } else {
                    if y + translation.y >= self.partialView  {
                        self.view.frame = CGRect(x: 0, y: self.partialView, width: self.view.frame.width, height: UIScreen.main.bounds.height - self.partialView)
                        self.view.layoutIfNeeded()
                    } else {
                        self.view.frame = CGRect(x: 0, y: self.fullView, width: self.view.frame.width, height: UIScreen.main.bounds.height - self.fullView)
                        self.view.layoutIfNeeded()
                    }
                }
                
            }, completion: nil)
        }
    }
    
    func removeBottomSheetView() {
        var frame = view.frame
        frame.origin.y = UIScreen.main.bounds.maxY
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: UIView.AnimationOptions.curveEaseIn,
                       animations: { [weak self] () -> Void in
                        self?.view.frame = frame
                        
        }, completion: { [weak self] (finished) -> Void in
            guard let self = self else { return }
            self.view.removeFromSuperview()
            self.removeFromParent()
            self.stickersViewControllerDelegate?.stickersViewDidDisappear()
        })
    }
    
    func prepareBackgroundView(){
        let blurEffect = UIBlurEffect.init(style: .light)
        let visualEffect = UIVisualEffectView.init(effect: blurEffect)
        let bluredView = UIVisualEffectView.init(effect: blurEffect)
        bluredView.contentView.addSubview(visualEffect)
        visualEffect.frame = UIScreen.main.bounds
        bluredView.frame = UIScreen.main.bounds
        view.insertSubview(bluredView, at: 0)
    }
    
    
    
}

extension StickersViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.bounds.width
        let pageFraction = scrollView.contentOffset.x / pageWidth
        self.pageControl.currentPage = Int(round(pageFraction))
    }
}

// MARK: - UICollectionViewDataSource
extension StickersViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stickers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        stickersViewControllerDelegate?.didSelectImage(image: stickers[indexPath.item])
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = "StickerCollectionViewCell"
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! StickerCollectionViewCell
        cell.stickerImage.image = stickers[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

