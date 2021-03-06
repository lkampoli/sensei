# Catalyst test expects the following arguments to be passed to cmake using
# -DFoo=BAR arguments.

# CATALYST_TEST_DRIVER  -- path to oscillator executable
# CATALYST_TEST_DIR     -- path to temporary dir
# CATALYST_TEST_DATA    -- path to where test input files are located
# IMAGE_TESTER          -- path to ImagesTester executable
# CATALYST_DATA_DIR     -- path to data dir for baselines

# MPIEXEC
# MPIEXEC_NUMPROC_FLAG
# MPIEXEC_NUMPROCS
# MPIEXEC_PREFLAGS
# VTK_MPI_POSTFLAGS

# remove result files generated by  the test
file(REMOVE "${CATALYST_TEST_DIR}/slice-9.png" )

if(NOT EXISTS "${CATALYST_TEST_DRIVER}")
  message(FATAL_ERROR "'${CATALYST_TEST_DRIVER}' does not exist")
endif()

message("Executing in ${CATALYST_TEST_DIR}:
      ${MPIEXEC} ${MPIEXEC_NUMPROC_FLAG} ${MPIEXEC_NUMPROCS} ${MPIEXEC_PREFLAGS}
      \"${CATALYST_TEST_DRIVER}\" -b 2 -t 1
      -f \"${CATALYST_TEST_DATA}/oscillator-catalyst-slice.xml\"
      \"${CATALYST_TEST_DATA}/oscillator-catalyst-slice.osc\""
  )

execute_process(COMMAND
  ${MPIEXEC} ${MPIEXEC_NUMPROC_FLAG} ${MPIEXEC_NUMPROCS} ${MPIEXEC_PREFLAGS}
  ${CATALYST_TEST_DRIVER} -b 2 -t 1
  -f ${CATALYST_TEST_DATA}/oscillator-catalyst-slice.xml
  ${CATALYST_TEST_DATA}/oscillator-catalyst-slice.osc
  WORKING_DIRECTORY ${CATALYST_TEST_DIR}
  RESULT_VARIABLE rv)

if(NOT rv EQUAL 0)
  message(FATAL_ERROR "Test executable return value was ${rv}")
endif()

if(NOT EXISTS "${CATALYST_TEST_DIR}/slice-9.png")
  message(FATAL_ERROR "'${CATALYST_TEST_DIR}/slice-9.png' was not created")
endif()

message("Comparing test output ${CATALYST_TEST_DIR}/slice-9.png against ${CATALYST_TEST_DATA}/slice-9.png baseline.")

execute_process(COMMAND "${IMAGE_TESTER}"
  "${CATALYST_TEST_DIR}/slice-9.png" 20 -V "${CATALYST_TEST_DATA}/slice-9.png" -T "${CATALYST_TEST_DIR}"
  RESULT_VARIABLE failed)
if(failed)
  message(FATAL_ERROR "slice-9.png image compare failed.")
endif()
