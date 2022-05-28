//
//  ViewController.swift
//  OverPlay task
//
//  Created by Magdy Khaled on 27/05/2022.
//

import UIKit
import AVFoundation
import CoreLocation
import CoreMotion
import MediaPlayer

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
    let motion = CMMotionManager()
    var timer: Timer!
    var oldX: Double!
    var oldZ: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startGyros()
        if isLocationServicesEnabled() {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    deinit {
        playerLooper = nil
        locationManager.stopUpdatingLocation()
        stopGyros()
    }
    
    
    func initializeView() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        playVideo()
    }
    
    override func becomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?){
        if motion == .motionShake {
            player.pause()
        }
    }

    
    func startGyros() {
        if motion.isGyroAvailable {
            self.motion.gyroUpdateInterval = 10.0 / 60.0
            self.motion.startGyroUpdates()
            self.timer = Timer(fire: Date(), interval: (10.0/60.0),
                               repeats: true, block: { (timer) in
                // Get the gyro data.
                if let data = self.motion.gyroData {
                    if self.oldX == nil {
                        self.oldX = self.motion.gyroData?.rotationRate.x
                    }
                    if self.oldZ == nil {
                        self.oldZ = self.motion.gyroData?.rotationRate.z
                    }
                    self.setVolume(newX: data.rotationRate.x )
                    self.setVideoPosition(newZ:data.rotationRate.z )
                }
            })
            RunLoop.current.add(self.timer!, forMode: .default)
        }
    }
    
    func setVolume(newX:Double) {
        let x = newX
        if x > self.oldX + 0.05 {
            let volume = self.player.volume
            if volume != 1 {
                self.player.volume = volume + 0.0625
            }
        } else if x < self.oldX + 0.05 {
            let volume = self.player.volume
            if volume != 0 {
                self.player.volume = volume - 0.0625
            }
        }
    }
    
    func setVideoPosition(newZ:Double) {
        let z = newZ
        if z > self.oldZ + 0.05 {
            guard let duration = player.currentItem?.duration else { return }
            let currentTime = CMTimeGetSeconds(player.currentTime())
            let newTime = currentTime + 5.0
            if newTime < (CMTimeGetSeconds(duration) - 5.0) {
                let time: CMTime = CMTimeMake(value: Int64(newTime*1000), timescale: 1000)
                player.seek(to: time)
            }
            
        } else if z < self.oldZ + 0.05 {
            if player.currentTime().value != 0 {
                let currentTime = CMTimeGetSeconds(player.currentTime())
                var newTime = currentTime - 5.0
                
                if newTime < 0 {
                    newTime = 0
                }
                let time: CMTime = CMTimeMake(value: Int64(newTime * 1000 ), timescale: 1000)
                player.seek(to: time)
            }
        }
    }
    
    func stopGyros() {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
            
            self.motion.stopGyroUpdates()
        }
    }
    
    func playVideo() {
        videoView.layer.sublayers = nil
        if let pathURL = URL(string: self.videoURL) {
            let duration = Int64(((Float64(CMTimeGetSeconds(AVAsset(url: pathURL).duration)) *  10.0) - 1) / 10.0 )
            player = AVQueuePlayer()
            playerLayer = AVPlayerLayer(player: player)
            playerItem = AVPlayerItem(url: pathURL)
            playerLooper = AVPlayerLooper(player: player, templateItem: playerItem,
                                          timeRange: CMTimeRange(start:  CMTime.zero, end: CMTimeMake(value: duration, timescale: 1)) )
            playerLayer.videoGravity = .resizeAspect
            try! AVAudioSession.sharedInstance().setCategory(.playback)
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
        if self.currentLocation.distance(from: oldLocation) > 9 {
            restartVideo()
        }
    }
}

