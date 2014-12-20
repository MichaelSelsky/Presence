//
//  Session.swift
//  Presence
//
//  Created by Michael Selsky on 10/4/14.
//  Copyright (c) 2014 Michael Selsky. All rights reserved.
//

import UIKit

class Session: NSObject, SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate {
    var locationManager: LocationManager
    let networkManager = NetworkingManager()
    var spotifySession: SPTSession
    var spotifyPlayer: SPTAudioStreamingController = SPTAudioStreamingController()
    var nextPlay: String?
    
    var currentPlayingTrack = ""
    var currentPlayingArtist = ""
    var currentPlayingAlbum = ""
    var currentPlayingImage = UIImage()
    
    init(spotifySession:SPTSession){
        self.locationManager = LocationManager(callback: { (coordinate) -> () in
            //TODO: callback with coordinate
        })
        self.spotifySession = spotifySession
    }
    
    func start(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "nextSong", name: "NextSong", object: nil)
        let str = self.spotifySession.canonicalUsername
        
        self.networkManager.oAuthToken = self.spotifySession.canonicalUsername.stringByReplacingOccurrencesOfString(".", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: Range<String.Index>(start: str.startIndex, end: str.endIndex))
        self.locationManager = LocationManager(callback: { (coordinate) -> () in
            let long = "\(coordinate.longitude)"
            let lat = "\(coordinate.latitude)"
            self.networkManager.updateLocation(lat, longitude: long)
        })
        
        self.spotifyPlayer.playbackDelegate = self;
        
        self.spotifyPlayer.delegate = self;
        
        self.spotifyPlayer.loginWithSession(self.spotifySession, callback: { (error) -> Void in
            if error != nil {

            } else {
                    self.networkManager.getNextPlaylist { (nextSong) -> () in
                        println("Next song:\(nextSong)")
//                        if self.spotifyPlayer.isPlaying{
//                        self.nextPlay = nextSong
//                            self.spotifyPlayer.queueURI(NSURL(string: nextSong), callback: { (error) -> Void in
//                                if error != nil {
//                                    
//                                }
//                                
//                            })
//                        } else {
                            self.spotifyPlayer.playURI(NSURL(string: nextSong), callback: { (error) -> Void in
                                if error != nil {
                                    println("*** Player error: \(error)")
                                }
                                self.networkManager.getNextPlaylist { (nextSong) -> () in
                                    println("Next song:\(nextSong)")
                                        self.nextPlay = nextSong
                                        self.spotifyPlayer.queueURI(NSURL(string: nextSong), callback: { (error) -> Void in
                                            if error != nil {
                                                
                                            }
                                            
                                        })
                                    
                                }
                            })
//                        }
                    }
                
            }
        })
        
        func nextSong() {
            self.spotifyPlayer.skipNext(nil)
        }
        
        
        
        self.locationManager.start()
        self.getSpotifyPreferences();
        
    }
    
    //TODO: refactor this somewhere else
    func getSpotifyPreferences() {
        SPTRequest.starredListForUserInSession(self.spotifySession, callback: { (error, playlistOptional) -> Void in
            if let playlist = playlistOptional as? SPTPlaylistSnapshot{
                var preferences: [String: AnyObject] = [:]
                let tracks = playlist.tracksForPlayback()
                for track in tracks {
                    let song = track as SPTPartialTrack
                    let artists = track.artists!
                    for artistObject in artists {
                        let artist = artistObject as SPTPartialArtist
                        let title = track.identifier as String
                        let artistName = artist.name as String
                            if let data: AnyObject = preferences[artistName] {
                                var newData = data as [String]
                                newData.append(title)
                                preferences[artistName] = newData
                            } else {
                                preferences[artistName] = [title]
                            }
                        }
                    }
                
                var preferencesArray:[String: AnyObject] = [:]
                
                for key in preferences.keys {
                    var dict: [String: AnyObject] = [:]
                    let keyString = key as String
                    dict["id"] = key as String
                    dict["tracks"] = preferences[key]
                    preferencesArray[keyString] = dict
                }
                
                self.networkManager.uploadPreferences(preferencesArray)
                
                }
        })
    }
    
    func audioStreamingDidSkipToNextTrack(audioStreaming: SPTAudioStreamingController!) {
        self.networkManager.getNextPlaylist { (nextSong) -> () in
            println("Next song:\(nextSong)")
            self.nextPlay = nextSong
            self.spotifyPlayer.queueURI(NSURL(string: nextSong), callback: { (error) -> Void in
                if error != nil {
                    
                }
                
            })
        }
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didEncounterError error: NSError!) {
        println("Audio Streaming Error:\(error)")
    }
    
    func audioStreamingDidEncounterTemporaryConnectionError(audioStreaming: SPTAudioStreamingController!) {
        println("Connection Error")
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        if !isPlaying{
            if let nextSongToPlay = self.nextPlay{
                audioStreaming.playURI(NSURL(string:nextSongToPlay), callback: { (error) -> Void in
                    if error != nil {
                        
                    }
                })
            }
        } else {
            self.networkManager.getNextPlaylist { (nextSong) -> () in
                println("Next song:\(nextSong)")
                self.nextPlay = nextSong
                self.spotifyPlayer.queueURI(NSURL(string: nextSong), callback: { (error) -> Void in
                    if error != nil {
                        
                    }
                    
                })
            }
        }
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangeToTrack trackMetadata: [NSObject : AnyObject]!) {
        if let trackData = trackMetadata {
        println("\(trackMetadata)")
        
            let currentPlayingAlbum: AnyObject? = trackData["SPTAudioStreamingMetadataAlbumName"]
            let currentPlayingArtist: AnyObject? = trackData["SPTAudioStreamingMetadataArtistName"]
            let currentPlayingTrack: AnyObject? = trackData["SPTAudioStreamingMetadataTrackName"]
            
            self.currentPlayingTrack = currentPlayingTrack as String
            self.currentPlayingArtist = currentPlayingArtist as String
            self.currentPlayingAlbum = currentPlayingAlbum as String
        } else {
            self.currentPlayingTrack = "No network connectivity"
            self.currentPlayingArtist = "We are truly and deeply"
            self.currentPlayingAlbum="sorry."
        }
        
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "SongChange", object: nil, userInfo: ["caller":self]))
    }
    
}


