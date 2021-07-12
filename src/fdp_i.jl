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
# NB. add code run id
struct DataRegistryHandle
   config::Dict         # working config file data
   wc_obj_uri::String   # config file object id
   ss_obj_uri::String   # submission script object file id
   crr_obj_uri          # code repo object file id (optional)
   working_dir          # working directory for this session
   # user_id           # [local registry] user_id
end
# - NB. FAIR RUN [server] gets called by user using CI tool

## registry token
function get_access_token(user_id::Int=1)
   # fp = "~/.fair/registry/token" # NB. v THIS IS A HACK **
   # fp = "/home/martin/.fair/registry/token"
   # token = open(fp) do file
   #    return read(file, String)
   # end
   # return string("token ", token)
   db_path = string(homedir(), "/.fair/registry/db.sqlite3")
   db = SQLite.DB(db_path)
   sel_stmt = SQLite.Stmt(db, "SELECT key FROM authtoken_token WHERE user_id=?")
   qr = SQLite.DBInterface.execute(sel_stmt, (user_id, )) |> DataFrames.DataFrame
   return string("token ", qr[1,1])
end

### upload to data registry
# - NB. what about user ID? Always == 1?
function http_post_data(endpoint::String, data)
    url = string(API_ROOT, endpoint, "/")
    headers = Dict("Authorization"=>get_access_token(), "Content-Type" => "application/json")
    body = JSON.json(data)
    C_DEBUG_MODE && println(" POSTing data to := ", url, ": \n ", body)
    r = HTTP.request("POST", url, headers=headers, body=body)
    # resp = String(r.body)
    resp = replace(String(r.body), "http://localhost/api/" => "http://localhost:8000/api/")
    println(" - Response: \n ", resp)
    return JSON.parse(resp)
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
   resp = http_post_data("storage_root", body)
   return resp["url"]
end

## check storage location
function search_storage_root(path::String, is_local::Bool)
    search_url = string(API_ROOT, "storage_root/?root=", HTTP.escapeuri(path), "&local=", is_local)
    return http_get_json(search_url)
end

## return default SR URI
function get_local_sroot(path::String) #, handle::DataRegistryHandle
   file_path = string("file://", path)
   resp = search_storage_root(file_path, true)
   if resp["count"]==0  # add
      return register_storage_root(file_path, true)
   else                 # retrieve
      return resp["results"][1]["url"]
   end
end

## register/retrieve storage location and return uri
function get_storage_location(path::String, hash::String, root_id::String)
   resp = search_storage_location(path, hash, root_id)
   # println("SSL: ", resp)
   if resp["count"]==0  # add
      body = Dict("path"=>path, "hash"=>hash, "storage_root"=>root_id)
      resp = http_post_data("storage_location", body)
      return resp["url"]
   else
      return resp["results"][1]["url"]
   end
end

## register and return object uri
# NB. what about authors / filetype?
function register_object(path::String, hash::String, description::String, root_uri::String)
   sl_uri = get_storage_location(path, hash, root_uri)
   ## add object
   body = (description=description, storage_location=sl_uri)
   resp = http_post_data("object", body)
   return resp["url"]
end

##
function register_code_run(handle::DataRegistryHandle, description::String)
    rt = Dates.now()
    ## inputs / outputs - TBA ****
    # - OBJECT COMPONENTS
    # body = (object=run_obj_id, name=inputs, description=)
    # resp = http_post_data("object_component", body, scrc_access_tkn)
    inputs = []
    outputs = []

    ## use Dict? **
    body = (run_date=rt, description=description, model_config=handle.wc_obj_uri, submission_script=handle.ss_obj_uri, inputs=inputs, outputs=outputs)
    if !isnothing(handle.crr_obj_uri)
      body["code_repo"] = handle.crr_obj_uri
    end
    resp = http_post_data("code_run", body)
    return resp["url"]
end

## yaml config ifnull helper
function ifnull_prop(data::Dict, property::String, ifnull::String="default")
   if haskey(data, property)
      return data[property]
   else
      return ifnull
   end
end

