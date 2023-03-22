//
//  PTChatCustomCell.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 9/3/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import MessageKit

class CustomLayoutSizeCalculator: CellSizeCalculator {
    // MARK: Lifecycle

    init(layout: MessagesCollectionViewFlowLayout? = nil) {
        super.init()

        self.layout = layout
    }

    // MARK: Internal

    var cellTopLabelVerticalPadding: CGFloat = 32
    var cellTopLabelHorizontalPadding: CGFloat = 32
    var cellMessageContainerHorizontalPadding: CGFloat = 48
    var cellMessageContainerExtraSpacing: CGFloat = 16
    var cellMessageContentVerticalPadding: CGFloat = 16
    var cellMessageContentHorizontalPadding: CGFloat = 16
    var cellDateLabelHorizontalPadding: CGFloat = 24
    var cellDateLabelBottomPadding: CGFloat = 8

    var messagesLayout: MessagesCollectionViewFlowLayout {
        layout as! MessagesCollectionViewFlowLayout
    }

    var messageContainerMaxWidth: CGFloat {
        messagesLayout.itemWidth -
        cellMessageContainerHorizontalPadding -
        cellMessageContainerExtraSpacing
    }

    var messagesDataSource: MessagesDataSource {
        self.messagesLayout.messagesDataSource
    }

    override func sizeForItem(at indexPath: IndexPath) -> CGSize {
        let dataSource = messagesDataSource
        let message = dataSource.messageForItem(
            at: indexPath,
            in: messagesLayout.messagesCollectionView)
        let itemHeight = cellContentHeight(
            for: message,
            at: indexPath)
        return CGSize(
            width: messagesLayout.itemWidth,
            height: itemHeight)
    }

    func cellContentHeight(
        for message: MessageType,
        at indexPath: IndexPath)
    -> CGFloat
    {
        cellTopLabelSize(
            for: message,
            at: indexPath).height +
        cellMessageBottomLabelSize(
            for: message,
            at: indexPath).height +
        messageContainerSize(
            for: message,
            at: indexPath).height
    }

    // MARK: - Top cell Label

    func cellTopLabelSize(
        for message: MessageType,
        at indexPath: IndexPath)
    -> CGSize
    {
        guard
            let attributedText = messagesDataSource.cellTopLabelAttributedText(
                for: message,
                at: indexPath) else
        {
            return .zero
        }

        let maxWidth = messagesLayout.itemWidth - cellTopLabelHorizontalPadding
        let size = attributedText.size(consideringWidth: maxWidth)
        let height = size.height + cellTopLabelVerticalPadding

        return CGSize(
            width: maxWidth,
            height: height)
    }

    func cellTopLabelFrame(
        for message: MessageType,
        at indexPath: IndexPath)
    -> CGRect
    {
        let size = cellTopLabelSize(
            for: message,
            at: indexPath)
        guard size != .zero else {
            return .zero
        }

        let origin = CGPoint(
            x: cellTopLabelHorizontalPadding / 2,
            y: 0)

        return CGRect(
            origin: origin,
            size: size)
    }

    func cellMessageBottomLabelSize(
        for message: MessageType,
        at indexPath: IndexPath)
    -> CGSize
    {
        guard
            let attributedText = messagesDataSource.messageBottomLabelAttributedText(
                for: message,
                at: indexPath) else
        {
            return .zero
        }
        let maxWidth = messageContainerMaxWidth - cellDateLabelHorizontalPadding

        return attributedText.size(consideringWidth: maxWidth)
    }

    func cellMessageBottomLabelFrame(
        for message: MessageType,
        at indexPath: IndexPath)
    -> CGRect
    {
        let messageContainerSize = messageContainerSize(
            for: message,
            at: indexPath)
        let labelSize = cellMessageBottomLabelSize(
            for: message,
            at: indexPath)
        let x = messageContainerSize.width - labelSize.width - (cellDateLabelHorizontalPadding / 2)
        let y = messageContainerSize.height - labelSize.height - cellDateLabelBottomPadding
        let origin = CGPoint(
            x: x,
            y: y)

        return CGRect(
            origin: origin,
            size: labelSize)
    }

