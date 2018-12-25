import UIKit
import HTTPClient

class ViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    var httpClient: HTTPClient!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordTextField.isSecureTextEntry = true
        
        let logger = LoggerImpl { [weak self] cUrl in
            self?.log(cUrl)
        }
        httpClient = HTTPClientFactoryImpl().githubHTTPClient(logger: logger)
    }
    
    private func showError(error: RequestError<GithubErrorResponse>) {
        switch error {
        case .apiError(let apiError):
            showMessage(message: apiError.message)
        default:
            showMessage(message: "Other error")
        }
    }

    private func showMessage(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onLoginTap(_ sender: Any) {
        guard let username = usernameTextField.text, let password = passwordTextField.text else {
            return
        }
        
        let request = GithubUserRepositoriesRequest(
            username: username,
            password: password,
            visibility: .private
        )
        httpClient.send(request: request) { [weak self] result in
            result.onData { [weak self] response in
                self?.log(response)
            }
            result.onError { error in
                switch error {
                case .apiError(let apiError):
                    self?.log(apiError)
                default:
                    self?.log("Error. Debug for investigation.")
                }
            }
        }
    }
    
    private func log(_ text: String) {
        textView.text.append(contentsOf: "\n\(text)")
    }
    
    private func log(_ encodable: Encodable) {
        log(encodable.log)
    }
    
}
