function [] = ConfigureFEM()
%LOADELASTOSYNTHFEM This function configures the FEM library from Elastosynth

config_obj = clibConfiguration("FEM_Interface", ExecutionMode="outofprocess");

if (config_obj.Loaded)
    "Reloading";
    config_obj.unload;
end

config_obj.ExecutionMode = "outofprocess";
config_obj;

end

