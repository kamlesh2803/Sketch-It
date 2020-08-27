//
//  MySketchesViewController.swift
//  Sketch It
//
//  Created by kamlesh on 27/08/20.
//  Copyright © 2020 kamlesh. All rights reserved.
//

import UIKit
import Firebase
import SnapKit
import SDWebImage

class MySketchesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var imgData : [String] = []
    
    private lazy var mySketchesCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewLayout.init())
        return collectionView
    }()
    
    private lazy var nosketches : UILabel = {
        let title = UILabel()
        title.font = UIFont(name: "HelveticaNeue-BoldItalic", size: 16)
        title.textAlignment = .center
        title.textColor = .white
        title.text = "\"No Sketches Made Yet\""
        return title
    }()
    
    private lazy var backGroundView: UIView = {
       let backGroundView = UIView(frame: CGRect(x: 0, y: 0, width: mySketchesCollectionView.frame.width, height: mySketchesCollectionView.frame.height))
        backGroundView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        return backGroundView
    }()
    
    private var activityIndicator: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView()
        loader.hidesWhenStopped = true
        loader.style = .large
        loader.color = .white
        return loader
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .rgb(fromHex: 0x2D4059)
        
        self.navigationItem.title = "My Sketches"

        //MARK: Arranging Collection View Cell Item
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let width = self.view.frame.width/3 - 15
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        layout.itemSize = CGSize(width: width, height: width)
        
        mySketchesCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        
        //MARK: Register custom collectionview cell to CollectionView
        mySketchesCollectionView.register(mySketchesCollectionViewCell.self, forCellWithReuseIdentifier: "mySketchesCollectionViewCell")
        
        mySketchesCollectionView.backgroundColor = .clear
        mySketchesCollectionView.delegate = self
        mySketchesCollectionView.dataSource = self
        
        //MARK: Adding subviews to Superview
        view.addSubview(activityIndicator)
        view.addSubview(mySketchesCollectionView)
        view.addSubview(nosketches)
        
        nosketches.isHidden = true
        mySketchesCollectionView.isHidden = true

        fetchMySketchesData()
        AutoLayoutForAllViews()
    }
    
    private func AutoLayoutForAllViews() {
        
        // For My Sketches Gallery
        mySketchesCollectionView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(view)
            make.topMargin.bottomMargin.equalTo(view).inset(20)
        }
        
        // For Text No Sketches
        nosketches.snp.makeConstraints { (make) in
            make.center.equalTo(view)
            make.leading.trailing.equalTo(view).inset(20)
            make.height.equalTo(30)
        }
        
        // For Loader
        activityIndicator.snp.makeConstraints { (make) in
            make.width.height.equalTo(100)
            make.center.equalTo(view)
        }
        
    }
    
    //MARK: Setting up CollectionView
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mySketchesCollectionViewCell", for: indexPath) as! mySketchesCollectionViewCell
        
        cell.imgViewSketches.sd_setImage(with: URL(string: imgData[indexPath.row]))
//        cell.layer.borderWidth = 1
//        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.cornerRadius = 5
        cell.layer.masksToBounds = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //MARK: Close Image Preview Button
        let btnClose = UIButton(frame: CGRect(x: backGroundView.frame.width - 60, y: 10, width: 50, height: 20))
        btnClose.setTitle("Close", for: .normal)
        btnClose.setTitleColor(.white, for: .normal)
        btnClose.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
        btnClose.addTarget(self, action: #selector(btnCloseTapped), for: .touchUpInside)
        
        //MARK: Share Image Button
        let btnShare = UIButton(frame: CGRect(x: backGroundView.frame.width - 120, y: 10, width: 50, height: 20))
        btnShare.setTitle("Share", for: .normal)
        btnShare.setTitleColor(.white, for: .normal)
        btnShare.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
        btnShare.tag = indexPath.row
        btnShare.addTarget(self, action: #selector(btnShareTapped), for: .touchUpInside)
        
        
        //MARK: Creating Image Preview
        let imageView = UIImageView(frame: CGRect(x: 20, y: 40, width: backGroundView.frame.width - 40, height: backGroundView.frame.height - 60))
        imageView.sd_setImage(with: URL(string: imgData[indexPath.row]))
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            imageView.transform = CGAffineTransform.identity.scaledBy(x: 1.01, y: 1.01)
        }) { (finished) in
          UIView.animate(withDuration: 1, animations: {
            
           imageView.transform = CGAffineTransform.identity

        })
        }
        
        mySketchesCollectionView.addSubview(backGroundView)
        backGroundView.addSubview(imageView)
        backGroundView.addSubview(btnClose)
        backGroundView.addSubview(btnShare)
        
    }
    
    //MARK: Close Button Action
    @objc func btnCloseTapped() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.backGroundView.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
        }) { (finished) in
            
            self.backGroundView.removeFromSuperview()
            self.backGroundView.transform = CGAffineTransform.identity
        }
    }
    
    //MARK: Share Button Action
    @objc func btnShareTapped(button: UIButton) {
        
        let imgView = UIImageView()
        imgView.sd_setImage(with: URL(string: imgData[button.tag])!)
        
        
        let activityViewController = UIActivityViewController(activityItems: [imgView.image!], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true)
    }
    
    
    func manageUI() {
        if imgData.count > 0 {
            nosketches.isHidden = true
            mySketchesCollectionView.isHidden = false
        }else{
            nosketches.isHidden = false
            mySketchesCollectionView.isHidden = true
        }
    }
    
    //MARK: Downloading images from firestore
    func fetchMySketchesData() {
        self.activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        
        let ref = globalConstants.firestoreRef.collection("Sketches")
        ref.getDocuments { (snap, err) in
            if err != nil {
                let alert = UIAlertController(title: "", message: "\(err!.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default))
                self.present(alert, animated: true, completion: nil)
                
                self.activityIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
                return
            }
            
            for document in snap!.documents {
                let data = document.data()
                for url in data.values {
                    self.imgData.append(url as! String)
                    
                    self.mySketchesCollectionView.reloadData()
                }
            }
            self.manageUI()
            self.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
        }
    }
}