  // MARK: - MessageContainer

    func messageContainerSize(
      for message: MessageType,
      at indexPath: IndexPath)
      -> CGSize
    {
      let labelSize = cellMessageBottomLabelSize(
        for: message,
        at: indexPath)
      let width = labelSize.width +
        cellMessageContentHorizontalPadding +
        cellDateLabelHorizontalPadding
      let height = labelSize.height +
        cellMessageContentVerticalPadding +
        cellDateLabelBottomPadding

      return CGSize(
        width: width,
        height: height)
    }

    func messageContainerFrame(
      for message: MessageType,
      at indexPath: IndexPath,
      fromCurrentSender: Bool)
      -> CGRect
    {
      let y = cellTopLabelSize(
        for: message,
        at: indexPath).height
      let size = messageContainerSize(
        for: message,
        at: indexPath)
      let origin: CGPoint
      if fromCurrentSender {
        let x = messagesLayout.itemWidth -
          size.width -
          (cellMessageContainerHorizontalPadding / 2)
        origin = CGPoint(x: x, y: y)
      } else {
        origin = CGPoint(
          x: cellMessageContainerHorizontalPadding / 2,
          y: y)
      }

      return CGRect(
        origin: origin,
        size: size)
    }
}

class CustomTextLayoutSizeCalculator: CustomLayoutSizeCalculator {
    var messageLabelFont = UIFont.preferredFont(forTextStyle: .body)
    var cellMessageContainerRightSpacing: CGFloat = 16

    override func messageContainerSize(
      for message: MessageType,
      at indexPath: IndexPath)
      -> CGSize
    {
      let size = super.messageContainerSize(
        for: message,
        at: indexPath)
      let labelSize = messageLabelSize(
        for: message,
        at: indexPath)
      let selfWidth = labelSize.width +
        cellMessageContentHorizontalPadding +
        cellMessageContainerRightSpacing
      let width = max(selfWidth, size.width)
      let height = size.height + labelSize.height

      return CGSize(
        width: width,
        height: height)
    }

    func messageLabelSize(
      for message: MessageType,
      at _: IndexPath)
      -> CGSize
    {
      let attributedText: NSAttributedString

      let textMessageKind = message.kind
      switch textMessageKind {
      case .attributedText(let text):
        attributedText = text
      case .text(let text), .emoji(let text):
        attributedText = NSAttributedString(string: text, attributes: [.font: messageLabelFont])
      default:
        fatalError("messageLabelSize received unhandled MessageDataType: \(message.kind)")
      }

      let maxWidth = messageContainerMaxWidth -
        cellMessageContentHorizontalPadding -
        cellMessageContainerRightSpacing

      return attributedText.size(consideringWidth: maxWidth)
    }

    func messageLabelFrame(
      for message: MessageType,
      at indexPath: IndexPath)
      -> CGRect
    {
      let origin = CGPoint(
        x: cellMessageContentHorizontalPadding / 2,
        y: cellMessageContentVerticalPadding / 2)
      let size = messageLabelSize(
        for: message,
        at: indexPath)

      return CGRect(
        origin: origin,
        size: size)
    }
}

class CustomMessageContentCell: MessageCollectionViewCell {
    // MARK: Lifecycle

    override init(frame: CGRect) {
      super.init(frame: frame)
      contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      setupSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      setupSubviews()
    }

    // MARK: Internal

    /// The `MessageCellDelegate` for the cell.
    weak var delegate: MessageCellDelegate?

    /// The container used for styling and holding the message's content view.
    var messageContainerView: UIView = {
      let containerView = UIView()
      containerView.clipsToBounds = true
      containerView.layer.masksToBounds = true
      return containerView
    }()

    /// The top label of the cell.
    var cellTopLabel: UILabel = {
      let label = UILabel()
      label.numberOfLines = 0
      label.textAlignment = .center
      return label
    }()

    var cellDateLabel: UILabel = {
      let label = UILabel()
      label.numberOfLines = 0
      label.textAlignment = .right
      return label
    }()

    override func prepareForReuse() {
      super.prepareForReuse()
      cellTopLabel.text = nil
      cellTopLabel.attributedText = nil
      cellDateLabel.text = nil
      cellDateLabel.attributedText = nil
    }

