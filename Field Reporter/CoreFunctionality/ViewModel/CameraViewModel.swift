//
//  CameraViewModel.swift
//  Field Reporter
//
//  Created by Tanmay Deo on 30/06/25.
//

import UIKit
import AVFoundation

protocol CameraViewModelDelegate: AnyObject {
    func updateRecordingTime(_ time: String)
    func recordingDidFinish(url: URL, duration: Int)
    func recordingDidFail(with error: Error)
    func cameraPermissionDenied()
    func recordingStarted()
    func recordingStopped()
}

class CameraViewModel: NSObject {
    
    // MARK: - Properties
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureMovieFileOutput()
    private var activeVideoInput: AVCaptureDeviceInput?
    private let sessionQueue = DispatchQueue(label: "com.fieldReporter.cameraSession")
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    weak var delegate: CameraViewModelDelegate?
    
    private var recordingTimer: Timer?
    private var elapsedSeconds = 0
    
    var isRecording: Bool {
        videoOutput.isRecording
    }
    
    // MARK: - Setup
    func configureSession() {
        sessionQueue.async {
            self.captureSession.beginConfiguration()
            self.captureSession.sessionPreset = .high
            
            defer { self.captureSession.commitConfiguration() }
            
            guard let camera = AVCaptureDevice.default(for: .video),
                  let videoInput = try? AVCaptureDeviceInput(device: camera),
                  self.captureSession.canAddInput(videoInput) else {
                return
            }
            
            self.captureSession.addInput(videoInput)
            self.activeVideoInput = videoInput
            
            if let mic = AVCaptureDevice.default(for: .audio),
               let micInput = try? AVCaptureDeviceInput(device: mic),
               self.captureSession.canAddInput(micInput) {
                self.captureSession.addInput(micInput)
            }
            
            if self.captureSession.canAddOutput(self.videoOutput) {
                self.captureSession.addOutput(self.videoOutput)
            }
        }
    }
    
    func startSession() {
        sessionQueue.async {
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        sessionQueue.async {
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
    }
    
    func getPreviewLayer(for view: UIView) -> AVCaptureVideoPreviewLayer {
        if previewLayer == nil {
            let layer = AVCaptureVideoPreviewLayer(session: captureSession)
            layer.videoGravity = .resizeAspectFill
            layer.frame = view.bounds
            previewLayer = layer
        }
        return previewLayer!
    }
    
    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            delegate?.recordingStopped()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.delegate?.recordingStopped()
                    } else {
                        self.delegate?.cameraPermissionDenied()
                    }
                }
            }
        case .denied, .restricted:
            delegate?.cameraPermissionDenied()
        @unknown default:
            delegate?.cameraPermissionDenied()
        }
    }
    
    // MARK: - Recording
    func startRecording() {
        guard !videoOutput.isRecording else { return }
        
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mov")
        
        videoOutput.startRecording(to: outputURL, recordingDelegate: self)
    }
    
    func stopRecording() {
        guard videoOutput.isRecording else { return }
        videoOutput.stopRecording()
    }
    
    // MARK: - Timer
    private func startRecordingTimer() {
        recordingTimer?.invalidate()
        elapsedSeconds = 0
        delegate?.updateRecordingTime("00:00")
        
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedSeconds += 1
            
            let min = self.elapsedSeconds / 60
            let sec = self.elapsedSeconds % 60
            self.delegate?.updateRecordingTime(String(format: "%02d:%02d", min, sec))
            
            if self.elapsedSeconds >= 30 {
                self.stopRecording()
            }
        }
    }
    
    private func stopRecordingTimer() {
        recordingTimer?.invalidate()
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate
extension CameraViewModel: AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput,
                    didStartRecordingTo fileURL: URL,
                    from connections: [AVCaptureConnection]) {
        DispatchQueue.main.async {
            self.startRecordingTimer()
            self.delegate?.recordingStarted()
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection],
                    error: Error?) {
        DispatchQueue.main.async {
            self.stopRecordingTimer()
            if let error = error {
                self.delegate?.recordingDidFail(with: error)
            } else {
                self.delegate?.recordingDidFinish(url: outputFileURL, duration: self.elapsedSeconds)
            }
        }
    }
}
