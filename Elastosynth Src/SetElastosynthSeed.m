function SetElastosynthSeed(seed, stage)
%SETELASTOSYNTHSEED Seed MATLAB's random number generator for one pipeline stage.
%   SetElastosynthSeed(seed, stage) resets the global generator (Mersenne
%   Twister) to a state derived from the phantom seed and the pipeline
%   stage, so that every stage of a phantom is reproducible on its own:
%
%       stage 0 : parameter table generation (GeneratePhantomParameterTable)
%       stage 1 : phantom geometry and heterogeneity (GenerateProceduralPhantom)
%       stage 2 : scatterer field and out-of-plane motion (RF generation)
%
%   FIELD II itself is deterministic for a given scatterer set, so seeding
%   the MATLAB generator is sufficient to reproduce a complete RF pair.
%
%   A NaN or empty seed leaves the generator untouched (legacy behaviour).

    if nargin < 2, stage = 0; end
    if isempty(seed) || any(isnan(seed)), return; end

    seed = double(seed(1));
    state = mod(seed*1000003 + stage*7919, 2^32 - 1);
    rng(state, 'twister');

end
