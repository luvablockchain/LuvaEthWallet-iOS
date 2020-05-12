//
//  ScanQRCodeViewController.swift
//  LuvaEthWallet
//
//  Created by Nguyen Xuan Khang on 4/21/20.
//  Copyright © 2020 Nguyen Xuan Khang. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox
import PKHUD
import web3swift

protocol ScanQRCodeViewControllerDelegate:NSObject {
    func didScanQRCodeSuccess(address:String)
}

class ScanQRCodeViewController: BaseViewController {
    
    @IBOutlet weak var lblCreateQRCode: UILabel!
    
    @IBOutlet weak var lblScanQRCode: UILabel!
    
    @IBOutlet weak var vCreateQrCode: UIView!
    
    @IBOutlet weak var vQrCode: UIView!
    
    @IBOutlet weak var btnCreateQrCode: UIButton!
    
    @IBOutlet weak var btnScanQrCode: UIButton!
    
    @IBOutlet weak var lblPhoto: UILabel!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var vPhoto: UIView!
    
    @IBOutlet weak var imgFlash: UIImageView!
    
    @IBOutlet weak var vFlash: UIView!
    
    @IBOutlet weak var btnBack: UIButton!
    
    @IBOutlet weak var btnScanQRInLib: UIButton!
    
    @IBOutlet weak var focusImage: UIImageView!
    
    @IBOutlet weak var cameraView: UIView!
    
    @IBOutlet weak var imgPhoto: UIImageView!
    
    @IBOutlet weak var lblFlash: UILabel!
    
    @IBOutlet weak var btnFlash: UIButton!
    
    @IBOutlet weak var vfoscus: UIView!
    
    @IBOutlet weak var contrainsTop: NSLayoutConstraint!
    
    @IBOutlet weak var contrainsBottom: NSLayoutConstraint!
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var imagePicker = UIImagePickerController()
    
