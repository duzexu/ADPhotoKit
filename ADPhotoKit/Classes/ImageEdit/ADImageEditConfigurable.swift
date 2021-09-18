//
//  ADImageEditConfigurable.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/23.
//

import Foundation

/// Use to save or revert edit tool info.
public protocol ADImageEditToolCodable: AnyObject {
    
    /// Identifier of the tool. It will be used to identify the tool when
    /// save and revert info. You might want to make sure that tools with
    /// different identifiers.
    ///
    /// - Note: It is recommended to use a reverse domain name notation string of
    /// your own for the identifier.
    var identifier: String { get }
    
    /// Archive tool info to save.
    func encode() -> Any?
    
    /// Unarchive tool info from saved data.
    /// - Parameter from: Saved data.
    func decode(from: Any)
}

/// An `ADImageEditTool` would be used to edit image.
public protocol ADImageEditTool: ADImageEditToolCodable {
    
    /// Tool's icon for default state. Which is display on bottom of the edit controller.
    var image: UIImage { get }
    /// Tool's icon for select state. Which is display when tool is selected.
    /// - Note: Return `nil` if icon don't change when selected.
    var selectImage: UIImage? { get }
    
    /// Changed when tool selected or not.
    var isSelected: Bool { set get }
    
    /// Block to lock or unlock edit content view. When lock, content view will scroll disabled.
    var contentLockStatus: ((Bool) -> Void)? { set get }
    
    /// View showed when tool is selected, use to change tool's setting. Return `nil` if no needed.
    var toolConfigView: (UIView & ADToolConfigable)? { set get }
    /// View interaction with user operations. Return `nil` if no needed.
    var toolInteractView: (UIView & ADToolInteractable)? { set get }
    
    /// Called when tool is selected.
    /// - Parameter ctx: The controller to present tool's detail view.
    /// - Returns: Return `true` if tool can seleced and deselect last selected tool. Otherwise, return `false`.
    func toolDidSelect(ctx: UIViewController?) -> Bool
        
}

public extension ADImageEditTool {
    var selectImage: UIImage? { return nil }
}

/// `ImageEditTool` can confirm this protocol to add ability to modify the original image.
public protocol ADSourceImageEditable {
    var modifySourceImage: ((UIImage) -> Void)? { get set }
}

/// `ImageEditTool` can confirm this protocol to add ability to do something when the original image is modify.
public protocol ADSourceImageModify {
    func sourceImageDidModify(_ image: UIImage)
}

/// Use to control tool's setting config view.
public protocol ADToolConfigable {
    
    /// Whether it can respond when clicked.
    /// - Parameters:
    ///   - point:  Point where user click.
    ///   - event: System event.
    /// - Returns: Return `true` if can response user's click. Otherwise, return `false`.
    func point(inside point: CGPoint, with event: UIEvent?) -> Bool
    
}

extension ADToolConfigable {
    public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
}

/// Tool's interaction view z-Index enum.
public enum ADInteractZIndex: Int {
    case Top = 100
    case Mid = 60
    case Bottom = 10
}

/// Tool's interaction view response strategy.
public enum ADInteractStrategy {
    /// Support multiple 'ADInteractType' to respond at the same time.
    case simult
    /// Support single 'ADInteractType' to respond at the same time.
    case single
    /// Support none 'ADInteractType' to respond.
    case none
}

/// Tool's interaction gesture type.
public enum ADInteractType {
    /// Pan gesture.
    /// - Parameters:
    ///     - loc: Location in interaction view.
    ///     - trans: Translation in interaction view.
    case pan(loc: CGPoint, trans: CGPoint)
    /// Pinch gesture.
    /// - Parameters:
    ///     - scale: Scale to last scale.
    ///     - point: Location in interaction view.
    case pinch(scale: CGFloat, point: CGPoint)
    /// Rotate gesture.
    /// - Parameters:
    ///     - angle: Angle to last angle.
    ///     - point: Location in interaction view.
    case rotate(angle: CGFloat, point: CGPoint)
}

/// Warp of interaction view clip info.
/// - Parameters:
///     - screen: Screen rect convert to tool's interaction view.
///     - clip: Clip rect to to tool's interaction view.
///     - rotate: Interaction view's rotation to orgin image.
///     - scale: Interaction view's scale to orgin image size.
public typealias ADClipingInfo = (screen: CGRect, clip: CGRect, rotate: ADRotation, scale: CGFloat)

/// Use to control tool's interaction view.
public protocol ADToolInteractable {
    
    /// Tool's interaction view z-Index in superview. The higher the value, the top the view.
    /// - Note: You can use `ADInteractZIndex.rawValue` or custom int value.
    /// - Note: System line draw tool's zIndex is `ADInteractZIndex.Bottom.rawValue+1`, mosaic draw tool's zIndex is `ADInteractZIndex.Bottom.rawValue`. System sticker tool's zIndex is `ADInteractZIndex.Top.rawValue`
    var zIndex: Int { get }
    
