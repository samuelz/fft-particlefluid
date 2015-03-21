N = 100;
L = 2*pi;

xlist = 1/N:L/N:L;
ylist = 1/N:L/N:L;

[x,y] = meshgrid(xlist,ylist);

z1 = 0.0;
z2 = 1;

% shifted fourier transforms (-N/2 to N/2-1)
fft2s = @(u) fftshift(fft2(u));
ifft2s = @(u) ifft2(ifftshift(u));
% intial shape: heaviside disc
u0 = z2*0.6*((x-3).^2+(y-3).^2 < 1);
v0 = z2*0.6*((x-3).^2+(y-3).^2 < 1);
% intial shape: gaussian
u0 = z2*0.6*exp(-(x-3).^2-(y-3).^2);
v0 = z2*0.6*exp(-(x-3).^2-(y-3).^2);

% initial shape: wave
linedist = abs(x-2);%/sqrt(2);
%u0 = exp(-linedist.^2);
%v0 = u0;
vel0 = zeros(N,N,2);
vel0(:,:,1) = u0;
vel0(:,:,2) = v0;
%u0 = y2*0.6*exp(-4*(x-3).^2);
%u0 = y2*0.6*(abs(sin(x)-0.5)<0.2);

quiver(x,y,u0,v0);
%axis([0 L 0 L 0 z2]);
%hold all;
%% 

c = fft2s(vel0);

klist = -N/2:1:N/2-1;
llist = -N/2:1:N/2-1;
[k,l] = meshgrid(klist,llist);
k = repmat(k,1,1,2);
l = repmat(l,1,1,2);

dt = 0.00025;

k2 = k.^2;
l2 = l.^2;
k2l2 = k2+l2;
nu = 0;
i = 1:N/100:N;

for t = 0:dt:400*dt
    % u_t = u_xx+u_yy
    %dcdt = -k2l2.*c;
    % u_t = -u*u_x - v*u_y + nu*(u_xx+u_yy)
    % v_t = -u*v_x - v*v_y + nu*(v_xx+v_yy)
    dcdt = -10j*(k+l).*c - nu*k2l2.*c;
    
    c = c + dt * dcdt;
    clf;
    vel = real(ifft2s(c));
    %quiver(x(i,i),y(i,i),,vel(i,i,2));
    vabs = sqrt(vel(i,i,1).^2 + vel(i,i,2).^2);
    surf(x(i,i),y(i,i),vabs);
    axis([0 L 0 L]);
    drawnow();
    %pause(0.3);
end
