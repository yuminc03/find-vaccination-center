import UIKit

/// custom navigationBar를 사용해도 swipe back을 활성화
extension UINavigationController {
  open override func viewDidLoad() {
    super.viewDidLoad()
    interactivePopGestureRecognizer?.delegate = nil
  }
}
