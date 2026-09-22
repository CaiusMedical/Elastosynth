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

## Contributing

Contributions to Elastosynth are welcome. The preferred workflow is to **fork the repository, make and test your changes in your own fork, and then submit those changes back upstream through a pull request**.

Useful contributions include:

* Bug fixes and performance improvements.
* New phantom-generation methods, anatomical models, or material distributions.
* Improvements to the finite element solver or MATLAB/C++ interface.
* Additional FIELD II acquisition configurations, transducers, or RF-generation methods.
* Support for additional operating systems or MATLAB releases.
* Validation studies, benchmarks, and reproducibility tests.
* Documentation, examples, and usability improvements.

### Contribution workflow

1. **Fork the Elastosynth repository** to your own GitHub account.
2. **Clone your fork** locally.
3. Create a new branch for the work, for example:
   `feature/new-phantom-model` or `fix/fem-boundary-condition`.
4. Make your changes in that branch.
5. Run the relevant Elastosynth tests and confirm that the existing functionality still works.
6. Push the completed branch to your fork.
7. Open a **pull request from your fork back to the main Elastosynth repository**.
8. In the pull request, briefly explain:

   * what was changed;
   * why the change is useful;
   * how it was tested; and
   * whether it changes numerical results, generated datasets, or reproducibility.
9. Address any review comments, then update the pull request by pushing additional commits to the same branch.

Please do not maintain useful fixes or extensions only in a private or separate fork where they can reasonably be contributed back to the project. Where possible, improvements should be **upstreamed to the main Elastosynth repository** so that other researchers can use, test, and build on them.

For substantial changes, opening a GitHub issue before implementation is encouraged so that the proposed approach can be discussed before significant work is done.

### Reproducibility requirements

Changes affecting stochastic generation must preserve the existing reproducibility framework. Random behaviour should be derived from the Elastosynth seed mechanism rather than introducing independent uncontrolled random-number generators.

If a change modifies generated phantoms, FE results, RF data, or numerical behaviour, please document the expected difference and provide a small validation example where practical.

### Reporting issues

When reporting a bug, please include:

* Operating system.
* MATLAB version.
* Relevant MATLAB toolbox versions.
* Elastosynth release or Git commit.
* The script or function being run.
* The complete error message and stack trace.
* A minimal example or parameter set that reproduces the issue, where possible.

For reproducibility-related issues, please also include the relevant master seed or `phantom_seed` and the corresponding parameter-table row.

### Research contributions

If Elastosynth is extended as part of a research project, we strongly encourage researchers to upstream generally useful additions rather than maintaining them only as laboratory-specific modifications.

Examples include new tissue models, tumour models, FE formulations, transducer definitions, simulation settings, validation scripts, and performance improvements.

Contributors retain copyright to their contributions. By submitting code to the project, you agree that it may be distributed under the project's LGPL-2.1 license. Contributions involving FIELD II or other third-party components must also comply with the licensing terms of those dependencies.

