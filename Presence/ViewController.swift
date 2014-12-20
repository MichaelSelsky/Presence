//
//  ViewController.swift
//  Presence
//
//  Created by Michael Selsky on 10/4/14.
//  Copyright (c) 2014 Michael Selsky. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var labels: [UILabel]!
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var trackTitleLabel: UILabel!
    
    @IBOutlet weak var nextSongButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "songChanged:", name: "SongChange", object: nil)
        for label in self.labels {
            let animation = CATransition()
            animation.duration = 1.0
            animation.type = kCATransitionFade
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            label.layer.addAnimation(animation, forKey: "changeTextTransition")
        }

        
//        self.view.addGestureRecognizer(doubleTapGesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(animated: Bool) {
        let application = UIApplication.sharedApplication().delegate as AppDelegate
        var auth = SPTAuth.defaultInstance()
        
        
        let loginURL = auth.loginURLForClientId(application.kClientID, declaredRedirectURL: NSURL(string: application.kCallbackURL), scopes: [SPTAuthStreamingScope], withResponseType: "token")
        if let url = loginURL {
            let app = UIApplication.sharedApplication()
            app.openURL(url)
        }
        
    }
    
    func songChanged(note: NSNotification) {
        let placeholder = note.userInfo!["caller"]
        let session = placeholder as Session
        
        let animation = CATransition()
        animation.duration = 1.0
        animation.type = kCATransitionFade
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        
        self.trackTitleLabel.layer.addAnimation(animation, forKey: "changeTextTransition")
        self.trackTitleLabel.text = session.currentPlayingTrack
        self.artistLabel.layer.addAnimation(animation, forKey: "changeTextTransition")
        self.artistLabel.text = session.currentPlayingArtist
        self.albumLabel.layer.addAnimation(animation, forKey: "changeTextTransition")
        self.albumLabel.text = session.currentPlayingAlbum
        
        
    }
   
    @IBAction func nextSong(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "NextSong", object: nil))
    }
}

