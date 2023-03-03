//
//  PTChatViewController.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 3/3/23.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import PooTools
import MapKit
import SDWebImage

fileprivate extension String{
    static let navTitle = "ChatGPT"
    static let loading = "思考中....."
}

class PTChatViewController: MessagesViewController {
    
    var editMessage:Bool = false
    var editString:String = ""
    var openAI:OpenAISwift!// = OpenAISwift(authToken: "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")

    lazy var messageList:[PTMessageModel] = []
    
    private(set) lazy var refreshControl:UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(loadMoreMessage), for: .valueChanged)
        return control
    }()
        
    
    init(token:String) {
        super.init(nibName: nil, bundle: nil)
        self.openAI = OpenAISwift(authToken: token)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        
        self.configureMessageCollectionView()
        self.configureMessageInputBar()
        self.title = .navTitle
    }
    
    @objc func loadMoreMessage()
    {
        DispatchQueue.global(qos:.userInitiated).asyncAfter(deadline: .now() + 1) {
            DispatchQueue.main.async {
                self.messagesCollectionView.reloadDataAndKeepOffset()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func configureMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self

        scrollsToLastItemOnKeyboardBeginsEditing = true // default false
        showMessageTimestampOnSwipeLeft = true // default false

        messagesCollectionView.refreshControl = refreshControl
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self

    }
    
    func configureMessageInputBar() {
        messageInputBar.delegate = self
        messageInputBar.inputTextView.tintColor = .black
        messageInputBar.sendButton.setTitleColor(.black, for: .normal)
        messageInputBar.sendButton.setTitleColor(
            UIColor.black.withAlphaComponent(0.3),
            for: .highlighted)
    }
    
    // MARK: - Helpers

    func insertMessage(_ message: PTMessageModel) {
        messageList.append(message)
      // Reload last section to update header/footer labels and insert a new one
        PTGCDManager.gcdMain {
            self.messagesCollectionView.performBatchUpdates({
                self.messagesCollectionView.insertSections([self.messageList.count - 1])
                if self.messageList.count >= 2 {
                    self.messagesCollectionView.reloadSections([self.messageList.count - 2])
              }
            }, completion: { [weak self] _ in
                if self?.isLastSectionVisible() == true {
                    self?.messagesCollectionView.scrollToLastItem(animated: true)
                }
            })
        }
    }

    func isLastSectionVisible() -> Bool {
      guard !messageList.isEmpty else { return false }

      let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)

      return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }


    // MARK: Private

    // MARK: - Private properties

    private let formatter: DateFormatter = {
      let formatter = DateFormatter()
      formatter.dateStyle = .medium
      return formatter
    }()

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.messagesCollectionView
        {
            self.messageInputBar.inputTextView.resignFirstResponder()
        }
    }
}

// MARK: - MessagesDisplayDelegate

extension PTChatViewController: MessagesDisplayDelegate {
    
    // MARK: - Text Messages
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        switch detector {
        case .hashtag, .mention: return [.foregroundColor: UIColor.blue]
        default: return MessageLabel.defaultAttributes
        }
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
    }
    
    // MARK: - All Messages
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .systemBlue : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let avatar = PTChatData.share.getAvatarFor(sender: message.sender)
        avatarView.set(avatar: avatar)
    }

    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if case MessageKind.photo(let media) = message.kind, let imageURL = media.url {
            imageView.sd_setImage(with: imageURL)
        } else {
//            imageView.kf.cancelDownloadTask()
        }
    }
    
    // MARK: - Location Messages
    
    func annotationViewForLocation(message: MessageType, at indexPath: IndexPath, in messageCollectionView: MessagesCollectionView) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: nil, reuseIdentifier: nil)
        let pinImage = #imageLiteral(resourceName: "ic_map_marker")
        annotationView.image = pinImage
        annotationView.centerOffset = CGPoint(x: 0, y: -pinImage.size.height / 2)
        return annotationView
    }
    
    func animationBlockForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> ((UIImageView) -> Void)? {
        return { view in
            view.layer.transform = CATransform3DMakeScale(2, 2, 2)
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
                view.layer.transform = CATransform3DIdentity
            }, completion: nil)
        }
    }
    
    func snapshotOptionsForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LocationMessageSnapshotOptions {
        
        return LocationMessageSnapshotOptions(showsBuildings: true, showsPointsOfInterest: true, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
    }

    // MARK: - Audio Messages

    func audioTintColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : UIColor(red: 15/255, green: 135/255, blue: 255/255, alpha: 1.0)
    }
    
    func configureAudioCell(_ cell: AudioMessageCell, message: MessageType) {
//        audioController.configureAudioCell(cell, message: message) // this is needed especially when the cell is reconfigure while is playing sound
    }

}