    /// Tool's interaction view response strategy.
    var strategy: ADInteractStrategy { get }
    
    /// Whether interaction view clip to clip rect bounds when interacting.
    /// - Note: Under normal circumstances, the size of the interactive view and the image are the same. Returning `false` means that the interactive area can exceed the boundary of the view during interaction, and vice versa.
    var interactClipBounds: Bool { get }
    
    /// Interaction view clip info use to congfig .
    var clipingScreenInfo: ADClipingInfo? { set get }
    
    /// Check if view can interact with gesture.
    /// - Parameters:
    ///   - gesture: User interaction gesture.
    ///   - point: Gesture location in view.
    /// - Returns: Return `true` if view can response user's interaction. Otherwise, return `false`.
    func shouldInteract(_ gesture: UIGestureRecognizer, point: CGPoint) -> Bool
    
    /// Do some action with user interaction.
    /// - Parameters:
    ///   - type: Interaction gesture type.
    ///   - scale: Interaction view's scale to orgin image size.
    ///   - state: Interaction gesture state.
    /// - Returns: Return delay time of interaction view become clip when `interactClipBounds` is `false`. Return `nil` or `0` means no delay.
    func interact(with type: ADInteractType, scale: CGFloat, state: UIGestureRecognizer.State) -> TimeInterval?
    
    /// Called before render view to image.
    func willBeginRenderImage()
    
    /// Called after render view to image.
    func didEndRenderImage()
}

extension ADToolInteractable {
    public func shouldInteract(_ gesture: UIGestureRecognizer, point: CGPoint) -> Bool { return false }
    
    public func interact(with type: ADInteractType, scale: CGFloat, state: UIGestureRecognizer.State) -> TimeInterval? { return nil }
    
    public func willBeginRenderImage() { }
    
    public func didEndRenderImage() { }
}

/// Image sticker select controller.
public typealias ADImageStickerSelectable = (UIViewController & ADImageStickerSelectConfigurable)
/// Use to define image sticker select controller.
public protocol ADImageStickerSelectConfigurable: AnyObject {
    
    /// Called when image is selected.
    var imageDidSelect: ((UIImage) -> Void)? { get set }
    
}

/// Text sticker color.
/// - Note: If sticker style is `normal`, text color is `primaryColor`.
///         If sticker style is `border`, text color is `secondaryColor` and border color is `primaryColor`.
public typealias ADTextStickerColor = (primaryColor: UIColor, secondaryColor: UIColor)

/// Text sticker info.
public struct ADTextSticker {
    
    /// Text sticker style.
    public enum Style {
        case normal
        /// Text with border.
        case border
    }
    
    /// Text sticker color.
    public var color: ADTextStickerColor
    /// Text sticker style.
    public var style: Style = .normal
    /// Text string.
    public var text: String?
}

/// Text sticker edit controller.
public typealias ADTextStickerEditable = (UIViewController & ADTextStickerEditConfigurable)
/// Use to define text sticker edit controller.
public protocol ADTextStickerEditConfigurable: AnyObject {
    
    /// Called when end edit.
    /// - Parameters:
    ///   - image: Image generate by text.
    ///   - sticker: Text sticker info.
    var textDidEdit: ((UIImage, ADTextSticker) -> Void)? { get set }
    
}

/// Image clip controller.
public typealias ADImageClipable = (UIViewController & ADImageClipConfigurable)
/// Use to define Image clip controller.
public protocol ADImageClipConfigurable: AnyObject {
    
    /// Called when clip finished.
    /// - Parameters:
    ///   - rect: Normalized clip rect. Return `nil` means no clip.
    ///   - rotation: Image rotation.
    var clipInfoConfirmBlock: ((CGRect?,ADRotation) -> Void)? { get set }
    
    /// Create with clip info.
    /// - Parameter clipInfo: Image clip info.
    init(clipInfo: ADClipInfo)
    
}

class ADImageEditConfigurable {
    
    static func imageStickerSelectVC() -> ADImageStickerSelectable {
        return ADPhotoKitConfiguration.default.customImageStickerSelectVC ?? ADImageStickerSelectController(dataSource: ADPhotoKitConfiguration.default.imageStickerDataSource!)
    }
    
    static func textStickerEditVC(sticker: ADTextSticker?) -> ADTextStickerEditable {
        return ADPhotoKitConfiguration.default.customTextStickerEditVCBlock?(sticker) ?? ADTextStickerEditController(sticker: sticker)
    }
    
    static func imageClipVC(clipInfo: ADClipInfo) -> ADImageClipable {
        return ADPhotoKitConfiguration.default.customImageClipVCBlock?(clipInfo) ?? ADImageClipController(clipInfo: clipInfo)
    }
    
}
