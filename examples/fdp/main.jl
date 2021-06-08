## ph for FDP example
import DataRegistryUtils

## basic model run
function example()
    ## initialise
    # config_file = "examples/fdp/config.yaml"
    # handle = DataRegistryUtils.initialise(config_file)
    # ## read some data
    # # - read data product
    # hc = DataRegistryUtils.fdp_read_array(handle, "human/commutes")
    # # - read external object by alias
    # ct = DataRegistryUtils.link_read(handle, "crummy_table")
    ## TBC:
    # - write data (e.g. array)
    # - register model run (NB. does this require a patch to code_run?)
end

## whats_my_file example
function whats_my_example()
    some_filepath = "examples/simple/data/1e20f69b-c998-4048-a1ff-1543bb7f1a2c"
    ## run for this file only
    DataRegistryUtils.whats_my_file(some_filepath)
    # - same again but display remote file path (can be messy)
    DataRegistryUtils.whats_my_file(some_filepath, show_path=true)
    # - run for an entire directory
    some_dir = "examples/simple/data/"
    DataRegistryUtils.whats_my_file(some_dir)
end

## run examples:
# example()
whats_my_example()