    /// Handle tap gesture on contentView and its subviews.
    override func handleTapGesture(_ gesture: UIGestureRecognizer) {
      let touchLocation = gesture.location(in: self)

      switch true {
      case messageContainerView.frame
        .contains(touchLocation) && !cellContentView(canHandle: convert(touchLocation, to: messageContainerView)):
        delegate?.didTapMessage(in: self)
      case cellTopLabel.frame.contains(touchLocation):
        delegate?.didTapCellTopLabel(in: self)
      case cellDateLabel.frame.contains(touchLocation):
        delegate?.didTapMessageBottomLabel(in: self)
      default:
        delegate?.didTapBackground(in: self)
      }
    }

    /// Handle long press gesture, return true when gestureRecognizer's touch point in `messageContainerView`'s frame
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
      let touchPoint = gestureRecognizer.location(in: self)
      guard gestureRecognizer.isKind(of: UILongPressGestureRecognizer.self) else { return false }
      return messageContainerView.frame.contains(touchPoint)
    }

    func setupSubviews() {
      messageContainerView.layer.cornerRadius = 5

      contentView.addSubview(cellTopLabel)
      contentView.addSubview(messageContainerView)
      messageContainerView.addSubview(cellDateLabel)
    }

    func configure(
      with message: MessageType,
      at indexPath: IndexPath,
      in messagesCollectionView: MessagesCollectionView,
      dataSource: MessagesDataSource,
      and sizeCalculator: CustomLayoutSizeCalculator)
    {
      guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
        return
      }
      cellTopLabel.frame = sizeCalculator.cellTopLabelFrame(
        for: message,
        at: indexPath)
      cellDateLabel.frame = sizeCalculator.cellMessageBottomLabelFrame(
        for: message,
        at: indexPath)
      messageContainerView.frame = sizeCalculator.messageContainerFrame(
        for: message,
        at: indexPath,
        fromCurrentSender: dataSource
          .isFromCurrentSender(message: message))
      cellTopLabel.attributedText = dataSource.cellTopLabelAttributedText(
        for: message,
        at: indexPath)
      cellDateLabel.attributedText = dataSource.messageBottomLabelAttributedText(
        for: message,
        at: indexPath)
      messageContainerView.backgroundColor = displayDelegate.backgroundColor(
        for: message,
        at: indexPath,
        in: messagesCollectionView)
    }

    /// Handle `ContentView`'s tap gesture, return false when `ContentView` doesn't needs to handle gesture
    func cellContentView(canHandle _: CGPoint) -> Bool {
      false
    }
}

class PTChatCustomCell: CustomMessageContentCell {
    /// The label used to display the message's text.
    var messageLabel: UILabel = {
      let label = UILabel()
      label.numberOfLines = 0
      label.font = UIFont.preferredFont(forTextStyle: .body)

      return label
    }()

    override func prepareForReuse() {
      super.prepareForReuse()

      messageLabel.attributedText = nil
      messageLabel.text = nil
    }

    override func setupSubviews() {
      super.setupSubviews()

      messageContainerView.addSubview(messageLabel)
    }

    override func configure(
      with message: MessageType,
      at indexPath: IndexPath,
      in messagesCollectionView: MessagesCollectionView,
      dataSource: MessagesDataSource,
      and sizeCalculator: CustomLayoutSizeCalculator)
    {
      super.configure(
        with: message,
        at: indexPath,
        in: messagesCollectionView,
        dataSource: dataSource,
        and: sizeCalculator)

      guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
        return
      }

      let calculator = sizeCalculator as? CustomTextLayoutSizeCalculator
      messageLabel.frame = calculator?.messageLabelFrame(
        for: message,
        at: indexPath) ?? .zero

      let textMessageKind = message.kind
      switch textMessageKind {
      case .text(let text), .emoji(let text):
        let textColor = displayDelegate.textColor(for: message, at: indexPath, in: messagesCollectionView)
        messageLabel.text = text
        messageLabel.textColor = textColor
      case .attributedText(let text):
        messageLabel.attributedText = text
      default:
        break
      }
    }

}
