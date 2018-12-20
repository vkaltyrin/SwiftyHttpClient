import UIKit
import HTTPClient

class ViewController: UIViewController {
    
    let httpClient = HTTPClientFactoryImpl().githubHTTPClient()
    let githubAPI = GithubAPI()

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let request = githubAPI.searchRepositoriesRequest(query: "swift", sort: .stars, order: .desc)
//        httpClient.send(request: request) { result in
//            result.onData { response in
//
//            }
//            result.onError { [weak self] error in
//                self?.showError(error: error)
//            }
//        }
        let request = githubAPI.basicAuthorization(username: "vkasci@gmail.com", password: "9Carman33")
        httpClient.send(request: request) { [weak self] result in
            result.onData { response in
                
            }
            result.onError { error in
                
            }
        }
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
}
