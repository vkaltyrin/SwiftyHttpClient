import Unbox

 final class SuccessResponse: Unboxable {

     let value: Bool
    
     init(value: Bool) {
        self.value = value
    }
    
    // MARK: - Unboxable
     init(unboxer: Unboxer) throws {
        value = try unboxer.unbox(key: "success")
    }
}
