import UIKit
import SwiftUI
import React

// MARK: - SwiftUI Liquid Glass View (iOS 26+)
@available(iOS 26.0, *)
struct LGBackground: View {
  var body: some View {
    Rectangle()
      .fill(Color.clear)
      .glassContainerEffect()
      .edgesIgnoringSafeArea(.all)
  }
}

// MARK: - UIView wrapper with iOS 26 Liquid Glass / fallback blur
@objc(LiquidGlassContainerView)
public class LiquidGlassContainerView: UIView {
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }

  private func setup() {
    if #available(iOS 26.0, *) {
      let host = UIHostingController(rootView: LGBackground())
      host.view.translatesAutoresizingMaskIntoConstraints = false
      host.view.backgroundColor = .clear
      host.view.isUserInteractionEnabled = false
      addSubview(host.view)
      NSLayoutConstraint.activate([
        host.view.topAnchor.constraint(equalTo: topAnchor),
        host.view.bottomAnchor.constraint(equalTo: bottomAnchor),
        host.view.leadingAnchor.constraint(equalTo: leadingAnchor),
        host.view.trailingAnchor.constraint(equalTo: trailingAnchor),
      ])
    } else {
      let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
      blur.translatesAutoresizingMaskIntoConstraints = false
      blur.backgroundColor = UIColor(white: 0.08, alpha: 0.25)
      addSubview(blur)
      NSLayoutConstraint.activate([
        blur.topAnchor.constraint(equalTo: topAnchor),
        blur.bottomAnchor.constraint(equalTo: bottomAnchor),
        blur.leadingAnchor.constraint(equalTo: leadingAnchor),
        blur.trailingAnchor.constraint(equalTo: trailingAnchor),
      ])
    }
  }
}

// MARK: - React Native View Manager
@objc(LiquidGlassContainerViewManager)
class LiquidGlassContainerViewManager: RCTViewManager {
  override func view() -> UIView! {
    return LiquidGlassContainerView()
  }

  override static func requiresMainQueueSetup() -> Bool {
    return true
  }
}
