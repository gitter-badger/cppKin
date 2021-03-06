project(cppKin CXX)
cmake_minimum_required(VERSION 3.0)

set (CMAKE_CXX_STANDARD 14)
set (CMAKE_CXX_STANDARD_REQUIRED ON)
set (CMAKE_COLOR_MAKEFILE ON)
set (CMAKE_CXX_EXTENSIONS OFF)
set (CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} -fPIC)

if (NOT CMAKE_BUILD_TYPE)
    message(STATUS "Default build type 'Debug'")
    set(CMAKE_BUILD_TYPE DEBUG CACHE STRING "" FORCE )
else()
    string(TOUPPER ${CMAKE_BUILD_TYPE} CMAKE_BUILD_TYPE)
    message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
endif()

set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)
set(PROJECT_DIR ${CMAKE_CURRENT_SOURCE_DIR})
list(APPEND CMAKE_PREFIX_PATH ${EXTERNAL_PROJECT_DIR})

if(3RD_PARTY_INSTALL_STEP)
    find_package(SpdLog REQUIRED)
    find_package(Boost REQUIRED)
    find_package(Thrift REQUIRED)
    if(UNIX AND NOT APPLE)
        find_package(BenchMark REQUIRED)
    endif()
    include(installThirdParty)
endif()

if(PRE_COMPILE_STEP)
if (WIN32)
	include(cppkinMacro)
	LinuxPath_ToWinPath(${PROJECT_DIR} WIN_PROJECT_DIR)
	add_custom_target(THRIFT_BUILD ALL COMMAND ${WIN_PROJECT_DIR}\\IDL\\GenerateZipkin.bat ${WIN_PROJECT_DIR})
	add_custom_command(TARGET THRIFT_BUILD POST_BUILD COMMAND copy ${WIN_PROJECT_DIR}\\Third_Party\\Patch\\zipkinCore_constants.h ${WIN_PROJECT_DIR}\\GeneratedFiles COMMAND copy ${WIN_PROJECT_DIR}\\Third_Party\\Patch\\zipkinCore_constants.cpp ${WIN_PROJECT_DIR}\\GeneratedFiles)
else()
    add_custom_target(THRIFT_BUILD ALL COMMAND ${PROJECT_DIR}/IDL/GenerateZipkin.bash ${PROJECT_DIR})
endif()
endif()

if(COMPILATION_STEP)
    set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
    set(PROJECT_DIR ${CMAKE_CURRENT_SOURCE_DIR})
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_DIR}/bin)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY  ${PROJECT_DIR}/bin)
    set(CMAKE_BINARY_DIR ${PROJECT_DIR}/bin)
    set(EXECUTABLE_OUTPUT_PATH ${PROJECT_DIR}/bin)
    set(PROJECT_3RD_LOC ${CMAKE_CURRENT_SOURCE_DIR}/Third_Party)
    #Pre build step
    set(CORE_NO_3RD_PARTY True)
    set(CORE_NO_GLOBAL_HANDLING True)
    add_subdirectory(${PROJECT_DIR}/Core)
    if(UNIX AND NOT APPLE)
        add_subdirectory(${PROJECT_DIR}/bench)
    endif()

    include_directories(. ..  ${PROJECT_DIR}/src ${PROJECT_3RD_LOC}/include)
	link_directories(${PROJECT_3RD_LOC}/lib)
	add_definitions(-DA_DLL)
    add_library(cppkin SHARED src/Trace.h src/SpanContainer.h src/SpanContainer.cpp src/Span.cpp src/Span.h src/AnnotationType.cpp src/AnnotationType.h src/Annotation.h src/SimpleAnnotation.cpp src/SimpleAnnotation.h src/cppkin.h src/Trace.cpp src/Encoder.cpp src/Encoder.h src/EncodingTypes.cpp src/EncodingTypes.h src/EncodingContext.cpp src/EncodingContext.h src/TransportManager.cpp src/TransportManager.h src/Transport.cpp src/Transport.h src/ScribeTransport.cpp src/ScribeTransport.h src/ConfigTags.h src/TransportType.cpp src/TransportType.h src/TransportFactory.h src/TransportFactory.cpp src/EncoderBase64.h GeneratedFiles/scribe.cpp GeneratedFiles/Scribe_constants.cpp GeneratedFiles/Scribe_types.cpp GeneratedFiles/zipkinCore_constants.cpp GeneratedFiles/zipkinCore_types.cpp src/ConfigParams.cpp src/ConfigTags.cpp src/Annotation.cpp src/Sampler.cpp)
    #add_executable(cppkin src/Trace.h src/SpanContainer.h src/SpanContainer.cpp src/Span.cpp src/Span.h src/AnnotationType.cpp src/AnnotationType.h src/Annotation.h src/SimpleAnnotation.cpp src/SimpleAnnotation.h src/cppkin.h src/Trace.cpp src/Encoder.cpp src/Encoder.h src/EncodingTypes.cpp src/EncodingTypes.h src/EncodingContext.cpp src/EncodingContext.h src/TransportManager.cpp src/TransportManager.h src/Transport.cpp src/Transport.h src/ScribeTransport.cpp src/ScribeTransport.h src/ConfigTags.h src/TransportType.cpp src/TransportType.h src/TransportFactory.h src/TransportFactory.cpp src/EncoderBase64.h src/main.cpp GeneratedFiles/scribe.cpp GeneratedFiles/Scribe_constants.cpp GeneratedFiles/Scribe_types.cpp GeneratedFiles/zipkinCore_constants.cpp GeneratedFiles/zipkinCore_types.cpp src/ConfigParams.cpp src/ConfigTags.cpp src/Annotation.cpp src/Sampler.cpp)
	if(WIN32)
		set(TO_LINK_LIBS thriftmd)
	else()
		set(TO_LINK_LIBS pthread thrift)
	endif()
	target_link_libraries(cppkin Core ${TO_LINK_LIBS})
endif()
