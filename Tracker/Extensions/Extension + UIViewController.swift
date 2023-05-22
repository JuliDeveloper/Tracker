import UIKit

extension UIViewController {
    func showAlert(title: String?, message: String?, preferredStyle: UIAlertController.Style = .alert, actions: [UIAlertAction]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        
        for action in actions {
            alertController.addAction(action)
        }
        
        present(alertController, animated: true)
    }
}
