// RUN: %target-swift-frontend(mock-sdk: %clang-importer-sdk) -typecheck -I %S/Inputs/custom-modules -enable-experimental-concurrency %s -verify -verify-ignore-unknown

// REQUIRES: objc_interop
// REQUIRES: concurrency
import Foundation
import ObjCConcurrency

// Conform via async method
class C1: ConcurrentProtocol {
  func askUser(toSolvePuzzle puzzle: String) async throws -> String { "" }

  func askUser(toJumpThroughHoop hoop: String) async -> String { "hello" }
}

// Conform via completion-handler method
class C2: ConcurrentProtocol {
  func askUser(toSolvePuzzle puzzle: String, completionHandler: ((String?, Error?) -> Void)?) {
    completionHandler?("hello", nil)
  }

  func askUser(toJumpThroughHoop hoop: String, completionHandler: ((String) -> Void)?) {
    completionHandler?("hello")
  }
}

// Conform via both; this is an error
class C3: ConcurrentProtocol {
  // expected-note@+1{{method 'askUser(toSolvePuzzle:)' declared here}}
  func askUser(toSolvePuzzle puzzle: String) async throws -> String { "" }

  // expected-error@+1{{'askUser(toSolvePuzzle:completionHandler:)' with Objective-C selector 'askUserToSolvePuzzle:completionHandler:' conflicts with method 'askUser(toSolvePuzzle:)' with the same Objective-C selector}}
  func askUser(toSolvePuzzle puzzle: String, completionHandler: ((String?, Error?) -> Void)?) {
    completionHandler?("hello", nil)
  }
}

// Conform but forget to supply either. Also an error.
// FIXME: Suppress one of the notes?
class C4: ConcurrentProtocol { // expected-error{{type 'C4' does not conform to protocol 'ConcurrentProtocol'}}
}

class C5 {
}

extension C5: ConcurrentProtocol {
  func askUser(toSolvePuzzle puzzle: String, completionHandler: ((String?, Error?) -> Void)?) {
    completionHandler?("hello", nil)
  }

  func askUser(toJumpThroughHoop hoop: String, completionHandler: ((String) -> Void)?) {
    completionHandler?("hello")
  }
}
