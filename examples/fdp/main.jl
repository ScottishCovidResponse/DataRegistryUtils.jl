## ph for FDP example
import DataRegistryUtils

function example()
    some_filepath = "examples/simple/data/1e20f69b-c998-4048-a1ff-1543bb7f1a2c"
    ## run for this file only
    DataRegistryUtils.whats_my_file(some_filepath)
    # - same again but display remote file path (can be messy)
    DataRegistryUtils.whats_my_file(some_filepath, show_path=true)
    # - run for an entire directory
    some_dir = "examples/simple/data/"
    DataRegistryUtils.whats_my_file(some_dir)
end
example()