extension PTChatViewController:MessagesLayoutDelegate
{
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 18
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 17
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
}

extension PTChatViewController:MessagesDataSource
{
    func currentSender() -> MessageKit.SenderType {
        PTChatData.share.user
    }
    
    func numberOfSections(in _: MessagesCollectionView) -> Int {
      messageList.count
    }

    func messageForItem(at indexPath: IndexPath, in _: MessagesCollectionView) -> MessageType {
      messageList[indexPath.section]
    }

    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
      if indexPath.section % 3 == 0 {
        return NSAttributedString(
          string: MessageKitDateFormatter.shared.string(from: message.sentDate),
          attributes: [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
            NSAttributedString.Key.foregroundColor: UIColor.darkGray,
          ])
      }
      return nil
    }

    func cellBottomLabelAttributedText(for _: MessageType, at _: IndexPath) -> NSAttributedString? {
      NSAttributedString(
        string: "Read",
        attributes: [
          NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
          NSAttributedString.Key.foregroundColor: UIColor.darkGray,
        ])
    }

    func messageTopLabelAttributedText(for message: MessageType, at _: IndexPath) -> NSAttributedString? {
      let name = message.sender.displayName
      return NSAttributedString(
        string: name,
        attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }

    func messageBottomLabelAttributedText(for message: MessageType, at _: IndexPath) -> NSAttributedString? {
      let dateString = formatter.string(from: message.sentDate)
      return NSAttributedString(
        string: dateString,
        attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }

    func textCell(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> UICollectionViewCell? {
      nil
    }

}

extension PTChatViewController:MessageCellDelegate
{
    func didTapAvatar(in _: MessageCollectionViewCell) {
        print("Avatar tapped")
    }

    func didTapMessage(in cell: MessageCollectionViewCell) {
        let indexPath = self.messagesCollectionView.indexPath(for: cell)
        let messageModel = self.messageList[indexPath!.section]
        switch messageModel.kind {
        case .text(let text):
            self.editString = text
            messageInputBar.inputTextView.placeholder = "請輸入對\(self.editString)須要修改的內容"
        default: break
        }
        
        self.editMessage = true
        messageInputBar.inputTextView.becomeFirstResponder()
    }

    func didTapImage(in _: MessageCollectionViewCell) {
        PTLocalConsoleFunction.share.pNSLog("Image tapped")
    }

    func didTapCellTopLabel(in _: MessageCollectionViewCell) {
        PTLocalConsoleFunction.share.pNSLog("Top cell label tapped")
    }

    func didTapCellBottomLabel(in _: MessageCollectionViewCell) {
        PTLocalConsoleFunction.share.pNSLog("Bottom cell label tapped")
    }

    func didTapMessageTopLabel(in _: MessageCollectionViewCell) {
        PTLocalConsoleFunction.share.pNSLog("Top message label tapped")
    }

    func didTapMessageBottomLabel(in _: MessageCollectionViewCell) {
        PTLocalConsoleFunction.share.pNSLog("Bottom label tapped")
    }

//    func didTapPlayButton(in cell: AudioMessageCell) {
//      guard
//        let indexPath = messagesCollectionView.indexPath(for: cell),
//        let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView)
//      else {
//        print("Failed to identify message when audio cell receive tap gesture")
//        return
//      }
//      guard audioController.state != .stopped else {
//        // There is no audio sound playing - prepare to start playing for given audio message
//        audioController.playSound(for: message, in: cell)
//        return
//      }
//      if audioController.playingMessage?.messageId == message.messageId {
//        // tap occur in the current cell that is playing audio sound
//        if audioController.state == .playing {
//          audioController.pauseSound(for: message, in: cell)
//        } else {
//          audioController.resumeSound()
//        }
//      } else {
//        // tap occur in a difference cell that the one is currently playing sound. First stop currently playing and start the sound for given message
//        audioController.stopAnyOngoingPlaying()
//        audioController.playSound(for: message, in: cell)
//      }
//    }

    func didStartAudio(in _: AudioMessageCell) {
        PTLocalConsoleFunction.share.pNSLog("Did start playing audio sound")
    }

    func didPauseAudio(in _: AudioMessageCell) {
        PTLocalConsoleFunction.share.pNSLog("Did pause audio sound")
    }

    func didStopAudio(in _: AudioMessageCell) {
        PTLocalConsoleFunction.share.pNSLog("Did stop audio sound")
    }

    func didTapAccessoryView(in _: MessageCollectionViewCell) {
        PTLocalConsoleFunction.share.pNSLog("Accessory view tapped")
    }

}

extension PTChatViewController: MessageLabelDelegate {
    func didSelectAddress(_ addressComponents: [String: String]) {
        PTLocalConsoleFunction.share.pNSLog("Address Selected: \(addressComponents)")
    }

    func didSelectDate(_ date: Date) {
        PTLocalConsoleFunction.share.pNSLog("Date Selected: \(date)")
    }

    func didSelectPhoneNumber(_ phoneNumber: String) {
        PTLocalConsoleFunction.share.pNSLog("Phone Number Selected: \(phoneNumber)")
    }

    func didSelectURL(_ url: URL) {
        PTLocalConsoleFunction.share.pNSLog("URL Selected: \(url)")
    }

    func didSelectTransitInformation(_ transitInformation: [String: String]) {
        PTLocalConsoleFunction.share.pNSLog("TransitInformation Selected: \(transitInformation)")
    }

    func didSelectHashtag(_ hashtag: String) {
        PTLocalConsoleFunction.share.pNSLog("Hashtag selected: \(hashtag)")
    }

    func didSelectMention(_ mention: String) {
        PTLocalConsoleFunction.share.pNSLog("Mention selected: \(mention)")
    }

    func didSelectCustom(_ pattern: String, match _: String?) {
        PTLocalConsoleFunction.share.pNSLog("Custom data detector patter selected: \(pattern)")
    }
}


extension PTChatViewController: InputBarAccessoryViewDelegate
{
    // MARK: Internal
    @objc func inputBar(_: InputBarAccessoryView, didPressSendButtonWith _: String) {
        processInputBar(messageInputBar)
    }

    func processInputBar(_ inputBar: InputBarAccessoryView) {
        // Here we can parse for which substrings were autocompleted
        let attributedText = inputBar.inputTextView.attributedText!
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.enumerateAttribute(.autocompleted, in: range, options: []) { _, range, _ in

            let substring = attributedText.attributedSubstring(from: range)
            let context = substring.attribute(.autocompletedContext, at: 0, effectiveRange: nil)
            PTLocalConsoleFunction.share.pNSLog("Autocompleted:\(substring) with context\(String(describing: context))")
        }

        let components = inputBar.inputTextView.components
        inputBar.inputTextView.text = String()
        inputBar.invalidatePlugins()
        // Send button activity animation
        inputBar.sendButton.startAnimating()
        inputBar.inputTextView.placeholder = "Sending..."
        // Resign first responder for iPad split view
        inputBar.inputTextView.resignFirstResponder()
        DispatchQueue.global(qos: .default).async {
            // fake send request task
            sleep(1)
            DispatchQueue.main.async {
                inputBar.sendButton.stopAnimating()
                inputBar.inputTextView.placeholder = "Aa"
                self.insertMessages(components)
                self.messagesCollectionView.scrollToLastItem(animated: true)
            }
        }
    }

    // MARK: Private
    private func insertMessages(_ data: [Any])
    {
        for component in data {
            let user = PTChatData.share.user
            if let str = component as? String {
                let message = PTMessageModel(text: str, user: user, messageId: UUID().uuidString, date: Date())
                insertMessage(message)
                self.title = .loading
                if self.editMessage
                {
                    self.openAI.sendEdits(with: str, input: self.editString) { result in
                        switch result {
                        case .success(let success):
                            let botMessage = PTMessageModel(text: success.choices.first?.text ?? "", user: PTChatData.share.bot, messageId: UUID().uuidString, date: Date())
                            self.insertMessage(botMessage)
                            PTGCDManager.gcdMain {
                                self.editString = ""
                                self.editMessage = false
                                self.title = .navTitle
                            }
                        case .failure(let failure):
                            PTBaseViewController.gobal_drop(title: failure.localizedDescription)
                        }
                    }
                }
                else
                {
                    self.openAI.sendCompletion(with: str,maxTokens: 2048) { result in
                        switch result {
                        case .success(let success):
                            let botMessage = PTMessageModel(text: success.choices.first?.text ?? "", user: PTChatData.share.bot, messageId: UUID().uuidString, date: Date())
                            self.insertMessage(botMessage)
                            PTGCDManager.gcdMain {
                                self.title = .navTitle
                            }
                        case .failure(let failure):
                            PTBaseViewController.gobal_drop(title: failure.localizedDescription)
                        }
                    }
                }
            } else if let img = component as? UIImage {
                let message = PTMessageModel(image: img, user: user, messageId: UUID().uuidString, date: Date())
                insertMessage(message)
            }
        }
    }
}
