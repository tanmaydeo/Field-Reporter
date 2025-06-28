//
//  CameraViewController.swift
//  Field Reporter
//
//  Created by Tanmay Deo on 27/06/25.
//

import UIKit
import AVFoundation

protocol CameraViewControllerDelegate: AnyObject {
    func cameraViewController(_ controller: CameraViewController, didFinishRecordingTo url: URL)
}

final class CameraViewController: UIViewController {
    
    weak var delegate: CameraViewControllerDelegate?
    
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureMovieFileOutput()
    private var activeVideoInput: AVCaptureDeviceInput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    private let recordButton = UIButton()
    private let dismissButton = UIButton(type: .system)
    
    private let sessionQueue = DispatchQueue(label: "com.fieldReporter.cameraSession")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        configureCaptureSession()
        startSession()
    }
    
    private func setupView() {
        setupHierarchy()
        setupStyles()
        setupConstraints()
    }
    
    private func setupHierarchy() {
        view.addSubview(recordButton)
        view.addSubview(dismissButton)
    }
    
    private func setupStyles() {
        //View
        view.backgroundColor = .black
        
        // Record Button
        recordButton.backgroundColor = .white
        recordButton.layer.cornerRadius = 35
        recordButton.layer.masksToBounds = true
        recordButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        recordButton.setTitle("Record", for: .normal)
        recordButton.setTitleColor(.black, for: .normal)
        recordButton.addTarget(self, action: #selector(toggleRecording), for: .touchUpInside)
        
        // Dismiss Button
        dismissButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        dismissButton.tintColor = .white
        dismissButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            recordButton.widthAnchor.constraint(equalToConstant: 70),
            recordButton.heightAnchor.constraint(equalToConstant: 70),
            
            dismissButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 16),
            dismissButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            dismissButton.widthAnchor.constraint(equalToConstant: 40),
            dismissButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func configureCaptureSession() {
        sessionQueue.async {
            self.captureSession.beginConfiguration()
            self.captureSession.sessionPreset = .high
            
            if let camera = AVCaptureDevice.default(for: .video),
               let videoInput = try? AVCaptureDeviceInput(device: camera),
               self.captureSession.canAddInput(videoInput) {
                self.captureSession.addInput(videoInput)
                self.activeVideoInput = videoInput
            }
            
            if let mic = AVCaptureDevice.default(for: .audio),
               let micInput = try? AVCaptureDeviceInput(device: mic),
               self.captureSession.canAddInput(micInput) {
                self.captureSession.addInput(micInput)
            }
            
            if self.captureSession.canAddOutput(self.videoOutput) {
                self.captureSession.addOutput(self.videoOutput)
            }
            
            self.captureSession.commitConfiguration()
        }
    }
    
    private func startSession() {
        sessionQueue.async {
            self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.setupPreviewLayer()
            }
        }
    }
    
    private func setupPreviewLayer() {
        let preview = AVCaptureVideoPreviewLayer(session: captureSession)
        preview.frame = view.bounds
        preview.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(preview, at: 0)
        self.previewLayer = preview
    }
    
    // MARK: - User Interaction
    
    @objc func toggleRecording() {
        sessionQueue.async {
            if self.videoOutput.isRecording {
                self.videoOutput.stopRecording()
                DispatchQueue.main.async {
                    self.recordButton.setTitle("Record", for: .normal)
                }
            } else {
                let outputURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension("mov")
                
                self.videoOutput.startRecording(to: outputURL, recordingDelegate: self)
                
                DispatchQueue.main.async {
                    self.recordButton.setTitle("Stop", for: .normal)
                }
            }
        }
    }
    
    @objc func dismissView() {
        dismiss(animated: true)
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection],
                    error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                print("Recording error: \(error.localizedDescription)")
            } else {
                self.delegate?.cameraViewController(self, didFinishRecordingTo: outputFileURL)
            }
            self.dismiss(animated: true)
        }
    }
}
