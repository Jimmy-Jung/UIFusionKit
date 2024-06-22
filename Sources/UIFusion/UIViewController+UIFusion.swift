//
//  UIViewController+Extension.swift
//
//
//  Created by 정준영 on 2023/08/30.
//

import UIKit
import SnapKit
import Then

extension UIViewController: UIFusion {
    public enum TransitionStyle {
        case changeRootVC
        /// Present without navigation
        case present
        /// Present full screen without navigation
        case presentFull
        /// Present with embedded navigation
        case presentNavigation
        /// Present full screen with embedded navigation
        case presentFullNavigation
        /// Navigation push
        case pushNavigation
    }
}

public extension UIFusion where Self: UIViewController {
    /// Storyboard Transition
    /// - Parameters:
    ///   - storyboard: Storyboard's name
    ///   - viewController: ViewController's Meta Type
    ///   - style: Transition Style
    func transition<T: UIViewController>(
        storyboard: String,
        viewController: T.Type,
        style: TransitionStyle,
        animated: Bool = true,
        preprocessViewController: ((_ vc: T) -> ())? = nil) {
            let sb = UIStoryboard(name: storyboard, bundle: nil)
            guard let vc = sb
                .instantiateViewController(withIdentifier: viewController.identifier) as? T else {
                fatalError("There is a problem with making an instantiateViewController. The identifier may be incorrect.")
            }
            transition(
                viewController: vc,
                style: style,
                animated: animated,
                preprocessViewController: preprocessViewController
            )
        }
    
    /// ViewController Transition
    /// - Parameters:
    ///   - vc: ViewController Instance
    ///   - style: Transition Style
    func transition<T: UIViewController>(
        viewController vc: T,
        style: TransitionStyle,
        animated: Bool = true,
        preprocessViewController: ((_ vc: T) -> ())? = nil) {
            preprocessViewController?(vc)
            switch style {
                case .changeRootVC:
                    if let windowScene = UIApplication
                        .shared
                        .connectedScenes
                        .first as? UIWindowScene,
                       let window = windowScene
                        .windows
                        .first {
                        window.rootViewController = vc
                    } else {
                        fatalError("Unable to find a valid window scene")
                    }
                case .present:
                    present(vc, animated: animated)
                case .presentFull:
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: animated)
                case .presentNavigation:
                    let nav = UINavigationController(rootViewController: vc)
                    present(nav, animated: animated)
                case .presentFullNavigation:
                    let nav = UINavigationController(rootViewController: vc)
                    nav.modalPresentationStyle = .fullScreen
                    present(nav, animated: animated)
                case .pushNavigation:
                    navigationController?.pushViewController(vc, animated: animated)
            }
        }
}
