function [mld_values,sources_est] = number_sources_estimation(M, N, eigen_values)
    mld = zeros(M,1);
    eigen_values=abs(eigen_values);
    for d = 0:M-1
        eig_noise = eigen_values(d+1:M); % (M-d) smallest eigenvalues
        gm = prod(eig_noise)^(1/(M-d));  % Geometric mean
        am = mean(eig_noise);            % Arithmetic mean
        mld(d+1) = -N*(M-d)*log(gm/am ) + d*(2*M - d)*log(N)/2;
    end
    [~, sources_est] = min(mld);
    sources_est=sources_est-1;
    mld_values=mld;
end
