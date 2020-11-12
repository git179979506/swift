// RUN: %target-run-simple-swift(%S/Inputs/main.swift %S/Inputs/consume-logging-metadata-value.swift -Xfrontend -prespecialize-generic-metadata -target %module-target-future) | %FileCheck %s
// REQUIRES: executable_test

// REQUIRES: VENDOR=apple || OS=linux-gnu
// UNSUPPORTED: CPU=i386 && OS=ios
// UNSUPPORTED: CPU=armv7 && OS=ios
// UNSUPPORTED: CPU=armv7s && OS=ios
// Executing on the simulator within __abort_with_payload with "No ABI plugin located for triple x86_64h-apple-ios -- shared libraries will not be registered!"
// UNSUPPORTED: CPU=x86_64 && OS=ios
// UNSUPPORTED: CPU=x86_64 && OS=tvos
// UNSUPPORTED: CPU=x86_64 && OS=watchos
// UNSUPPORTED: CPU=i386 && OS=watchos
// UNSUPPORTED: use_os_stdlib

class MyGenericClazz<T> {

  let line: UInt

  init(line: UInt = #line) {
    self.line = line
  }

}

extension MyGenericClazz : CustomStringConvertible {

  var description: String {
    "\(type(of: self)) @ \(line)"
  }

}

@inline(never)
func consume<T>(clazz: MyGenericClazz<T>) {
  consume(clazz)
}

@inline(never)
func consume<T>(clazzType: MyGenericClazz<T>.Type) {
  consume(clazzType)
}


public func doit() {
  // CHECK: [[FLOAT_METADATA_ADDRESS:[0-9a-f]+]] MyGenericClazz<Float> @ 46
  consume(MyGenericClazz<Float>())
  // CHECK: [[FLOAT_METADATA_ADDRESS]] MyGenericClazz<Float> @ 48
  consume(clazz: MyGenericClazz<Float>())

  // CHECK: [[DOUBLE_METADATA_ADDRESS:[0-9a-f]+]] MyGenericClazz<Double> @ 51
  consume(MyGenericClazz<Double>())
  // CHECK: [[DOUBLE_METADATA_ADDRESS]] MyGenericClazz<Double> @ 53
  consume(clazz: MyGenericClazz<Double>())

  // CHECK: [[INT_METADATA_ADDRESS:[0-9a-f]+]] MyGenericClazz<Int> @ 56
  consume(MyGenericClazz<Int>())
  // CHECK: [[INT_METADATA_ADDRESS]] MyGenericClazz<Int> @ 58
  consume(clazz: MyGenericClazz<Int>())

  // CHECK: [[STRING_METADATA_ADDRESS:[0-9a-f]+]] MyGenericClazz<String> @ 61
  consume(MyGenericClazz<String>())
  // CHECK: [[STRING_METADATA_ADDRESS]] MyGenericClazz<String> @ 63
  consume(clazz: MyGenericClazz<String>())

  // CHECK: [[NESTED_METADATA_ADDRESS:[0-9a-f]+]] MyGenericClazz<MyGenericClazz<String>> @ 66
  consume(MyGenericClazz<MyGenericClazz<String>>())
  // CHECK: [[NESTED_METADATA_ADDRESS:[0-9a-f]+]] MyGenericClazz<MyGenericClazz<String>> @ 68
  consume(clazz: MyGenericClazz<MyGenericClazz<String>>())

  // CHECK: [[FLOAT_METADATA_METATYPE_ADDRESS:[0-9a-f]+]] MyGenericClazz<Float>
  consume(MyGenericClazz<Float>.self)
  // CHECK: [[FLOAT_METADATA_METATYPE_ADDRESS]] MyGenericClazz<Float>
  consume(clazzType: MyGenericClazz<Float>.self)
}
