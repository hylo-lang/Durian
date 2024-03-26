find_package(GenerateSwiftXCTestMain)
find_package(SwiftXCTest)

file(GLOB_RECURSE test_files
  FOLLOW_SYMLINKS
  LIST_DIRECTORIES false
  CONFIGURE_DEPENDS DurianTests/*.swift)

add_swift_xctest(DurianTests Durian ${test_files})
