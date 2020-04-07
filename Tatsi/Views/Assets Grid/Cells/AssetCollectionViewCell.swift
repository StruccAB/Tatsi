//
//  AssetCollectionViewCell.swift
//  AWKImagePickerController
//
//  Created by Rens Verhoeven on 29-03-16.
//  Copyright © 2017 Awkward BV. All rights reserved.
//

import UIKit
import Photos

let selectedImage: UIImage! = #imageLiteral(resourceName: "SelectedShot")
let unselectedImage: UIImage! = #imageLiteral(resourceName: "UnselectedShot")

final internal class AssetCollectionViewCell: UICollectionViewCell {
    
    static var reuseIdentifier: String {
        return "asset-cell"
    }
    
    internal var imageSize: CGSize = CGSize(width: 100, height: 100) {
        didSet {
            guard self.imageSize != oldValue else {
                return
            }
            self.shouldUpdateImage = true
        }
    }
    
    internal var imageManager: PHImageManager?
    
    internal var asset: PHAsset? {
        didSet {
            self.metadataView.asset = self.asset
            guard self.asset != oldValue || self.imageView.image == nil else {
                return
            }
            self.accessibilityLabel = asset?.accessibilityLabel
            self.shouldUpdateImage = true
        }
    }
    
    private var currentRequest: PHImageRequestID?
    
    fileprivate var shouldUpdateImage = false
    
    lazy private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy private var metadataView: AssetMetadataView = {
        let view = AssetMetadataView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy private var overlayView = OverlayView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.contentView.addSubview(self.imageView)
        self.contentView.addSubview(self.metadataView)
        self.contentView.addSubview(self.overlayView)
        
        self.accessibilityIdentifier = "tatsi.cell.asset"
        self.accessibilityTraits = UIAccessibilityTraits.image
        self.isAccessibilityElement = true
        
        self.setupConstraints()
    }
    
    private func setupConstraints() {
        let constraints = [
            self.imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.imageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: self.imageView.bottomAnchor),
            self.contentView.trailingAnchor.constraint(equalTo: self.imageView.trailingAnchor),
            
            self.overlayView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.overlayView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: self.overlayView.bottomAnchor),
            self.contentView.trailingAnchor.constraint(equalTo: self.overlayView.trailingAnchor),
            
            self.metadataView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: self.metadataView.bottomAnchor),
            self.contentView.rightAnchor.constraint(equalTo: self.metadataView.rightAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    internal func reloadContents() {
        guard self.shouldUpdateImage else {
            return
        }
        self.shouldUpdateImage = false
        self.startLoadingImage()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageView.image = nil
        
        if let currentRequest = self.currentRequest {
            let imageManager = self.imageManager ?? PHImageManager.default()
            imageManager.cancelImageRequest(currentRequest)
        }

    }
    
    fileprivate func startLoadingImage() {
        self.imageView.image = nil
        guard let asset = self.asset else {
            return
        }
        let imageManager = self.imageManager ?? PHImageManager.default()
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.resizeMode = PHImageRequestOptionsResizeMode.fast
        requestOptions.isSynchronous = false
        
        self.imageView.contentMode = UIView.ContentMode.center
        self.imageView.image = nil
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else {
                return
            }
            objc_sync_enter(self)
            autoreleasepool {
                let scale = UIScreen.main.scale > 2 ? 2 : UIScreen.main.scale
                let targetSize = self.imageSize.scaled(with: scale)
                guard self.asset?.localIdentifier == asset.localIdentifier else {
                    return
                }
                self.currentRequest = imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: PHImageContentMode.aspectFill, options: requestOptions) { (image, _) in
                    DispatchQueue.main.async {
                        autoreleasepool {
                            guard let image = image, self.asset?.localIdentifier == asset.localIdentifier else {
                                return
                            }
                            self.imageView.contentMode = UIView.ContentMode.scaleAspectFill
                            self.imageView.image = image
                        }
                    }
                }
            }
            objc_sync_exit(self)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            self.overlayView.setSelected(isSelected)
        }
    }
}

class OverlayView: UIView {
    private let imageView: UIImageView = {
        let imageView = UIImageView(image: unselectedImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private let selectedBackgroundView: UIView
    
    init() {
        selectedBackgroundView = UIView()
        selectedBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        selectedBackgroundView.isHidden = true
        selectedBackgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(selectedBackgroundView)
        selectedBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        selectedBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        selectedBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        selectedBackgroundView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        addSubview(imageView)
        topAnchor.constraint(
            equalTo: imageView.topAnchor,
            constant: -5
        ).isActive = true
        trailingAnchor.constraint(
            equalTo: imageView.trailingAnchor,
            constant: 5
        ).isActive = true
    }
    
    @available(*, unavailable,
      message: "Loading this view from a nib is unsupported in favor of initializer."
    )
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSelected(_ isSelected: Bool) {
        selectedBackgroundView.isHidden = !isSelected
        UIView.animate(withDuration: 0.1) { [unowned self] in
            self.imageView.image = isSelected
                ? selectedImage!
                : unselectedImage
        }
    }
}
