# Elastosynth

Open-source MATLAB/C++ package for generating realistic *in silico* radio-frequency (RF) data for quasi-static ultrasound elastography. Elastosynth chains three modules that can also be used independently:

1. **Procedural phantom generation** – random, clinically realistic heterogeneous Young's modulus maps (Monte-Carlo inclusion placement, super-pixel heterogeneity, optional PCA tumour shapes).
2. **Finite element (FE) modelling** – a lightweight C++ solver (Armadillo) for 2D plane-stress / plane-strain compression of arbitrarily heterogeneous stiffness images.
3. **RF data generation** – FIELD II simulation of pre- and post-compression RF frames, accelerated by a partial-domain (lateral windowing) scheme.

**Documentation:** https://elastosynth.notion.site/43961d8dc2ea4bd29e8fc607856493c5?v=524fa2ca411d4b84a56a2abead012f8d

**License:** LGPL-2.1 (see `LICENSE`). FIELD II is redistributed under its own terms; see `FIELD II Windows/users_guide.pdf`.

## Requirements

- MATLAB R2022b or newer (tested with R2024a) with the Image Processing, Signal Processing and Statistics and Machine Learning toolboxes. The Parallel Computing Toolbox is optional.
- Windows 10/11 (pre-compiled FEM interface in `FEM Interface Windows`) or Linux (`FEM Interface Linux`). macOS is expected to work from source but has not been validated.
- 8 GB RAM minimum, 16 GB recommended.

## Quick start

```matlab
root = ElastosynthSetup();          % adds every package folder to the path
TestReproducibility                 % seeded phantom generation self-test (~1 min)
TestFEMInterface                    % single FE simulation of a 221x201 phantom
TestProceduralPhantomGeneration     % phantoms -> FE -> RF frame pairs (writes to Outputs/)
```

All example scripts start with `ElastosynthSetup()`, so they can be run from any working directory.

## Reproducible generation (random seeds)

Every random draw in the pipeline is controlled through one master seed:

```matlab
seed = 42;
parameter_table = GeneratePhantomParameterTable(n_phantoms, [1 3], [5 1 10], [0 1], 0, 0, 0, 1, seed);
```

The table receives a `phantom_seed` column (`seed`, `seed+1`, ...). `GenerateProceduralPhantom`, `GenerateRFOneByOne` and `BatchPairGeneration` reset MATLAB's generator from that per-phantom seed at the start of each stage (see `SetElastosynthSeed.m`), so any single phantom of a dataset can be regenerated from its row of `ParameterTable.csv` alone. FIELD II is deterministic for a given scatterer set. Omitting the seed reproduces the previous, unseeded behaviour.

## Partial-domain acceleration

`GenerateRFLinearArray(phantom, transducer, imageopts, coeff)` only passes to FIELD II the scatterers within a lateral window of half-width `coeff × (lateral extent of the scatterer field)` centred on the current A-line. `GenerateFramePairLinear` takes `speed_factor = 1/coeff`, so `speed_factor = 100` keeps a ±1 % window (about 2 % of the scatterers per line) and `speed_factor = 1` simulates the full domain.

## Repository layout

| Folder / file | Content |
|---|---|
| `Elastosynth Src/` | MATLAB source: phantom generation, FE wrapper classes, RF generation, batch drivers |
| `FEM Src/` | C++ source of the finite element solver (CMake project) |
| `FEM Interface Windows/`, `FEM Interface Linux/` | Pre-compiled MATLAB C++ interface to the solver |
| `FIELD II Windows/`, `FIELD II Linux/` | FIELD II binaries and MATLAB wrappers |
| `Transducers/` | Transducer definitions (`Default_Transducer`, `L11-5V`, `L12-3V`) |
| `Models/` | Generative PCA model of clinical tumour shapes |
| `Test*.m`, `GeneratePhantomManually.m` | Example and test scripts |
| `MassMLDataGeneration.m`, `FiniteElementAnalysisBatch.m`, `FieldIIBatch.m` | Batch generation with Cooper's ligaments and clinical tumour masks |

## Citation

If you use Elastosynth, please cite:

> M. Caius, Z. Wang, A. Samani, "Elastosynth – An open-source software package for the generation of realistic in-silico RF data for ultrasound elastography", *Sensors* (under review).

Archived releases: see the GitHub *Releases* page; each tagged version is deposited on Zenodo with a DOI.
