//
//  ViewController.swift
//  OverPlay task
//
//  Created by Magdy Khaled on 27/05/2022.
//

import UIKit
import AVFoundation
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var videoView: UIView!
    
    
    private var player: AVQueuePlayer!
    private var playerLayer: AVPlayerLayer!
    private var playerItem: AVPlayerItem!
    private var playerLooper: AVPlayerLooper!
    private var locationManager: CLLocationManager!
    let videoURL = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4"
    var currentLocation: CLLocation!
    var oldLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        playVideo()
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 4
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Check for auth
        if isLocationServicesEnabled() {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        // Do other stuff
    }
    deinit {
        playerLooper = nil
        locationManager.stopUpdatingLocation()
    }
    
    func playVideo() {
        videoView.layer.sublayers = nil
        if let pathURL = URL(string: self.videoURL) {
            let duration = Int64( ( (Float64(CMTimeGetSeconds(AVAsset(url: pathURL).duration)) *  10.0) - 1) / 10.0 )
            player = AVQueuePlayer()
            playerLayer = AVPlayerLayer(player: player)
            playerItem = AVPlayerItem(url: pathURL)
            playerLooper = AVPlayerLooper(player: player, templateItem: playerItem,
                                          timeRange: CMTimeRange(start:  CMTime.zero, end: CMTimeMake(value: duration, timescale: 1)) )
            playerLayer.videoGravity = .resizeAspectFill
            playerLayer.frame = videoView.layer.bounds
            videoView.layer.insertSublayer(playerLayer, at: 1)
            player.play()
            
            
        }
    }
    func restartVideo() {
        self.player.seek(to: CMTime.zero)
        self.player.play()
    }
    func isLocationServicesEnabled() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                return false
            case .authorizedAlways, .authorizedWhenInUse:
                return true
            @unknown default:
                return false
            }
        }
        
        return false
    }
}

extension ViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        // Use location.latitude and location.longitude here
        // If you don't want to receive any more location data then call
        self.currentLocation = location
        
        if self.oldLocation == nil {
            self.oldLocation = location
        }
        if self.currentLocation.distance(from: oldLocation) > 3 {
            restartVideo()
        }
        
//        locationManager.stopUpdatingLocation()
    }
}
