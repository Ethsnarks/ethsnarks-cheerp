cmake_minimum_required(VERSION 2.8)

project(ethsnarks-cheerp)

set(CMAKE_VERBOSE_MAKEFILE on)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/build.cheerp)

set(USE_ASM OFF)
set(WITH_PROCPS OFF)
set(DEBUG OFF)
set(WITH_SUPERCOP OFF)
set(ETHSNARKS_DISABLE_UTILS ON)
set(ETHSNARKS_NO_THREADS ON)
set(CMAKE_CXX_FLAGS "--std=c++11 -O3 -target cheerp -cheerp-mode=wasm -cheerp-linear-heap-size=256 -fexceptions")
set(CMAKE_C_FLAGS "-O3 -target cheerp -cheerp-mode=wasm")

set(CMAKE_PREFIX_PATH ${CMAKE_CURRENT_SOURCE_DIR}/installroot)

set(PKG_CONFIG_USE_CMAKE_PREFIX_PATH on)

set(GMP_LIBRARY ${CMAKE_CURRENT_SOURCE_DIR}/installroot/lib/libgmp.a)
set(GMP_INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/installroot/include)
set(GMP_LIBRARIES ${CMAKE_CURRENT_SOURCE_DIR}/installroot/lib/libgmp.a)
set(GMPXX_LIBRARIES libgmpxx)


include_directories(SYSTEM ${CMAKE_CURRENT_SOURCE_DIR}/installroot/include)

add_subdirectory(ethsnarks)



include_directories(ethsnarks/src)
include_directories(
  ${DEPENDS_DIR}/libsnark
  ${DEPENDS_DIR}/libsnark/depends/libff
  ${DEPENDS_DIR}/libfqfft)


add_executable(test_primes test/primes.c)
target_link_libraries(test_primes ${GMP_LIBRARY})


add_executable(test_cheerp test/test_cheerp.cpp)
target_link_libraries(test_cheerp ff)
