//
//  CameraViewController.swift
//  Field Reporter
//
//  Created by Tanmay Deo on 27/06/25.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    // MARK: - AVFoundation Properties
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureMovieFileOutput()
    private var activeVideoInput: AVCaptureDeviceInput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var isSessionConfigured = false
    
    // MARK: - UI Elements
    private let recordButton = UIButton()
    private let dismissButton = UIButton(type: .custom)
    private let videoTimerLabel = PaddedLabel()
    
    // MARK: - Recording Timer
    private var recordingTimer: Timer?
    private var elapsedSeconds = 0
    
    // MARK: - Other
    private let sessionQueue = DispatchQueue(label: "com.fieldReporter.cameraSession")
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        configureCaptureSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar()
        startCaptureSession()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopCaptureSession()
    }
    
    private func setupView() {
        view.backgroundColor = .black
        addSubviews()
        styleSubviews()
        layoutSubviews()
    }
    
    private func addSubviews() {
        view.addSubview(recordButton)
        view.addSubview(dismissButton)
        view.addSubview(videoTimerLabel)
    }
    
    private func styleSubviews() {
        // Record Button
        recordButton.backgroundColor = .white
        recordButton.layer.cornerRadius = 35
        recordButton.layer.masksToBounds = true
        recordButton.addTarget(self, action: #selector(startRecording), for: .touchDown)
        recordButton.addTarget(self, action: #selector(stopRecording), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        // Dismiss Button
        dismissButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        dismissButton.tintColor = .white
        dismissButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        
        // Timer Label
        videoTimerLabel.text = "00:00"
        videoTimerLabel.textColor = .white
        videoTimerLabel.font = UIFont.systemFont(ofSize: 16, weight: .black)
        videoTimerLabel.backgroundColor = .systemRed
        videoTimerLabel.layer.cornerRadius = 8
        videoTimerLabel.clipsToBounds = true
        videoTimerLabel.isHidden = true
    }
    
    private func layoutSubviews() {
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        videoTimerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            recordButton.widthAnchor.constraint(equalToConstant: 70),
            recordButton.heightAnchor.constraint(equalToConstant: 70),
            
            dismissButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 16),
            dismissButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            dismissButton.widthAnchor.constraint(equalToConstant: 40),
            dismissButton.heightAnchor.constraint(equalToConstant: 40),
            
            videoTimerLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 16),
            videoTimerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

// MARK: - Camera Configuration
extension CameraViewController {
    
    private func configureCaptureSession() {
        guard !isSessionConfigured else { return }
        isSessionConfigured = true
        
        sessionQueue.async {
            self.captureSession.beginConfiguration()
            self.captureSession.sessionPreset = .high
            
            // Camera input
            if let camera = AVCaptureDevice.default(for: .video),
               let videoInput = try? AVCaptureDeviceInput(device: camera),
               self.captureSession.canAddInput(videoInput) {
                self.captureSession.addInput(videoInput)
                self.activeVideoInput = videoInput
            }
            
            // Microphone input
            if let mic = AVCaptureDevice.default(for: .audio),
               let micInput = try? AVCaptureDeviceInput(device: mic),
               self.captureSession.canAddInput(micInput) {
                self.captureSession.addInput(micInput)
            }
            
            // Output
            if self.captureSession.canAddOutput(self.videoOutput) {
                self.captureSession.addOutput(self.videoOutput)
            }
            
            self.captureSession.commitConfiguration()
        }
    }
    
    private func startCaptureSession() {
        sessionQueue.async {
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
                DispatchQueue.main.async {
                    self.setupPreviewLayer()
                }
            }
        }
    }
    
    private func stopCaptureSession() {
        sessionQueue.async {
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
    }
    
    private func setupPreviewLayer() {
        guard previewLayer == nil else { return }
        
        let preview = AVCaptureVideoPreviewLayer(session: captureSession)
        preview.frame = view.bounds
        preview.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(preview, at: 0)
        previewLayer = preview
    }
}

// MARK: - Recording Logic
extension CameraViewController {
    
    @objc private func startRecording() {
        sessionQueue.async {
            guard !self.videoOutput.isRecording else { return }
            
            let outputURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("mov")
            
            self.videoOutput.startRecording(to: outputURL, recordingDelegate: self)
            
            DispatchQueue.main.async {
                self.animateRecordButton(isRecording: true)
                self.videoTimerLabel.isHidden = false
                
                let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
                feedbackGenerator.prepare()
                feedbackGenerator.impactOccurred()
            }
        }
    }
    
    @objc private func stopRecording() {
        sessionQueue.async {
            guard self.videoOutput.isRecording else { return }
            
            self.videoOutput.stopRecording()
            DispatchQueue.main.async {
                self.recordingTimer?.invalidate()
                self.videoTimerLabel.isHidden = true
                self.videoTimerLabel.text = "00:00"
                self.animateRecordButton(isRecording: false)
            }
        }
    }
}

// MARK: - Timer Logic
extension CameraViewController {
    
    private func startRecordingTimer() {
        recordingTimer?.invalidate()
        elapsedSeconds = 0
        updateTimerLabel()
        
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedSeconds += 1
            self.updateTimerLabel()
            
            if self.elapsedSeconds >= 30 {
                self.recordingTimer?.invalidate()
                self.stopRecording()
            }
        }
    }
    
    private func updateTimerLabel() {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        videoTimerLabel.text = String(format: "%02d:%02d", minutes, seconds)
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
                self.navigationController?.pushViewController(
                    VideoPreviewViewController(videoURL: outputFileURL),
                    animated: false
                )
            }
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput,
                    didStartRecordingTo fileURL: URL,
                    from connections: [AVCaptureConnection]) {
        DispatchQueue.main.async {
            self.startRecordingTimer()
        }
    }
}

// MARK: - Utilities
extension CameraViewController {
    private func hideNavigationBar() {
        navigationController?.navigationBar.isHidden = true
    }
    
    @objc private func dismissView() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Button Animation
extension CameraViewController {
    
    private func animateRecordButton(isRecording: Bool) {
        let scale: CGFloat = isRecording ? 1.5 : 1.0
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [.curveEaseInOut], animations: {
            self.recordButton.backgroundColor = isRecording ? .red : .white
            self.recordButton.transform = CGAffineTransform(scaleX: scale, y: scale)
        })
    }
    
}
