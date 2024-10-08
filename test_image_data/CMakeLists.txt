## Copyright 2009 Intel Corporation
## SPDX-License-Identifier: Apache-2.0

cmake_minimum_required(VERSION 3.5)

project(ospray_test_data NONE)

# Baseline images for tests and benchmarks
include(ExternalData)

# Variable determines which reference images will be used for testing
set(OSPRAY_TEST_ISA "AVX512SKX" CACHE STRING "Reference images ISA")
set_property(CACHE OSPRAY_TEST_ISA PROPERTY STRINGS AVX2 AVX512SKX)

set(ExternalData_URL_TEMPLATES
  "https://www.ospray.org/ospray-test-data/%(algo)/%(hash)"
  "https://www.ospray.org/ospray-test-data/%(algo)/%(hash)" # retry on error
)

file(TO_CMAKE_PATH "$ENV{STORAGE_PATH}" STORAGE_PATH)

set(ExternalData_OBJECT_STORES
  "${CMAKE_BINARY_DIR}/regression_test_baseline"
  "${STORAGE_PATH}/projects/OSPRay/test-data"
)

set(ExternalData_BINARY_ROOT ${CMAKE_BINARY_DIR}/regression_test_baseline)
set(ExternalData_SOURCE_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/baseline/${OSPRAY_TEST_ISA})

ExternalData_Expand_Arguments(ospray_test_data
  ospray_test_suite
  DATA{${ExternalData_SOURCE_ROOT}/,REGEX:.*}
)

ExternalData_Add_Target(ospray_test_data)

set_target_properties(ospray_test_data PROPERTIES EXCLUDE_FROM_ALL TRUE)
