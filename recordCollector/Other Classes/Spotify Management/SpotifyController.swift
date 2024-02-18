//
//  SpotifyController.swift
//  recordCollector
//
//  Created by Hannah Adams on 1/27/24.
//

import SwiftUI
import SpotifyiOS
import Combine

class SpotifyController: NSObject, ObservableObject {
    let spotifyClientID = SpotifyConfiguration.spotifyClientID
    let spotifyRedirectURL = SpotifyConfiguration.spotifyRedirectURL
    
    var accessToken: String? = nil
    
    @Published var currentPlaying: String = ""
    @Published var playerPaused: Bool = false
    
    @Published var connectionFailure: Bool = false
    
    private var connectCancellable: AnyCancellable?
    
    private var disconnectCancellable: AnyCancellable?
    
    override init() {
        print("INIT")
        super.init()
        connectCancellable = NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                print("FIRST")
                self.connect()
            }
        
        disconnectCancellable = NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                print("SECOND")
                self.disconnect()
            }

    }
        
    lazy var configuration = SPTConfiguration(
        clientID: spotifyClientID,
        redirectURL: spotifyRedirectURL
    )

    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = self.accessToken
        appRemote.delegate = self
        return appRemote
    }()
    
    func setAccessToken(from url: URL) {
        print("SETTING TOKEN")
        let parameters = appRemote.authorizationParameters(from: url)
        
        if let accessToken = parameters?[SPTAppRemoteAccessTokenKey] {
            appRemote.connectionParameters.accessToken = accessToken
            self.accessToken = accessToken
            print("Setting Access Token: ",accessToken)
        } else if let errorDescription = parameters?[SPTAppRemoteErrorDescriptionKey] {
            print(errorDescription)
        }
        
    }
    
    func connect() {
        guard let _ = self.appRemote.connectionParameters.accessToken else {
            self.appRemote.authorizeAndPlayURI("")
            return
        }
        appRemote.connect()
    }
    
    func disconnect() {
        if appRemote.isConnected {
            appRemote.disconnect()
            connectionFailure = true
        }
    }
}

extension SpotifyController: SPTAppRemoteDelegate {
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        self.appRemote = appRemote
        self.appRemote.playerAPI?.delegate = self
        self.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
            
        })
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        connectionFailure = true
        print("failed", connectionFailure)
//        self.accessToken = nil
//        self.appRemote.connect()
        
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("disconnected")

    }
}

extension SpotifyController {
    func playFromSpotify(uri: String) {
        if appRemote.isConnected {
            appRemote.playerAPI?.setShuffle(false, callback: { [self] (result, error) in
                if let error = error {
                    debugPrint("Error setting shuffle: \(error.localizedDescription)")
                } else {
                    // Play the album after setting shuffle to false
                    appRemote.playerAPI?.play(uri, callback: { (result, error) in
                        if let error = error {
                            debugPrint("Error playing album: \(error.localizedDescription)")
                        } else {
                            print("Playing Album")
                            debugPrint("Successfully played album!")
                        }
                    })
                }
            })
        } else {
            // Handle not connected error
            debugPrint("Error: Spotify App Remote is not connected.")
            appRemote.connect()
        }
    }
    func pauseSpotifyPlayback() {
        if appRemote.isConnected {
            appRemote.playerAPI?.pause { (result, error) in
                if let error = error {
                    debugPrint("Error pausing playback: \(error.localizedDescription)")
                } else {
                    print("Playback paused")
                }
            }
        } else {
            debugPrint("Error: Spotify App Remote is not connected.")
            // Handle the case where the app remote is not connected.
        }
    }
    func resumeSpotifyPlayback() {
        if appRemote.isConnected {
            appRemote.playerAPI?.resume { (result, error) in
                if let error = error {
                    debugPrint("Error resuming playback: \(error.localizedDescription)")
                } else {
                    print("Playback resumed")
                }
            }
        } else {
            debugPrint("Error: Spotify App Remote is not connected.")
            // Handle the case where the app remote is not connected.
        }
    }
}



extension SpotifyController: SPTAppRemotePlayerStateDelegate {
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        self.currentPlaying = playerState.contextURI.absoluteString
        self.playerPaused = playerState.isPaused
        
//        print("player state changed")
//        print("isPaused", playerState.isPaused)
//        print("track.uri", playerState.track.uri)
//        print("track.name", playerState.track.name)
//        print("track.imageIdentifier", playerState.track.imageIdentifier)
//        print("track.artist.name", playerState.track.artist.name)
//        print("track.album.name", playerState.track.album.name)
//        print("HERE", self.currentPlaying)
//        print("track.isSaved", playerState.track.isSaved)
//        print("playbackSpeed", playerState.playbackSpeed)
//        print("playbackOptions.isShuffling", playerState.playbackOptions.isShuffling)
//        print("playbackOptions.repeatMode", playerState.playbackOptions.repeatMode.hashValue)
//        print("playbackPosition", playerState.playbackPosition)
    }
    
}
