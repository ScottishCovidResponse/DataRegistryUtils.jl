####  Simple examples for new FAIR version of the DP  ####
# This implements:
# https://fairdatapipeline.github.io/docs/interface/example0/
# Steps (PLACE HOLDER):                                                    Code:
# 1. preliminaries                                          L24
# 2. config files and scripts                               L32
# 3. read data products from the DR                         L43
# 4. run model simulation                                   L65
# 4b. automatic data access logging                         L103
# 5. stage 'code repo release' (i.e. model code)            L107
# 6. stage model 'code run'                                 L111
# 7. commit staged objects to the Registry                  L133
#
# Author:   Martin Burke (martin.burke@bioss.ac.uk)
# Date:     24-Jun-2021
#### #### #### #### ####

## LOCAL DR INSTRUCTIONS:
# - start using: ~/.scrc/scripts/run_scrc_server
# - stop using: ~/.scrc/scripts/stop_scrc_server
# - view tcp using: sudo netstat -ntap | grep LISTEN
import DataRegistryUtils

ss = "examples/simple2/main.jl"
## 1. Empty code run
# wc = "examples/simple2/working_config1.yaml"
# handle = DataRegistryUtils.initialise(wc, ss)
# DataRegistryUtils.finalise(handle; comments="Empty code run example.")

## 2. Write data product (HDF5)
# wc = "examples/simple2/working_config2.yaml"
# handle = DataRegistryUtils.initialise(wc, ss)

## 3. Read data product (HDF5)

## 4. Write data product (csv)
wc = "examples/simple2/working_config4.yaml"
handle = DataRegistryUtils.initialise(wc, ss)
# DataRegistryUtils.write_table(handle, tmp, "test/csv")
DataRegistryUtils.register_data_product(handle, "examples/register/tbl.csv", "test/csv")
DataRegistryUtils.finalise(handle; comments="Write CSV example.")

## 5. Write data product (point estimate)
