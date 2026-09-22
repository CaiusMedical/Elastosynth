%% TestReproducibility.m
% Checks that seeded phantom generation is reproducible:
%   1. the same master seed gives the same parameter table and phantoms,
%   2. any single phantom can be regenerated on its own from its row of the
%      parameter table (per-phantom seed), and
%   3. the scatterer field used for RF generation is reproducible too.
close all
clear all
clc
root = ElastosynthSetup();

seed = 42;
resolution = [128 128];
procedural_parameters = ProceduralParameters([30, 10], [1.5, 5, 3000], [1, 5, 1000], resolution, 10, 300);

%% 1. Same seed -> same table and phantoms
tableA = GeneratePhantomParameterTable(4, [1, 3], [5, 1, 10], [0, 1], 0, 0, 0, 1, seed);
tableB = GeneratePhantomParameterTable(4, [1, 3], [5, 1, 10], [0, 1], 0, 0, 0, 1, seed);
assert(isequal(tableA, tableB), 'parameter tables differ for the same seed');

[~, ~, metaA] = GenerateProceduralPhantom(tableA, procedural_parameters);
[~, ~, metaB] = GenerateProceduralPhantom(tableB, procedural_parameters);
for i = 1:height(tableA)
    assert(isequal(metaA(i).YM_hetero, metaB(i).YM_hetero), 'phantom %d differs for the same seed', i);
end
disp('1. same seed -> identical phantoms: OK')

%% 2. Regenerate a single phantom from its own table row
i = 3;
[~, ~, metaC] = GenerateProceduralPhantom(tableA(i, :), procedural_parameters);
assert(isequal(metaA(i).YM_hetero, metaC(1).YM_hetero), 'phantom %d could not be regenerated from its row', i);
disp('2. single phantom regenerated from its table row: OK')

%% 3. Scatterer field reproducibility (stage 2)
SetElastosynthSeed(tableA.phantom_seed(i), 2);
[p1, a1] = ImageToScatterers(ones(220, 200), 40/1000, 40/1000, 10/1000, 1000);
SetElastosynthSeed(tableA.phantom_seed(i), 2);
[p2, a2] = ImageToScatterers(ones(220, 200), 40/1000, 40/1000, 10/1000, 1000);
assert(isequal(p1, p2) && isequal(a1, a2), 'scatterer field differs for the same seed');
disp('3. scatterer field reproducible: OK')

%% 4. Different seeds -> different phantoms; unseeded table still works
tableD = GeneratePhantomParameterTable(4, [1, 3], [5, 1, 10], [0, 1], 0, 0, 0, 1, seed + 1);
[~, ~, metaD] = GenerateProceduralPhantom(tableD, procedural_parameters);
assert(~isequal(metaA(1).YM_hetero, metaD(1).YM_hetero), 'different seeds gave the same phantom');
tableE = GeneratePhantomParameterTable(2, [1, 3], [5, 1, 10], [0, 1], 0, 0, 0, 1);
assert(all(isnan(tableE.phantom_seed)), 'unseeded table should carry NaN seeds');
[~, ~, ~] = GenerateProceduralPhantom(tableE, procedural_parameters);
disp('4. different seeds differ, unseeded generation still works: OK')

disp('All reproducibility checks passed.')