## process yaml config file
# function process_config_yaml(d::String, out_dir::String)
#     println("processing config file: ", d)
#     data = YAML.load_file(d)
#     md = data["run_metadata"]
#     rd = data["read"]
#     df_ns_cd = get_ns_cd(data["namespace"])
#     fail_on_hash_mismatch = data["fail_on_hash_mismatch"]
#     err_cnt = 0
#     output = NamedTuple[]
#     for dp in keys(rd)
#         dpd = rd[dp]
#         ns = haskey(dpd, "namespace") ? dpd["namespace"] : data["namespace"]
#         (haskey(dpd, "use") && haskey(dpd["use"], "namespace")) && (ns = dpd["use"]["namespace"])
#         dpnm = dpd["where"]["data_product"]
#         fetch_version = get_version_str(dpd)
#         verbose && println(" - fetching data: ", dpnm, " : version := ", fetch_version)
#         res = refresh_dp(dpnm, get_ns_cd(dpd, df_ns_cd), fetch_version, out_dir, verbose, fail_on_hash_mismatch)
#         res.chk.pass || (err_cnt += 1)
#         sl_path = isnothing(res.sl) ? "" : res.sl.sl_path
#         sr_url = isnothing(res.sl) ? "" : res.sl.sr_url
#         description = isnothing(res.sl.description) ? "" : res.sl.description
#         op = (namespace=ns, dp_name=dpd["where"]["data_product"], filepath=res.chk.file_path,
#             dp_hash=res.chk.file_hash, dp_version=res.version, sr_url=sr_url,
#             sl_path=sl_path, description=description, registered=res.chk.pass, dp_url=res.url)
#         push!(output, op)
#     end
#     println(" - files refreshed", err_cnt == 0 ? "." : ", but issues were detected.")
#     return (metadata=output, config=data)
# end

## replacement for fetch_data_per_yaml
# - NB. add offline_mode option?
"""
    initialise(config_file, submission_script)

Read [working] config.yaml file. Returns a `DataRegistryHandle` containing:
- the working config.yaml file contents
- the object id for this file
- the object id for the submission script file
"""
function initialise(config_file::String, submission_script::String; code_repo=nothing, working_dir=pwd())
   C_CF_DESC = "Working config file."
   C_SS_DESC = "Submission script (Julia.)"
   ## 1. download data/metadata from RDR and register: sources
   # fdp pull config_file
   ## 2. read [user] config_file and generate working config .yaml
   # fdp run config_file
   ## 3.
   println("processing config file: ", config_file)
   config = YAML.load_file(config_file)
   println(typeof(config))
   ##
   storage_root_uri = get_local_sroot(working_dir)
   cf_obj_uri = register_object(config_file, get_file_hash(config_file), C_CF_DESC, storage_root_uri)#, scrc_access_tkn
   ss_obj_uri = register_object(submission_script, get_file_hash(submission_script), C_SS_DESC, storage_root_uri)#, scrc_access_tkn
   crr_obj_uri = nothing # TEMP: code_repo[_release]
   return DataRegistryHandle(config, cf_obj_uri, ss_obj_uri, crr_obj_uri, working_dir)
end

"""
    finalise(handle)

Complete (i.e. finish) code run.
"""
function finalise(handle::DataRegistryHandle; comments::String="Julia code run.")
   ## register code run
   register_code_run(handle, comments)
   # register_code_run(model_config::String, submission_script_text::String
       # , code_repo_release_uri::String, model_run_description::String, scrc_access_tkn::String)
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
function write_array(data_product::String, component::String, data::Array; handle::DataRegistryHandle)
   ## 1. API call to LDR (retrieve metadata)
   ## 2. register dp (possibly)
   ## 3. register component (definitely)
end

## register [generic] data product
# NB. need to add outputs to handle prior to this point ***
function register_data_product(handle::DataRegistryHandle, filepath::String, data_product::String) #component::String,
   C_DF_DESC = "Data product registered using DataRegistryUtils.jl."
   C_DF_VERSION = "0.1.0"
   if haskey(handle.config, "write")
      wmd = handle.config["write"]
      println(wmd)
      for i in eachindex(wmd)
         if wmd[i]["data_product"] == data_product
            ## register object
            hash = get_file_hash(filepath)
            description = ifnull_prop(wmd[i], "description", C_DF_DESC)
            storage_root_uri = get_local_sroot(handle.working_dir)
            obj_url = register_object(filepath, hash, description, storage_root_uri)
            ## register dp
            namespace = ifnull_prop(wmd[i]["use"], "namespace", ifnull_prop(handle.config["run_metadata"], "default_output_namespace"))
            version = ifnull_prop(wmd[i]["use"], "version", C_DF_VERSION)
            body = (namespace=namespace, name=data_product, version=version, object=obj_url)
            resp = http_post_data("data_product", body)
            println("NB. new data product registered as ", resp["url"])
            return resp["url"]
         end
      end
      println("WARNING: '", data_product, "' not found - check config file.")
   else
      println("WARNING: no 'write' section found - check config file.")
   end
   return nothing
end

## write_array
"""
    write_table()

Write an table as a component to an hdf5 file.

WIP.
"""
function write_table(data_product::String, data; handle::DataRegistryHandle)
   ## write to CSV file
   ## 1. API call to LDR (retrieve metadata)
   ## 2. register dp (possibly)
   # 3. register component (definitely)
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
