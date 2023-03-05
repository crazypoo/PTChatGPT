//
//  PTAudioPlayer.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 5/3/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import AVFoundation
import MessageKit
import PooTools

public enum PlayerState {
    case playing
    case pause
    case stopped
}

open class PTAudioPlayer: NSObject {

    open var audioPlayer: AVAudioPlayer?

    open weak var playingCell: AudioMessageCell?

    open var playingMessage: MessageType?

    open private(set) var state: PlayerState = .stopped

    public weak var messageCollectionView: MessagesCollectionView?

    internal var progressTimer: Timer?

    // MARK: - Init Methods
    public init(messageCollectionView: MessagesCollectionView) {
        self.messageCollectionView = messageCollectionView
        super.init()
    }

    // MARK: - Methods
    open func configureAudioCell(_ cell: AudioMessageCell, message: MessageType) {
        if self.playingMessage?.messageId == message.messageId, let collectionView = self.messageCollectionView, let player = audioPlayer {
            self.playingCell = cell
            cell.progressView.progress = (player.duration == 0) ? 0 : Float(player.currentTime/player.duration)
            cell.playButton.isSelected = (player.isPlaying == true) ? true : false
            guard let displayDelegate = collectionView.messagesDisplayDelegate else {
                fatalError("MessagesDisplayDelegate has not been set.")
            }
            cell.durationLabel.text = displayDelegate.audioProgressTextFormat(Float(player.currentTime), for: cell, in: collectionView)
        }
    }

    open func playSound(for message: MessageType, in audioCell: AudioMessageCell) {
        switch message.kind {
        case .audio(let item):
            self.playingCell = audioCell
            self.playingMessage = message
            guard let player = try? AVAudioPlayer(contentsOf: item.url) else {
                PTLocalConsoleFunction.share.pNSLog("Failed to create audio player for URL: \(item.url)")
                return
            }
            self.audioPlayer = player
            self.audioPlayer?.prepareToPlay()
            self.audioPlayer?.delegate = self
            self.audioPlayer?.play()
            self.state = .playing
            audioCell.playButton.isSelected = true
            self.startProgressTimer()
            audioCell.delegate?.didStartAudio(in: audioCell)
        default:
            PTLocalConsoleFunction.share.pNSLog("BasicAudioPlayer failed play sound because given message kind is not Audio")
        }
    }
    open func pauseSound(for message: MessageType, in audioCell: AudioMessageCell) {
        self.audioPlayer?.pause()
        self.state = .pause
        audioCell.playButton.isSelected = false
        self.progressTimer?.invalidate()
        if let cell = playingCell {
            cell.delegate?.didPauseAudio(in: cell)
        }
    }

    open func stopAnyOngoingPlaying() {
        guard let player = self.audioPlayer, let collectionView = self.messageCollectionView else { return }
        player.stop()
        self.state = .stopped
        if let cell = playingCell {
            cell.progressView.progress = 0.0
            cell.playButton.isSelected = false
            guard let displayDelegate = collectionView.messagesDisplayDelegate else {
                fatalError("MessagesDisplayDelegate has not been set.")
            }
            cell.durationLabel.text = displayDelegate.audioProgressTextFormat(Float(player.duration), for: cell, in: collectionView)
            cell.delegate?.didStopAudio(in: cell)
        }
        self.progressTimer?.invalidate()
        self.progressTimer = nil
        self.audioPlayer = nil
        self.playingMessage = nil
        self.playingCell = nil
    }

    open func resumeSound() {
        guard let player = self.audioPlayer, let cell = self.playingCell else {
            self.stopAnyOngoingPlaying()
            return
        }
        player.prepareToPlay()
        player.play()
        self.state = .playing
        self.startProgressTimer()
        cell.playButton.isSelected = true
        cell.delegate?.didStartAudio(in: cell)
    }

    // MARK: - Fire Methods
    @objc private func didFireProgressTimer(_ timer: Timer) {
        guard let player = self.audioPlayer, let collectionView = self.messageCollectionView, let cell = self.playingCell else {
            return
        }
        if let playingCellIndexPath = collectionView.indexPath(for: cell) {
            let currentMessage = collectionView.messagesDataSource?.messageForItem(at: playingCellIndexPath, in: collectionView)
            if currentMessage != nil && currentMessage?.messageId == self.playingMessage?.messageId {
                cell.progressView.progress = (player.duration == 0) ? 0 : Float(player.currentTime/player.duration)
                guard let displayDelegate = collectionView.messagesDisplayDelegate else {
                    fatalError("MessagesDisplayDelegate has not been set.")
                }
                cell.durationLabel.text = displayDelegate.audioProgressTextFormat(Float(player.currentTime), for: cell, in: collectionView)
            } else {
                self.stopAnyOngoingPlaying()
            }
        }
    }

    // MARK: - Private Methods
    private func startProgressTimer() {
        self.progressTimer?.invalidate()
        self.progressTimer = nil
        self.progressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(PTAudioPlayer.didFireProgressTimer(_:)), userInfo: nil, repeats: true)
    }


}

// MARK: - AVAudioPlayerDelegate
extension PTAudioPlayer:AVAudioPlayerDelegate
{
    open func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.stopAnyOngoingPlaying()
    }

    open func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        self.stopAnyOngoingPlaying()
    }
}
