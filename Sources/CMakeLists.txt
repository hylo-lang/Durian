#
# The Swift module our clients depend on.
#
file(GLOB_RECURSE source_files FOLLOW_SYMLINKS LIST_DIRECTORIES false CONFIGURE_DEPENDS Durian/*.swift)
add_library(Durian ${source_files})

# This is required in order to be a testee.
set_target_properties(Durian
  PROPERTIES FRAMEWORK TRUE
)

target_compile_options(Durian
  PRIVATE $<$<BOOL:${BUILD_TESTING}>:-enable-testing>)
