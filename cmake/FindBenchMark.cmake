find_path(BENCHMARK_INCLUDE_DIR NAMES benchmark PATHS ${PROJECT_DIR}/Third_Party/include NO_DEFAULT_PATH)
find_library(BENCHMARK_LIBRARY_DIR NAMES benchmark PATHS ${PROJECT_DIR}/Third_Party/lib NO_DEFAULT_PATH)
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(benchmark REQUIRED_VARS BENCHMARK_INCLUDE_DIR BENCHMARK_LIBRARY_DIR)

if(BENCHMARK_FOUND)
    message(STATUS "Found Benchmark include dir - ${BENCHMARK_INCLUDE_DIR}")
    message(STATUS "Found Benchmark library dir - ${BENCHMARK_LIBRARY_DIR}")
else()
    message(WARNING "Benchmark not found")
endif()
