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
        placeholderImage = UIImage(imageLiteralResourceName: "image_message_placeholder")
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
    private init(kind: MessageKind, user: PTChatUser, messageId: String, date: Date) {
        self.kind = kind
        self.user = user
        self.messageId = messageId
        sentDate = date
    }

    init(custom: Any?, user: PTChatUser, messageId: String, date: Date) {
        self.init(kind: .custom(custom), user: user, messageId: messageId, date: date)
    }

    init(text: String, user: PTChatUser, messageId: String, date: Date) {
        self.init(kind: .text(text), user: user, messageId: messageId, date: date)
    }

    init(attributedText: NSAttributedString, user: PTChatUser, messageId: String, date: Date) {
        self.init(kind: .attributedText(attributedText), user: user, messageId: messageId, date: date)
    }

    init(image: UIImage, user: PTChatUser, messageId: String, date: Date) {
        let mediaItem = PTImageMediaItem(image: image)
        self.init(kind: .photo(mediaItem), user: user, messageId: messageId, date: date)
    }

    init(imageURL: URL, user: PTChatUser, messageId: String, date: Date) {
        let mediaItem = PTImageMediaItem(imageURL: imageURL)
        self.init(kind: .photo(mediaItem), user: user, messageId: messageId, date: date)
    }

    init(thumbnail: UIImage, user: PTChatUser, messageId: String, date: Date) {
        let mediaItem = PTImageMediaItem(image: thumbnail)
        self.init(kind: .video(mediaItem), user: user, messageId: messageId, date: date)
    }

    init(location: CLLocation, user: PTChatUser, messageId: String, date: Date) {
        let locationItem = PTCoordinateItem(location: location)
        self.init(kind: .location(locationItem), user: user, messageId: messageId, date: date)
    }

    init(emoji: String, user: PTChatUser, messageId: String, date: Date) {
        self.init(kind: .emoji(emoji), user: user, messageId: messageId, date: date)
    }

    init(audioURL: URL, user: PTChatUser, messageId: String, date: Date) {
        let audioItem = PTAudioItem(url: audioURL)
        self.init(kind: .audio(audioItem), user: user, messageId: messageId, date: date)
    }

    init(contact: PTContactItem, user: PTChatUser, messageId: String, date: Date) {
        self.init(kind: .contact(contact), user: user, messageId: messageId, date: date)
    }

    init(linkItem: LinkItem, user: PTChatUser, messageId: String, date: Date) {
        self.init(kind: .linkPreview(linkItem), user: user, messageId: messageId, date: date)
    }

    // MARK: Internal

    var messageId: String
    var sentDate: Date
    var kind: MessageKind

    var user: PTChatUser

    var sender: SenderType {
        user
    }
}
