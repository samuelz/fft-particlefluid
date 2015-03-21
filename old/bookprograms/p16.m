% p16.m - Poisson eq. on [-1,1]x[-1,1] with u=0 on boundary

% Set up grids and tensor product Laplacian and solve for u:
  N = 24; [D,x] = cheb(N); y = x;
  [xx,yy] = meshgrid(x(2:N),y(2:N));
  xx = xx(:); yy = yy(:);       % stretch 2D grids to 1D vectors
  f = 10*sin(8*xx.*(yy-1));
  D2 = D^2; D2 = D2(2:N,2:N); I = eye(N-1);
  L = kron(I,D2) + kron(D2,I);                       % Laplacian 
  figure(1), clf, spy(L), drawnow
  tic, u = L\f; toc          % solve problem and watch the clock

% Reshape long 1D results onto 2D grid:
  uu = zeros(N+1,N+1); uu(2:N,2:N) = reshape(u,N-1,N-1);
  [xx,yy] = meshgrid(x,y);
  value = uu(N/4+1,N/4+1);

% Interpolate to finer grid and plot:
  Nm = 50;
  [xxx,yyy] = meshgrid(-Nm/2:Nm/2, -Nm/2:Nm/2);
  xxx = xxx*2/Nm; yyy = yyy*2/Nm;
  uuu = interp2(xx,yy,uu,xxx,yyy,'cubic');
  figure(2), clf, mesh(xxx,yyy,uuu), colormap(1e-6*[1 1 1]);
  xlabel x, ylabel y, zlabel u
  text(.4,-.3,-.3,sprintf('u(2^{-1/2},2^{-1/2}) = %14.11f',value))

  uuf = ifft2(ifftshift(padarray(fftshift(fft2(uu)),[Nm/2-N/2 Nm/2-N/2],0)));
  uuf = real(rot90(rot90(uuf)));
  uuf = uuf * max(max(uuu))/max(max(uuf));
  figure(3), clf, mesh(xxx,yyy,uuf), colormap(1e-6*[1 1 1]);
  xlabel x, ylabel y, zlabel u
  
  uulin = interp2(xx,yy,uu,xxx,yyy,'linear');
  uunea = interp2(xx,yy,uu,xxx,yyy,'nearest');
  uucub = interp2(xx,yy,uu,xxx,yyy,'cubic');
  uuspl = interp2(xx,yy,uu,xxx,yyy,'spline');
  
  