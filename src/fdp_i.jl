### new interface for FDP ###
# - implements: https://scottishcovidresponse.github.io/docs/data_pipeline/interface/

## BASELINE FDP FUNCTIONALITY:
# fdp pull config.yaml
# fdp run config.yaml
# fdp push config.yaml

## produced by initialise
# - add LDR property?
struct DataRegistryHandle
   config_file
   working_config
   wc_obj_id      # config file id
   ss_obj_id      # submission script file id
end

## replacement for fetch_data_per_yaml
# - NB. add offline_mode option?
"""
    initialise(config_file)

Read working config.yaml file. Returns a `DataRegistryHandle` containing:
- the working config.yaml file contents
- the object id for this file
- the object id for the submission script file
"""
function initialise(config_file::String)
   ## 1. download data/metadata from RDR and register: sources
   # fdp pull config_file
   ## 2. read [user] config_file and generate working config .yaml
   # fdp run config_file
end

## nb. what does 'alias recorded in handle'? that it exists in the working config file? if not, how can it be
"""
   link_read(handle, alias)

This function returns the path of an external object in the local data store:
- if the alias is already recorded in the handle, returns the path. If not, find the location of the file referenced by its alias.
- note that the alias is not recorded in the data registry, rather, it’s a means to reference external objects in the config.yaml
- store metadata associated with the external object.
"""
function link_read(handle::DataRegistryHandle, alias::String)
   ## 1. API call to LDR
   ## 2. return [path of an external object in the local data store]
end

## add alias?
"""
   fdp_read_estimate(handle, data_product; component, version)

Read TOML-based data product.
- note that it must already have been downloaded from the remote data store using ``fdp pull``.
- the latest version of the data is read unless otherwise specified.
"""
function fdp_read_estimate(handle::DataRegistryHandle, data_product::String; component=nothing, version=nothing)
   ## 1. API call to LDR
   ## 2. read estimate from TOML file and return
   # FILL IN
end

## add alias?
"""
   fdp_read_array(handle, data_product; component, version)

Read [array] data product.
- note that it must already have been downloaded from the remote data store using ``fdp pull``.
- the latest version of the data is read unless otherwise specified.
"""
function fdp_read_array(handle::DataRegistryHandle, data_product::String; component=nothing, version=nothing)
   ## 1. API call to LDR
   ## 2. read array from file -> process
   # FILL IN
end

## add alias?
"""
   fdp_read_table(handle, data_product; component, version)

Read [table] data product.
- note that it must already have been downloaded from the remote data store using ``fdp pull``.
- the latest version of the data is read unless otherwise specified.
"""
function fdp_read_table(handle::DataRegistryHandle, data_product::String; component=nothing, version=nothing)
   ## 1. API call to LDR
   ## 2. read array from file -> process
   # FILL IN
end

##
"""
   link_write(handle, alias)

For writing external objects.

Use link_read() and link_write() to read and write external objects, rather than the standard API read_xxx() and write_xxx() calls.
"""
function link_write(handle::DataRegistryHandle, alias::String)
   ## 1. API call to LDR (register)
end

## write_array
"""
   write_array()

Write an array as a component to an hdf5 file.

WIP.
"""
function write_array(handle::DataRegistryHandle, data_product::String, component::String)
   ## 1. API call to LDR (retrieve metadata)
   ## 2. register dp (possibly)
   ## 3. register component (definitely)
end

## register issue with data product; component; externalobject; or script
"""
   raise_issue(handle; ... )

Register issue with data product; component; external object; or script.

Pass the object URI as a named parameter[s], e.g. ``raise_issue(handle; data_product=dp, component=comp)``.

**Optional parameters**
- `data_product`
- `component`
- `external_object`
- `script`
"""
function raise_issue(handle::DataRegistryHandle; data_product=nothing, component=nothing, external_object=nothing, script=nothing)
   ## 1. API call to LDR (retrieve metadata)
   ## 2. register issue to LDR
   # FILL IN
end
