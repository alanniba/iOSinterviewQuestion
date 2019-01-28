//
//  PlayerDetailView.swift
//  InterViewQuestionApp
//
//  Created by haoyuan tan on 2019/1/20.
//  Copyright © 2019 haoyuan tan. All rights reserved.
//

import UIKit
import AVKit
import SDWebImage
import MediaPlayer
import Firebase
import JGProgressHUD
import MediaPlayer
protocol PlayerDetailViewDelegate {
    func handleMinimizeView()
    func handleMixMiazeView()
    func didClickBut(currentIndex : Int , tappingBut : Int , isSelect : Bool)
}


class PlayerDetailView: UIView {
    var pointArray = [String]()
    var currentIndex : Int!
    var question : Question!{
        didSet{

            print(question.correctAnswer ?? "")
            playVoice(urlString: question.correctAnswer ?? "")
            setImage(imageView: levelImage, levelInt: question.level ?? 0)
            setImage(imageView: miniPlayLevel, levelInt: question.level ?? 0)
            titleLab.text = question.title ?? ""
            miniPlayerLab.text = question.title ?? ""
            
            
            setupNowPlayingInfo()
            setupAudioSession()

            setBut(int: question.isMarkImpartant ?? 0, but: importantBut, selectedImage: #imageLiteral(resourceName: "important"), unselectedImage: #imageLiteral(resourceName: "unselectedImportant"))
            setBut(int: question.isMarkeasyForget ?? 0, but: flagBut, selectedImage: #imageLiteral(resourceName: "flag"), unselectedImage: #imageLiteral(resourceName: "unselectedFlag"))
            setBut(int: question.isMarkTooEasy ?? 0, but: easyBut, selectedImage: #imageLiteral(resourceName: "easy"), unselectedImage: #imageLiteral(resourceName: "unselectedEasy"))
            pointArray = question.keyPoint as! [String]
            addStackView(pointList: pointArray)
        }
    }
    
    fileprivate func setupNowPlayingInfo(){
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = question.title
        let artworkImage = #imageLiteral(resourceName: "flag")
        let artwork = MPMediaItemArtwork(boundsSize: artworkImage.size) { (_) -> UIImage in
            return artworkImage
        }
        nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    var delegate : PlayerDetailViewDelegate?
    
    @IBOutlet weak var miniPlayBut: UIButton!{
        didSet{
            miniPlayBut.addTarget(self, action: #selector(handlePlayOrPause), for: .touchUpInside)
        }
    }
    @IBOutlet weak var maxPlayer: UIView!
    @IBOutlet weak var importantBut: UIButton!
    @IBOutlet weak var flagBut: UIButton!
    @IBOutlet weak var easyBut: UIButton!
    @IBOutlet weak var miniPlayer: UIView!
    @IBOutlet weak var miniPlayerLab: UILabel!
    @IBOutlet weak var miniPlayLevel: UIImageView!
    @IBOutlet weak var playOrPauseBut: UIButton!{
        didSet{
            playOrPauseBut.addTarget(self, action: #selector(handlePlayOrPause), for: .touchUpInside)
        }
    }
    @objc fileprivate func handlePlayOrPause(){
        if player.timeControlStatus == .paused{
            player.play()
            playOrPauseBut.setImage(#imageLiteral(resourceName: "pauseBut"), for: .normal)
            miniPlayBut.setImage(#imageLiteral(resourceName: "pauseBut"), for: .normal)
            self.setupElapesTime(playbackRate: 1)

        } else {
            player.pause()
            playOrPauseBut.setImage(#imageLiteral(resourceName: "playBut"), for: .normal)
            miniPlayBut.setImage(#imageLiteral(resourceName: "playBut"), for: .normal)
            self.setupElapesTime(playbackRate: 0)

        }
    }
    @IBAction func handleCurrentTImeSlider(_ sender: Any) {
        let percentage = currentTimeSlider.value
        guard let duration = player.currentItem?.duration else {return}
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSecondes = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSecondes, preferredTimescale: Int32(NSEC_PER_SEC))
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = seekTimeInSecondes
        player.seek(to: seekTime)
    }
    
    
    
    @IBAction func handleRewind(_ sender: Any) {

        seekToCurrentTime(delta: -15)
    }
    @IBAction func handleForword(_ sender: Any) {

        seekToCurrentTime(delta: 15)
    }
    
    
    fileprivate func seekToCurrentTime(delta : Int64){
        let fifteenSeconds = CMTimeMake(value: delta, timescale: 1)
        let seekTime = CMTimeAdd(player.currentTime(), fifteenSeconds)
        player.seek(to: seekTime)
    }
    @IBOutlet weak var keyPointLab: UILabel!
    @IBOutlet weak var levelImage: UIImageView!
    @IBOutlet weak var currentTimeLab: UILabel!
    @IBOutlet weak var durationLab: UILabel!
    @IBOutlet weak var titleLab: UILabel!
    
    @IBOutlet weak var currentTimeSlider: UISlider!

    
    fileprivate func observeBoundrayTime() {
        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        player.addBoundaryTimeObserver(forTimes:times , queue: .main) {[weak self] in
            self?.setupLockScrrenDuration()
        }
    }
    fileprivate func setupLockScrrenDuration(){
        guard let duration = player.currentItem?.duration else {return}
        let durationSeconds = CMTimeGetSeconds(duration)
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = durationSeconds
    }
    
    override func awakeFromNib() {
        setupRemoteControl()
        observePlayerCurrentTime()
        setupInterruptionObserver()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(minimizing))
        maxPlayer.addGestureRecognizer(panGesture)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(maxmizing))
        miniPlayer.addGestureRecognizer(tapGesture)
        
        observeBoundrayTime()
    }
    
    fileprivate func setupInterruptionObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
    }
    @objc fileprivate func handleInterruption(notification : Notification){
        guard let userInfo = notification.userInfo else {return}
        guard let type = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt else {return}
        if type == AVAudioSession.InterruptionType.began.rawValue{
            print("interruption began")
            playOrPauseBut.setImage(#imageLiteral(resourceName: "playBut"), for: .normal)
            miniPlayBut.setImage(#imageLiteral(resourceName: "playBut"), for: .normal)
        } else {
            print("interrution ended...")
            guard let options = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt else {return}
            if options == AVAudioSession.InterruptionOptions.shouldResume.rawValue{
                
                player.play()
                playOrPauseBut.setImage(#imageLiteral(resourceName: "pauseBut"), for: .normal)
                miniPlayBut.setImage(#imageLiteral(resourceName: "pauseBut"), for: .normal)
            }
            
        }
    }
    
    
    fileprivate func setupRemoteControl(){
        UIApplication.shared.beginReceivingRemoteControlEvents()
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget {[weak self] (_) -> MPRemoteCommandHandlerStatus in
            print("should play")
            self?.player.play()
            self?.playOrPauseBut.setImage(#imageLiteral(resourceName: "pauseBut"), for: .normal)
            self?.miniPlayBut.setImage(#imageLiteral(resourceName: "pauseBut"), for: .normal)
            self?.setupElapesTime(playbackRate: 1)
            return .success
        }
        
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget {[weak self] (_) -> MPRemoteCommandHandlerStatus in
            print("should pause ")
            self?.player.pause()
            self?.playOrPauseBut.setImage(#imageLiteral(resourceName: "playBut"), for: .normal)
            self?.miniPlayBut.setImage(#imageLiteral(resourceName: "playBut"), for: .normal)
            self?.setupElapesTime(playbackRate: 0)

            return .success
        }
        
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { [weak self](_) -> MPRemoteCommandHandlerStatus in
            self?.handlePlayOrPause()

            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget(self, action: #selector(handleNextTrack))
        commandCenter.previousTrackCommand.addTarget(self, action: #selector(handlePreviousTrack))
    }
    
    var playlistQuestions = [Question]()
    
    @objc fileprivate func handlePreviousTrack(){
        if playlistQuestions.count == 0{
            return
        }
        let currenIndex = playlistQuestions.lastIndex { (qs) -> Bool in
            return self.question.title == qs.title
        }
        guard let index = currenIndex else {return}
        let previousQuestion : Question
        if index == 0{
            previousQuestion = playlistQuestions[playlistQuestions.count - 1]
        } else {
            previousQuestion = playlistQuestions[index - 1]
        }
        self.question = previousQuestion
    }
    @objc fileprivate func handleNextTrack(){
        
        if playlistQuestions.count == 0 {
            return
        }
        let currentIndex = playlistQuestions.lastIndex { (qs) -> Bool in
            return self.question.title == qs.title
        }
        guard let index = currentIndex else {return}
        let nextQuestion : Question
        if index == playlistQuestions.count - 1{
            nextQuestion = playlistQuestions[0]
        } else {
            nextQuestion = playlistQuestions[index + 1]

        }
        self.question = nextQuestion
    }
    
    fileprivate func setupElapesTime(playbackRate : Float){
        let elapsedTime = CMTimeGetSeconds(player.currentTime())
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = playbackRate

    }
    fileprivate func setupAudioSession(){
        do{
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let sessionErr {
            print("Failed to active session:", sessionErr)
        }
    }
    
    @objc func minimizing(){
        delegate?.handleMinimizeView()
        UIView.animate(withDuration: 0.3) {
            self.miniPlayer.alpha = 1
            self.maxPlayer.alpha = 0
        }
    }
    @objc func maxmizing(){
        delegate?.handleMixMiazeView()
        UIView.animate(withDuration: 0.3) {
            self.miniPlayer.alpha = 0
            self.maxPlayer.alpha = 1
        }

    }
    fileprivate func observePlayerCurrentTime() {
        let interval = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) {[weak self] (time) in
          
            self?.currentTimeLab.text = time.toDisplayString()
            self?.durationLab.text = self?.player.currentItem?.duration.toDisplayString()
//            self?.setupLockscreenCurrentTime()
            self?.updateCurrentTimeSlider()
        }
    }
    
//    fileprivate func setupLockscreenCurrentTime(){
//        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
//        guard let currentItem = player.currentItem else {return}
//        let duationInSec = CMTimeGetSeconds(currentItem.duration)
//        let elapsedTime = CMTimeGetSeconds(player.currentTime())
//        nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
//        nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = duationInSec
//        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
//    }
    
    fileprivate func updateCurrentTimeSlider(){
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
        let percentage = currentTimeSeconds / durationSeconds
        self.currentTimeSlider.value = Float(percentage)
    }
    
    let player: AVPlayer = {
        let player = AVPlayer()
        player.automaticallyWaitsToMinimizeStalling = false
        return player
    }()

    
    fileprivate func playVoice(urlString : String){
        guard let url = URL(string: urlString) else {return}
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
        miniPlayBut.setImage(#imageLiteral(resourceName: "pauseBut"), for: .normal)
        playOrPauseBut.setImage(#imageLiteral(resourceName: "pauseBut"), for: .normal)
    }
    var pointStackView : UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()
    
    private func addStackView(pointList : [String]){
        print(pointList)
        pointStackView.removeAllArrangedSubviews()
        pointStackView.alignment = .fill
        pointStackView.distribution = .fillProportionally
        var currentIndex = 1
        pointList.forEach { (content) in
            let lab = UILabel()
            lab.numberOfLines = 0
            let resultContent = "\(currentIndex).\(content)"
            lab.text = resultContent
            lab.textColor = UIColor.mainBlue()
            pointStackView.addArrangedSubview(lab)
            currentIndex += 1
        }
        maxPlayer.addSubview(pointStackView)
        pointStackView.anchor(top: keyPointLab.bottomAnchor, leading: keyPointLab.leadingAnchor, bottom: nil, trailing: self.trailingAnchor, padding: .init(top: 16, left: 0, bottom: 0, right: 24))
    }

    fileprivate func setImage(imageView : UIImageView ,levelInt : Int){
        if levelInt != 0 {
            switch  levelInt {
            case 1:
                imageView.image = #imageLiteral(resourceName: "Group 4")
            case 2:
                imageView.image = #imageLiteral(resourceName: "Group 5")
            case 3:
                imageView.image = #imageLiteral(resourceName: "Group 6")
            default:
                imageView.image = #imageLiteral(resourceName: "Group 7")
            }
        } else {
            return
        }
    }
    
    fileprivate func setBut(int : Int , but : UIButton, selectedImage: UIImage, unselectedImage : UIImage){
        if int == 0{
            but.isSelected = false
            but.setImage(unselectedImage, for: .normal)
        } else {
            but.isSelected = true
            but.setImage(selectedImage, for: .normal)
        }
    }

    @IBAction func handleMarkImportant(_ sender: Any) {
        if !importantBut.isSelected{
            importantBut.setImage(#imageLiteral(resourceName: "important"), for: .normal)
            importantBut.isSelected = true
            setMarkInFirestore(setString: "importantFlag", setValue: 1)
            delegate?.didClickBut(currentIndex: currentIndex, tappingBut: 0 , isSelect: true)
        } else {
            importantBut.setImage(#imageLiteral(resourceName: "unselectedImportant"), for: .normal)
            importantBut.isSelected = false
            setMarkInFirestore(setString: "importantFlag", setValue: 0)
            delegate?.didClickBut(currentIndex: currentIndex, tappingBut: 0 , isSelect: false)

        }
        
    }
    @IBAction func handleMarkFlag(_ sender: Any) {
        if !flagBut.isSelected{
            flagBut.setImage(#imageLiteral(resourceName: "flag"), for: .normal)
            flagBut.isSelected = true
            setMarkInFirestore(setString: "easyForgetFlag", setValue: 1)
            delegate?.didClickBut(currentIndex: currentIndex, tappingBut: 1 , isSelect: true)

        } else {
            flagBut.setImage(#imageLiteral(resourceName: "unselectedFlag"), for: .normal)
            flagBut.isSelected = false
            setMarkInFirestore(setString: "easyForgetFlag", setValue: 0)
            delegate?.didClickBut(currentIndex: currentIndex, tappingBut: 1 , isSelect: false)

        }
    }
    @IBAction func handleMarkEasy(_ sender: Any) {
        if !easyBut.isSelected{
            easyBut.setImage(#imageLiteral(resourceName: "easy"), for: .normal)
            easyBut.isSelected = true
            setMarkInFirestore(setString: "tooEasyFlag", setValue: 1)
            delegate?.didClickBut(currentIndex: currentIndex,tappingBut: 2 , isSelect: true)

        } else {
            easyBut.setImage(#imageLiteral(resourceName: "unselectedEasy"), for: .normal)
            easyBut.isSelected = false
            setMarkInFirestore(setString: "tooEasyFlag", setValue: 0)
            delegate?.didClickBut(currentIndex: currentIndex, tappingBut: 2 , isSelect: false)

        }
        
        
    }
    
    fileprivate func setMarkInFirestore(setString: String , setValue : Int){
        guard let cardID = question.cardID else {return}
        let docData = [
            setString: setValue
        ]
        Firestore.firestore().collection("user").document(cardID).updateData(docData) { (err) in
            
            if let err = err {
                print("unable to set easyForgetFlag", err)
            }
            print("successful set data to firestore")
            
        }
        
    }
    

    
    static func initFromNib() -> PlayerDetailView{
        return Bundle.main.loadNibNamed("PlayerDetailView", owner: self, options: nil)?.first as! PlayerDetailView
    }
    
}


extension UIStackView {
    
    func removeAllArrangedSubviews() {
        
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        
        // Deactivate all constraints
        NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))
        
        // Remove the views from self
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
}
