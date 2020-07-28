//
//  BackgroundHelper.swift
//  BackgroundAppPressureTest
//
//  Created by jianjun on 2020-07-28.
//  Copyright © 2020 Jianjun. All rights reserved.
//

import Foundation
import CoreLocation
import AVFoundation

protocol BackgroundHelper {
    func enable()
    func disable()
}

class LocationBackgroundHelper : NSObject, CLLocationManagerDelegate, BackgroundHelper {
    
    static let shared = LocationBackgroundHelper()
    let locationManager: CLLocationManager
    
    private override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
    }
    
    public func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    public func enable() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        } else {
            requestPermission();
        }
    }

    public func disable() {
        locationManager.stopUpdatingLocation()
    }
    
    @objc
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
}


class MusicBackgroundHelper : NSObject, CLLocationManagerDelegate {
    
    static let shared = MusicBackgroundHelper()
    var audioPlayer: AVAudioPlayer?
    
    private override init() {
        super.init()

        let url = Bundle.main.url(forResource: "testaudio", withExtension: "mp3")!
        do {
            audioPlayer = try AVAudioPlayer(data: Data.init(contentsOf: url))
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.prepareToPlay()
        } catch {
            print("Cannot play the file")
        }
    }
        
    public func enable() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        audioPlayer?.play()
    }

    public func disable() {
        audioPlayer?.pause()
    }
    
    public func isEnabled() -> Bool {
        return audioPlayer?.isPlaying ?? false
    }
    
}
