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
    func enable() -> Bool
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
    
    public func enable() -> Bool {
        if CLLocationManager.locationServicesEnabled()
            && (CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse) {
            locationManager.startUpdatingLocation()
            locationManager.allowsBackgroundLocationUpdates = true
            return true
        } else {
            requestPermission()
            return false
        }
    }

    public func disable() {
        locationManager.stopUpdatingLocation()
    }
    
    @objc
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("xxxxxxxxxxxxxxx")
        print(locations)
        print("***************")
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
        
    public func enable() -> Bool  {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
            return false
        }
        audioPlayer?.play()
        return true
    }

    public func disable() {
        audioPlayer?.pause()
    }
    
    public func isEnabled() -> Bool {
        return audioPlayer?.isPlaying ?? false
    }
    
}
