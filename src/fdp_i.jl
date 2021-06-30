### new interface for FAIR data pipeline ###
# - implements: https://scottishcovidresponse.github.io/docs/data_pipeline/interface/
# - UPDATED 29/6: https://fairdatapipeline.github.io/docs/interface/example1/

## BASELINE FDP FUNCTIONALITY:
# fdp pull config.yaml
# fdp run config.yaml
# fdp push config.yaml
## NB. 'fdp' -> FAIR

## LOCAL DR INSTRUCTIONS:
# - start using: ~/.fair/registry/scripts/start_fair_registry
# - stop using: ~/.fair/registry/scripts/stop_fair_registry
# - view tcp using: sudo netstat -ntap | grep LISTEN

## produced by initialise
# - add LDR property?
struct DataRegistryHandle
   config_file    # working config file
   wc_obj_uri     # config file id
   ss_obj_uri     # submission script file id
end
# - NB. FAIR RUN [server] gets called by user using CI tool

## registry token
function get_access_token()
   # fp = "~/.fair/registry/token" # NB. v THIS IS A HACK **
   fp = "/home/martin/.fair/registry/token"
   token = open(fp) do file
      return read(file, String)
   end
   return string("token ", token)
end

## register code repo release (i.e. model code)
# - PP per meeting 29/6
# function register_code_repo(name::String, version::String, repo::String,
#    hash::String, scrc_access_tkn::String, description::String,
#    website::String, storage_root_url::String, storage_root_id::String)
#
#    ## UPDATED: check name/version
#    crr_chk = search_code_repo_release(name, version)
#    sl_path = replace(repo, storage_root_url => "")
#    if crr_chk["count"] == 0
#       obj_id = insert_storage_location(sl_path, hash, description, storage_root_id, scrc_access_tkn)
#       ## register release
#       body = (name=name, version=version, object=obj_id, website=website)
#       resp = http_post_data("code_repo_release", body, scrc_access_tkn)
#       println("NB. new code repo release registered. URI := ", resp["url"])
#       return resp["url"]
#    else
#       ## check repo is the same
#       # NB. check SR match?
#       resp = http_get_json(crr_chk["results"][1]["object"])
#       resp = http_get_json(resp["storage_location"])
#       sl_path  == resp["path"] || println("WARNING: repo mismatch detected := ", sl_path, " != ", resp["path"])
#       println("NB. code repo release := ", crr_chk["results"][1]["url"])
#       return crr_chk["results"][1]["url"]
#    end
# end

## register storage root
function register_storage_root(path_root::String, is_local::Bool)
   # il = is_local ? "True" : "False"
   body = Dict("root"=>path_root, "local"=>is_local)
   resp = http_post_data("storage_root", body, get_access_token())
   return resp["url"]
end

## return default SR URI
function get_default_sroot() #, handle::DataRegistryHandle
   url = string(API_ROOT, "storage_root/?updated_by=&last_updated=&root=&local=true")
   resp = http_get_json(url)
   if resp["count"]==0
      ## add df
      sr = register_storage_root("file:///", true)
      return sr
   else
      return resp["results"][1]["url"]
   end
end

## replacement for fetch_data_per_yaml
# - NB. add offline_mode option?
"""
    initialise(config_file, submission_script)

Read [working] config.yaml file. Returns a `DataRegistryHandle` containing:
- the working config.yaml file contents
- the object id for this file
- the object id for the submission script file
"""
function initialise(config_file::String, submission_script::String; code_repo=nothing)
   C_CF_DESC = "Working config file."
   C_SS_DESC = "Submission script (Julia.)"
   ##
   storage_root_uri = get_default_sroot()
   # cf_obj_uri = insert_storage_location(config_file, get_file_hash(config_file), C_CF_DESC, storage_root_id)#, scrc_access_tkn
   # return DataRegistryHandle(config_file, cf_obj_uri, ss_obj_uri)
   # ss_obj_uri =
   # repo_obj_id
   ## 1. download data/metadata from RDR and register: sources
   # fdp pull config_file
   ## 2. read [user] config_file and generate working config .yaml
   # fdp run config_file
end

## nb. what does 'alias recorded in handle'? that it exists in the working config file? if not, how can it be
"""
    link_read(handle, alias)

This function returns the path of an external object in the local data store:
- If the alias is already recorded in the handle, returns the path. If not, find the location of the file referenced by its alias.
- Also, stores metadata associated with the external object.
- Note that the alias is not recorded in the data registry. Rather, it is a means to reference external objects in the `config.yaml` file.
"""
function link_read(handle::DataRegistryHandle, alias::String)
   ## 1. API call to LDR
   ## 2. return [path of an external object in the local data store]
end

## add alias?
"""
    fdp_read_estimate(handle, data_product; component, version)

Read TOML-based data product.
- note that it must already have been downloaded from the remote data store using `fdp pull`.
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
- note that it must already have been downloaded from the remote data store using `fdp pull`.
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
- note that it must already have been downloaded from the remote data store using `fdp pull`.
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

Pass the object URI as a named parameter[s], e.g. `raise_issue(handle; data_product=dp, component=comp)`.

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
