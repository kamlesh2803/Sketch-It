//
//  CreateSketchViewController.swift
//  Sketch It
//
//  Created by kamlesh on 26/08/20.
//  Copyright © 2020 kamlesh. All rights reserved.
//

import UIKit
import Firebase
import SnapKit
import ColorSlider

class CreateSketchViewController: UIViewController {
    
    let canvas = Canvas()
    
    private lazy var toolBarView: UIView = {
        let toolBarView = UIView()
        toolBarView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        return toolBarView
    }()
    
    private lazy var slider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 1
        slider.maximumValue = 20
        slider.addTarget(self, action: #selector(manageBrushSliderChange), for: .valueChanged)
        return slider
    }()
    
    private var colorSlider: ColorSlider = {
        let slider = ColorSlider(orientation: .horizontal, previewSide: .top)
        slider.addTarget(self, action: #selector(manageColorSliderChange(slider:)), for: .valueChanged)
        return slider
    }()
    
    private lazy var btnUndo: UIButton = {
        let button = UIButton()
        button.setTitle("Undo", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
        button.addTarget(self, action: #selector(btnUndoTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var btnClear: UIButton = {
        let button = UIButton()
        button.setTitle("Clear", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
        button.addTarget(self, action: #selector(btnClearTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var btnSave: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "download"), for: .normal)
        button.addTarget(self, action: #selector(btnSaveTapped), for: .touchUpInside)
        return button
    }()
    
    private var activityIndicator: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView()
        loader.hidesWhenStopped = true
        loader.style = .large
        return loader
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        let saveItem = UIBarButtonItem(customView: btnSave)
        self.navigationItem.setRightBarButton(saveItem, animated: true)

        view.backgroundColor = .white
        
        //MARK:Adding Subviews to ToolbarView
        toolBarView.addSubview(colorSlider)
        toolBarView.addSubview(slider)
        toolBarView.addSubview(btnUndo)
        toolBarView.addSubview(btnClear)
        
        //MARK:Adding Subviews to Superview
        view.addSubview(toolBarView)
        view.addSubview(canvas)
        view.addSubview(activityIndicator)
        
        canvas.backgroundColor = .clear
        AutoLayoutForAllViews()
        
    }
    
    
    private func AutoLayoutForAllViews() {
        
        // For canvas
        canvas.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalTo(view)
            make.bottom.equalTo(toolBarView.snp.top)
        }
        
        // For Toolbar
        toolBarView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(view)
            make.height.equalTo(100)
            make.bottomMargin.equalTo(view).offset(10)
        }
        
        // For Colors View
        colorSlider.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(toolBarView).inset(20)
            make.height.equalTo(15)
            make.top.equalTo(toolBarView).offset(5)
        }
        
        // For Undo Button
        btnUndo.snp.makeConstraints { (make) in
            make.leading.equalTo(toolBarView).inset(10)
            make.top.equalTo(colorSlider.snp.bottom).offset(15)
            make.height.equalTo(25)
        }
        
        // For Clear Button
        btnClear.snp.makeConstraints { (make) in
            make.leading.equalTo(btnUndo.snp.trailing).offset(5)
            make.top.equalTo(btnUndo)
            make.height.equalTo(25)
        }
        
        // For Brush Size Slider
        slider.snp.makeConstraints { (make) in
            make.leading.equalTo(btnClear.snp.trailing).offset(5)
            make.trailing.equalTo(toolBarView).inset(10)
            make.top.equalTo(btnUndo)
            make.height.equalTo(25)
        }
        
        // For Loader
        activityIndicator.snp.makeConstraints { (make) in
            make.width.height.equalTo(100)
            make.center.equalTo(view)
        }
    }
    
    
    //MARK: Uploading the image to Firebase Storage
    @objc func btnSaveTapped() {
        self.activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        
        if canvas.lines.count > 0 {
            guard let image = canvas.generateImage(), let data = image.jpegData(compressionQuality: 1.0) else {
                let alert = UIAlertController(title: "", message: "Something went wrong, try again", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default))
                self.present(alert, animated: true, completion: nil)
                self.activityIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
                return
            }
            
            let imageId = UUID().uuidString
            
            let imageRef = globalConstants.storageRef.child(imageId)
            
            imageRef.putData(data, metadata: nil) { (metadata, err) in
                if err != nil {
                    let alert = UIAlertController(title: "", message: "\(err!.localizedDescription)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default))
                    self.present(alert, animated: true, completion: nil)
                    self.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    return
                }
                
                imageRef.downloadURL { (url, err) in
                    if err != nil {
                        let alert = UIAlertController(title: "", message: "\(err!.localizedDescription)", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default))
                        self.present(alert, animated: true, completion: nil)
                        self.activityIndicator.stopAnimating()
                        self.view.isUserInteractionEnabled = true
                        return
                    }
                    
                    let value = ["imgURL" : "\(url!.absoluteString)"]
                    
                    let ref = globalConstants.firestoreRef.collection("Sketches").document(imageId)
                    ref.setData(value) { (err) in
                        if err != nil {
                            let alert = UIAlertController(title: "", message: "\(err!.localizedDescription)", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .default))
                            self.present(alert, animated: true, completion: nil)
                            self.activityIndicator.stopAnimating()
                            self.view.isUserInteractionEnabled = true
                            return
                        }
                        
                        let alert = UIAlertController(title: "", message: "Successfully Saved your Sketch!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default))
                        self.present(alert, animated: true, completion: nil)
                        self.activityIndicator.stopAnimating()
                        self.view.isUserInteractionEnabled = true
                        
                    }
                }
            }
        }else{
            let alert = UIAlertController(title: "Empty Canvas", message: "Cannot Save a Empty Canvas", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            self.present(alert, animated: true, completion: nil)
            self.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
        }
    }
    
    //MARK: Managing Brush Size
    @objc func manageBrushSliderChange() {
        canvas.setStrokeWidth(width: slider.value)
    }
    
    //MARK: Managing Brush Color Change
    @objc func manageColorSliderChange(slider: ColorSlider) {
        canvas.setStrokeColor(color: slider.color)
    }
    
    //MARK: UNDO Button Action
    @objc func btnUndoTapped() {
        print(canvas.lines.count)
        if canvas.lines.count > 0 {
            canvas.lines.removeLast()
            canvas.setNeedsDisplay()
        }
    }
    
    //MARK: CLEAR Button Action
    @objc func btnClearTapped() {
        canvas.lines.removeAll()
        canvas.setNeedsDisplay()
    }
}

//MARK: Saving Canvas In Image Format
extension UIView {
    func generateImage() -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
     
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if image != nil {
            return image
        }
        return UIImage()
    }
    
}
