## Copyright 2009 Intel Corporation
## SPDX-License-Identifier: Apache-2.0

# to run:  ./run_tests.ps1 <path to ospray source> <reference images ISA> [TEST_MPI]
# a new folder is created called build_regression_tests with results

$osprayDir=$args[0]
$testISA=$args[1]

$testMPI = $FALSE
$testMultiDevice = $FALSE
foreach ($arg in $args) {
  if ( $arg -eq "TEST_MPI" ) {
    $testMPI = $TRUE
  }
  if ( $arg -eq "TEST_MULTIDEVICE" ) {
    $testMultiDevice = $TRUE
  }
}

md build_regression_tests
cd build_regression_tests

$exitCode = 0

cmake -D OSPRAY_TEST_ISA=$testISA $osprayDir/test_image_data
$exitCode += $LastExitCode
cmake --build . --config Release --target ospray_test_data
$exitCode += $LastExitCode

md failed
ospTestSuite.exe --gtest_output=xml:tests.xml --baseline-dir=regression_test_baseline\ --failed-dir=failed
$exitCode += $LastExitCode

if ( $testMultiDevice ) {
  md failed-multidevice
  $Env:OSPRAY_NUM_SUBDEVICES = 2
  # post-processing not enabled on multidevice
  $test_filters = "DebugOp/ImageOp.ImageOp/0"
  $test_filters+=":DenoiserOp.DenoiserOp"
  ospTestSuite.exe --osp:load-modules=multidevice_cpu --osp:device=multidevice --gtest_output=xml:tests-multidevice.xml --baseline-dir=regression_test_baseline\ --failed-dir=failed-multidevice --gtest_filter="-$test_filters"
  $exitCode += $LastExitCode
}

if ( $testMPI ) {
  md failed-mpi
  $test_filters += ":TestScenesVariance/*"
  mpiexec.exe -np 1 ospTestSuite.exe --osp:load-modules=mpi_offload --osp:device=mpiOffload --gtest_output=xml:tests-mpi.xml --baseline-dir=regression_test_baseline\ --failed-dir=failed-mpi --gtest_filter="-$test_filters" : -np 2 ospray_mpi_worker.exe
  $exitCode += $LastExitCode

  md failed-mpi-data-parallel
  mpiexec.exe -np 3 -prepend-rank ospMPIDistribTestSuite.exe --gtest_output=xml:tests-mpi.xml --baseline-dir=regression_test_baseline\ --failed-dir=failed-mpi-data-parallel
  $exitCode += $LastExitCode
}

exit $exitCode
