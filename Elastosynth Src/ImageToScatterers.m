function [positions, amplitudes] = ImageToScatterers(I, D, L, Z, n_scatterers)

    
    positions = rand(n_scatterers, 3);
    positions(:,1) = L*positions(:,1) - L/2;
    positions(:,2) = Z*positions(:,2) - Z/2;
    positions(:,3) = D*positions(:,3) + 30/1000;

    [X,Y] = meshgrid(linspace(-L/2,L/2,size(I,2)), linspace(30/1000, D+30/1000, size(I,1)));

    %amplitudes = griddata(X,Y,I, positions(:,1), positions(:,3)) + 0.5*max(I(:))*randn(n_scatterers,1);
    %amplitudes = amplitudes ./ max(amplitudes(:));
    amplitudes = randn(n_scatterers,1);

end