import Quick
import Nimble

public typealias asyncCompletion<T> = ((Result<T, Error>) -> Void)

public func runAsyncExpectingSuccess<T>(_ asyncCallback: (@escaping asyncCompletion<T>) -> Void, when action: () -> Void) -> T? {
    let response = runAndWaitForAsyncCall(asyncCallback, when: action)
    
    switch response {
    case .success(let receivedResult):
        return receivedResult
    default:
        fail("should not fail")
        return nil
    }
}

public func runAsyncExpectingFailure<T>(_ asyncCallback: (@escaping asyncCompletion<T>) -> Void, when action: () -> Void) -> Error? {
    let response = runAndWaitForAsyncCall(asyncCallback, when: action)
    
    switch response {
    case .failure(let receivedError):
        return receivedError
    default:
        fail("should not succeed")
        return nil
    }
}

public func runAndWaitForAsyncCall<T>(_ asyncCallback: (@escaping asyncCompletion<T>) -> Void, when action: () -> Void) -> Result<T, Error> {
    
    let exp = QuickSpec.current.expectation(description: "wait")
    var receivedResult: Result<T, Error>!
    asyncCallback() {
        receivedResult = $0
        exp.fulfill()
    }
    
    action()
    QuickSpec.current.wait(for: [exp], timeout: 1)
    
    return receivedResult

}
