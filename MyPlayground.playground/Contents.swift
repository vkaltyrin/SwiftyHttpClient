import UIKit

var str = "Hello, playground"

struct Item: Decodable {
    let name: String
}

let json = """
[
    {
    "name": "Ivan"
    },
    {
    "name": "Ivan"
    }
]

""".data(using: .utf8)!

let array = try JSONDecoder().decode([Item].self, from: json)

print(array)
