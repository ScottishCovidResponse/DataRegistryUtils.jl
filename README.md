# DataRegistryUtils.jl
**The [FAIR Data Pipeline][dp_docs] in Julia**

![Documentation](https://github.com/FAIRDataPipeline/DataRegistryUtils.jl/workflows/Documentation/badge.svg)
![Package tests](https://github.com/FAIRDataPipeline/DataRegistryUtils.jl/workflows/Tests/badge.svg)

## Features
- Conveniently download Data Products from the [SCRC Data Registry](https://data.scrc.uk/).
- File hash-based version checking: new data is downloaded only when necessary.
- A SQLite layer for convenient pre-processing (typically aggregation, and the joining of disparate datasets based on common identifiers.)
- Easily register model code or realisations (i.e. 'runs') with a single line of code.

## Installation

The [current version of the] package is not yet registered and must be added via the package manager Pkg. From the REPL type `]` to enter Pkg mode and run:

```
pkg> add https://github.com/FAIRDataPipeline/DataRegistryUtils.jl
```

## Usage

See the [package documentation][docs] for instructions and examples.

[docs]: https://fairdatapipeline.github.io/DataRegistryUtils.jl/stable/

[dp_docs]: https://fairdatapipeline.github.io/docs/introduction/
