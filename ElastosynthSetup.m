function root = ElastosynthSetup()
%ELASTOSYNTHSETUP Add every Elastosynth folder to the MATLAB path.
%   root = ElastosynthSetup() adds the source folder, the compiled FEM
%   interface and the FIELD II binaries for the current platform, the
%   transducer definitions and the generative models to the path, and
%   returns the repository root folder.
%
%   Call this once at the top of every script instead of hard-coding
%   machine-specific paths.

    root = fileparts(mfilename('fullpath'));

    addpath(root);
    addpath(fullfile(root, 'Elastosynth Src'));
    addpath(fullfile(root, 'Transducers'));
    addpath(fullfile(root, 'Models'));

    if ispc
        addpath(fullfile(root, 'FEM Interface Windows'));
        addpath(fullfile(root, 'FIELD II Windows'));
    else
        addpath(fullfile(root, 'FEM Interface Linux'));
        addpath(fullfile(root, 'FIELD II Linux'));
    end

end
