//
//  PTMessageModel.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 3/3/23.
//

import UIKit
import MessageKit
import CoreLocation
import AVFoundation

private struct PTImageMediaItem: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize

    init(image: UIImage) {
        self.image = image
        size = CGSize(width: 240, height: 240)
        placeholderImage = UIImage()
    }

    init(imageURL: URL) {
        url = imageURL
        size = CGSize(width: 240, height: 240)
        placeholderImage = UIImage(imageLiteralResourceName: "DemoImage")
    }
}

private struct PTCoordinateItem: LocationItem {
    var location: CLLocation
    var size: CGSize

    init(location: CLLocation) {
        self.location = location
        size = CGSize(width: 240, height: 240)
    }
}


private struct PTAudioItem: AudioItem {
    var url: URL
    var size: CGSize
    var duration: Float

    init(url: URL) {
        self.url = url
        size = CGSize(width: 160, height: 35)
        let audioAsset = AVURLAsset(url: url)
        duration = Float(CMTimeGetSeconds(audioAsset.duration))
    }
}

struct PTContactItem: ContactItem {
    var displayName: String
    var initials: String
    var phoneNumbers: [String]
    var emails: [String]

    init(name: String, initials: String, phoneNumbers: [String] = [], emails: [String] = []) {
        displayName = name
        self.initials = initials
        self.phoneNumbers = phoneNumbers
        self.emails = emails
    }
}


internal struct PTMessageModel: MessageType {
    // MARK: Lifecycle
    private init(kind: MessageKind, user: PTChatUser, messageId: String, date: Date,sendSuccess:Bool) {
        self.kind = kind
        self.user = user
        self.messageId = messageId
        self.sentDate = date
        self.sendSuccess = sendSuccess
    }

    init(custom: Any?, user: PTChatUser, messageId: String, date: Date,sendSuccess:Bool) {
        self.init(kind: .custom(custom), user: user, messageId: messageId, date: date,sendSuccess: sendSuccess)
    }

    init(text: String, user: PTChatUser, messageId: String, date: Date,sendSuccess:Bool? = true,correctionText:String? = "") {
        self.init(kind: .text(text), user: user, messageId: messageId, date: date,sendSuccess: sendSuccess!)
        self.correctionText = correctionText!
    }

    init(attributedText: NSAttributedString, user: PTChatUser, messageId: String, date: Date,sendSuccess:Bool) {
        self.init(kind: .attributedText(attributedText), user: user, messageId: messageId, date: date,sendSuccess: sendSuccess)
    }

    init(image: UIImage, user: PTChatUser, messageId: String, date: Date,sendSuccess:Bool,fileName:String? = "") {
        let mediaItem = PTImageMediaItem(image: image)
        self.init(kind: .photo(mediaItem), user: user, messageId: messageId, date: date,sendSuccess: sendSuccess)
        self.localMessageImageName = fileName!
    }

    init(imageURL: URL, user: PTChatUser, messageId: String, date: Date,sendSuccess:Bool? = true) {
        let mediaItem = PTImageMediaItem(imageURL: imageURL)
        self.init(kind: .photo(mediaItem), user: user, messageId: messageId, date: date,sendSuccess: sendSuccess!)
    }

    init(thumbnail: UIImage, user: PTChatUser, messageId: String, date: Date,sendSuccess:Bool) {
        let mediaItem = PTImageMediaItem(image: thumbnail)
        self.init(kind: .video(mediaItem), user: user, messageId: messageId, date: date,sendSuccess: sendSuccess)
    }

    init(location: CLLocation, user: PTChatUser, messageId: String, date: Date,sendSuccess:Bool) {
        let locationItem = PTCoordinateItem(location: location)
        self.init(kind: .location(locationItem), user: user, messageId: messageId, date: date,sendSuccess: sendSuccess)
    }

    init(emoji: String, user: PTChatUser, messageId: String, date: Date,sendSuccess:Bool) {
        self.init(kind: .emoji(emoji), user: user, messageId: messageId, date: date,sendSuccess: sendSuccess)
    }

    init(audioURL: URL, user: PTChatUser, messageId: String, date: Date,sendSuccess:Bool) {
        let audioItem = PTAudioItem(url: audioURL)
        self.init(kind: .audio(audioItem), user: user, messageId: messageId, date: date,sendSuccess: sendSuccess)
    }

    init(contact: PTContactItem, user: PTChatUser, messageId: String, date: Date,sendSuccess:Bool) {
        self.init(kind: .contact(contact), user: user, messageId: messageId, date: date,sendSuccess: sendSuccess)
    }

    init(linkItem: LinkItem, user: PTChatUser, messageId: String, date: Date,sendSuccess:Bool) {
        self.init(kind: .linkPreview(linkItem), user: user, messageId: messageId, date: date,sendSuccess: sendSuccess)
    }

    // MARK: Internal

    var messageId: String
    var sentDate: Date
    var kind: MessageKind

    var user: PTChatUser

    var sender: SenderType {
        user
    }
    
    var sendSuccess:Bool
    var sending:Bool? = false
    var correctionText:String = ""
    var localMessageImageName:String = ""
}
