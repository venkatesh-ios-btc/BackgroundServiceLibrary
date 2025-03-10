// BackgroundServiceLibrary.swift
// A fresh library that provides background services such as audio playback,
// location tracking, image download/upload, API calls, and supports custom tasks.

import Foundation
import AVFoundation
import CoreLocation
import BackgroundTasks
import UIKit

// MARK: - BackgroundServiceLibrary

// Use @unchecked Sendable to suppress Swift concurrency warnings.
// WARNING: Verify that you are managing mutable state safely.

public class BackgroundService: NSObject, CLLocationManagerDelegate {
    
    // Singleton instance.
    public static let shared = BackgroundService()
    
    // MARK: - Private Properties
    
    private var audioPlayer: AVAudioPlayer?
    private var locationManager: CLLocationManager?
    
    // Dictionary to store custom background tasks.
    // The closures are marked as @Sendable.
    private var customTasks: [BackgroundTaskType: @Sendable () -> Void] = [:]
    
    // Private initializer to enforce singleton usage.
    private override init() {
        super.init()
    }
    
    // MARK: - Standard Background Tasks
    
    /// Starts a predefined background task based on the provided type.
    public func performBackgroundTask(_ taskType: BackgroundTaskType) {
        switch taskType {
        case .audio:
            playBackgroundAudio()
        case .locationTracking:
            startLocationTracking()
        case .apiCall:
            scheduleBackgroundAPICall()
        case .imageDownload:
            downloadImage()
        case .imageUpload:
            uploadImage()
        default:
            print("No predefined task for \(taskType.rawValue)")
        }
    }
    
    /// Stops a predefined background task based on the provided type.
    public func stopBackgroundTask(_ taskType: BackgroundTaskType) {
        switch taskType {
        case .audio:
            stopAudio()
        case .locationTracking:
            stopLocationTracking()
        default:
            print("\(taskType.rawValue) task stopped.")
        }
    }
    
    // MARK: - Custom Background Tasks
    
    /**
     Executes a custom background task provided by the user.
     
     - Parameters:
       - taskType: A type to identify the custom task.
       - task: A closure containing the custom logic to execute.
     */
    public func performCustomBackgroundTask(_ taskType: BackgroundTaskType, task: @escaping @Sendable () -> Void) {
        // Save the custom task.
        customTasks[taskType] = task
        
        // Execute the custom task on a global background queue.
        DispatchQueue.global(qos: .background).async { [taskType] in
            print("Starting custom background task: \(taskType.rawValue)")
            task()
            print("Finished custom background task: \(taskType.rawValue)")
        }
    }
    
    // MARK: - Predefined Task Implementations
    
    // MARK: Audio Playback
    
    private func playBackgroundAudio() {
        guard let url = Bundle.main.url(forResource: "background", withExtension: "mp3") else {
            print("Audio file 'background.mp3' not found in bundle")
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
            audioPlayer?.play()
            print("Background Audio Started")
        } catch {
            print("Error starting audio: \(error.localizedDescription)")
        }
    }
    
    private func stopAudio() {
        audioPlayer?.stop()
        print("Background Audio Stopped")
    }
    
    // MARK: Location Tracking
    
    private func startLocationTracking() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.startUpdatingLocation()
        print("Location Tracking Started")
    }
    
    private func stopLocationTracking() {
        locationManager?.stopUpdatingLocation()
        print("Location Tracking Stopped")
    }
    
    // CLLocationManagerDelegate method.
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("Updated Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
    }
    
    // MARK: Image Download & Upload
    
    private func downloadImage() {
        guard let url = URL(string: "https://example.com/sample-image.jpg") else { return }
        let downloadTask = URLSession.shared.downloadTask(with: url) { location, response, error in
            guard let location = location, error == nil else {
                print("Image Download Failed: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            print("Image Downloaded Successfully at: \(location)")
        }
        downloadTask.resume()
    }
    
    private func uploadImage() {
        guard let image = UIImage(named: "uploadImage"),
              let imageData = image.jpegData(compressionQuality: 0.8),
              let url = URL(string: "https://example.com/upload") else {
            print("Failed to prepare image upload")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        let uploadTask = URLSession.shared.uploadTask(with: request, from: imageData) { data, response, error in
            if let error = error {
                print("Image Upload Failed: \(error.localizedDescription)")
            } else {
                print("Image Uploaded Successfully")
            }
        }
        uploadTask.resume()
    }
    
    // MARK: API Call
    
    private func scheduleBackgroundAPICall() {
        let taskIdentifier = "com.background.api.fetch"
        
        // Ensure BGTaskScheduler is only used on iOS 13 and later
        if #available(iOS 13.0, *) {
            BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
                self.fetchDataFromAPI()
                task.setTaskCompleted(success: true)
            }
            
            do {
                let request = BGProcessingTaskRequest(identifier: taskIdentifier)
                request.requiresNetworkConnectivity = true
                request.earliestBeginDate = Date(timeIntervalSinceNow: 60) // 1-minute delay
                
                try BGTaskScheduler.shared.submit(request)
                print("Scheduled Background API Fetch")
            } catch {
                print("Failed to schedule API fetch: \(error.localizedDescription)")
            }
        } else {
            print("BGTaskScheduler is not supported on this iOS version.")
            // Fallback: Execute API fetch immediately for older iOS versions
            fetchDataFromAPI()
        }
    }
    
    public func fetchDataFromAPI() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/todos/1") else { return }
        let apiTask = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data,
               let jsonResponse = String(data: data, encoding: .utf8) {
                print("API Response: \(jsonResponse)")
            } else {
                print("API Call Failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
        apiTask.resume()
    }
}

// MARK: - BackgroundTaskType Enum

public enum BackgroundTaskType: String {
    case audio = "Audio"
    case video = "Video"
    case locationTracking = "Location Tracking"
    case imageDownload = "Image Download"
    case imageUpload = "Image Upload"
    case apiCall = "API Call"
    case custom = "Custom Task"
}