    weak var delegate: ScanQRCodeViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTitle.text = "Scan QRCode".localizedString()
        lblPhoto.text = "Use available images".localizedString()
        lblFlash.text = "Turn on Flash".localizedString()
        vPhoto.layer.cornerRadius = 5
        vPhoto.layer.masksToBounds = true
        vPhoto.backgroundColor = .clear
        btnScanQRInLib.backgroundColor = UIColor.lightGray
        btnScanQRInLib.alpha = 0.5
        setupVideoPreviewLayer()
        navigationController?.setNavigationBarHidden(true, animated: false)
        let imgCancel = UIImage.init(named: "ic_exit")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        btnBack.setImage(imgCancel, for: .normal)
        btnBack.tintColor = .lightGray
        imagePicker.delegate = self
        btnFlash.layer.cornerRadius = 0.5 * btnFlash.bounds.size.width
        vFlash.layer.backgroundColor = UIColor.lightGray.cgColor
        vFlash.layer.cornerRadius = 0.5 * btnFlash.bounds.size.width
        let imgFocus = UIImage.init(named: "ic_focus")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        focusImage.image = imgFocus
        focusImage.tintColor = BaseViewController.MainColor
        let photo = UIImage.init(named: "ic_photo")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        imgPhoto.image = photo
        imgPhoto.tintColor = .white
        btnBack.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupViewAnimation()
        NotificationCenter.default.addObserver(self, selector:#selector(self.didChangeCaptureInputPortFormatDescription(notification:)), name: NSNotification.Name.AVCaptureInputPortFormatDescriptionDidChange, object: nil)
        self.startScanQRcode()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.contrainsTop.isActive = true
        self.contrainsBottom.isActive = false
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVCaptureInputPortFormatDescriptionDidChange, object: nil)
    }
    
    func setupViewAnimation() {
        UIView.animate(withDuration: 3.0, delay: 0.0, options: [.autoreverse,.repeat], animations: {
            self.contrainsTop.isActive = false
            self.contrainsBottom = self.vfoscus.bottomAnchor.constraint(equalTo: self.focusImage.bottomAnchor)
            self.contrainsBottom.isActive = true
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func setupVideoPreviewLayer() {
        self.view.layoutIfNeeded()
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            captureSession = AVCaptureSession()
            captureSession!.addInput(input)
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession!.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr,.ean8, .ean13, .pdf417, .code128]
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.cameraView.layer.addSublayer(videoPreviewLayer!)
            
            let layerRect = self.cameraView.layer.bounds
            self.videoPreviewLayer?.frame = layerRect
            self.videoPreviewLayer?.position = CGPoint(x: layerRect.midX, y: layerRect.midY)
            if self.captureSession?.isRunning == false {
                self.captureSession?.startRunning()
            }
            view.bringSubviewToFront(self.focusImage)
        } catch {
            return
        }
    }
    
    func showAlertWith(content: String) {
        let alertController = UIAlertController(title: "Content Qr Code", message: content, preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "Ok", style: .default) { (alert) in
            self.startScanQRcode()
        }
        alertController.addAction(actionOk)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func startScanQRcode() {
        if self.captureSession?.isRunning == false {
            self.captureSession?.startRunning()
        }
    }
    
    func stopScanQRcode() {
        if self.captureSession?.isRunning == true {
            self.captureSession?.stopRunning()
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    
    @objc func didChangeCaptureInputPortFormatDescription(notification: NSNotification) {
        if let metadataOutput = self.captureSession?.outputs.last as? AVCaptureMetadataOutput,
            let rect = self.videoPreviewLayer?.metadataOutputRectConverted(fromLayerRect: self.focusImage.frame) {
            metadataOutput.rectOfInterest = rect
        }
    }
    
    @IBAction func tappedOpenPhotoLibrary(_ sender: Any) {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func tappedBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
        
    @IBAction func tappedSelectFlash(_ sender: Any) {
        let avDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        if avDevice!.hasTorch {
            do {
                _ = try avDevice!.lockForConfiguration()
                lblFlash.text = "Turn off Flash".localizedString()
                vFlash.layer.backgroundColor = BaseViewController.MainColor.cgColor
                let flash = UIImage.init(named: "ic_flash")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                imgFlash.image = flash
                imgFlash.tintColor = UIColor.white
            } catch {
                HUD.flash(.label("Some thing went wrong.".localizedString()), delay: 1.0)
            }
            
            if avDevice!.isTorchActive {
                avDevice!.torchMode = AVCaptureDevice.TorchMode.off
                lblFlash.text = "Turn on Flash".localizedString()
                vFlash.layer.backgroundColor = UIColor.lightGray.cgColor
                let flash = UIImage.init(named: "ic_flashoff")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                imgFlash.image = flash
                imgFlash.tintColor = UIColor.black
            } else {
                do {
                    _ = try avDevice!.setTorchModeOn(level: 1.0)
                } catch {
                    HUD.flash(.label("Some thing went wrong.".localizedString()), delay: 1.0)
                }
            }
            avDevice!.unlockForConfiguration()
        }
    }
}

extension ScanQRCodeViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if let value = metadataObj.stringValue, metadataObj.type == AVMetadataObject.ObjectType.qr {
            if EthereumAddress(value) != nil {
                self.dismiss(animated: true, completion: nil)
                delegate?.didScanQRCodeSuccess(address: value)
            } else {
                self.dismiss(animated: true, completion: nil)
                HUD.flash(.label("Invalid address.".localizedString()), delay: 1.0)
            }
        } else {
            self.dismiss(animated: true, completion: nil)
            HUD.flash(.label("Some thing went wrong. Please try again".localizedString()), delay: 1.0)
        }
        self.stopScanQRcode()
    }
    
}
extension ScanQRCodeViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var qrCode = ""
        if let qrcodeImg = info[.editedImage] as? UIImage {
            let detector:CIDetector=CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])!
            let ciImage:CIImage=CIImage(image:qrcodeImg)!
            
            let features=detector.features(in: ciImage)
            for feature in features as! [CIQRCodeFeature] {
                qrCode += feature.messageString!
            }
            if qrCode == "" {
                self.dismiss(animated: true, completion: nil)
                HUD.flash(.label("Some thing went wrong. Please try again".localizedString()), delay: 1.0)
            } else {
                if EthereumAddress(qrCode) != nil {
                    self.dismiss(animated: true, completion: nil)
                    self.dismiss(animated: true, completion: nil)
                    delegate?.didScanQRCodeSuccess(address: qrCode)
                    self.stopScanQRcode()
                } else {
                    self.dismiss(animated: true, completion: nil)
                    HUD.flash(.label("Invalid address.".localizedString()), delay: 1.0)
                }
            }
        } else {
            self.dismiss(animated: true, completion: nil)
            HUD.flash(.label("Some thing went wrong. Please try again".localizedString()), delay: 1.0)
        }
    }
}
