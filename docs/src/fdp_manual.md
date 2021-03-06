# FDP interface manual
This is the updated manual for the upcoming `fdp` interfaced version of the package.

```@contents
Pages = ["fdp_manual.md"]
Depth = 3
```

Note that data products are processed and downloaded at the point of initialisation, provided that a `data_config` file is specified, and the `offline_mode` option is not used.

## Reading / downloading data

### Downloading data products

```@docs
initialise
```

### Reading data
Note that the `fdp_` prefix is temporary to avoid inline docs clashes with the existing functionality.

```@docs
fdp_read_estimate
fdp_read_array
fdp_read_table
```

### Extenal objects

NB. per the [Data pipeline docs](https://scottishcovidresponse.github.io/docs/data_pipeline/interface/), use `link_read` and `link_write` to read and write external objects (rather than the standard API `read_xxx` and `write_xxx` functions.)

```@docs
link_read
link_write
```

## Writing to the Data Registry

The process of registering objects such as data, code, and model runs, in the main Data Registry involves two steps; [local] registration, and then committing registered objects to the main online Registry.

### Registering objects

```@docs
write_array
```

WIP. TBA:
- estimate, table
- model
- model run? or is this done only via scripts?

### Raising issues

```@docs
raise_issue
```

## Other

```@docs
whats_my_file
registry_audit
```

## Index
```@index
Pages = ["fdp_manual.md"]
```
