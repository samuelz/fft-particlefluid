%% PRELIMINARIES
% constants
N = 16; dt = 1;
M = 100; % # of particles
tmax = dt*1000;
L = 2*pi;
nu = 0.4;

% space vectors
x = (0:N-1)*L/N;
[x1,x2,x3] = ndgrid(x,x,x);

% k-space vectors
k = -N /2:N/2-1;
[k1,k2,k3] = ndgrid(k,k,k);
ksq = k1.^2+k2.^2+k3.^2;
ksqinv = 1./ksq;
ksqinvsq = 1./(ksq.*ksq);
ksqinv(N/2+1,N/2+1,N/2+1) = 0;
ksqinvsq(N/2+1,N/2+1,N/2+1) = 0;

C1 = ksqinv / nu;
C2 = ksqinvsq / nu;

% particle positions
particlex1 = L*rand(1,M);
particlex2 = L*rand(1,M);
particlex3 = L*rand(1,M);
particleu = zeros(1,M);
particlev = zeros(1,M);
particlew = zeros(1,M);

%% FUNTIONS, EQUATION PROPERTIES

% gravity force on point particles
g = 9.82;
mrel = 0.1;
frel = mrel * g;
fgx = frel * 0;
fgy = frel * 0;
fgz = frel * -1;
% delta function half-width
epsilon = L/N; % = h

%% DO (...WHILE)

hdeltasum = 0;

for i = 1:M
    hdelta1 = max(1-abs(x1-particlex1(i))/epsilon,0);
    hdelta2 = max(1-abs(x2-particlex2(i))/epsilon,0);
    hdelta3 = max(1-abs(x3-particlex3(i))/epsilon,0);
    hdelta = hdelta1.*hdelta2.*hdelta3;
    hdeltasum = hdeltasum + hdelta;

end

fx = fgx * hdeltasum;
fy = fgy * hdeltasum;
fz = fgz * hdeltasum;

% calculate stokes flow from the particle force

fhx = fftns(fx);
fhy = fftns(fy);
fhz = fftns(fz);

kdotfh = (k1.*fhx + k2.*fhy + k3.*fhz).*C2;

u = ifftns(fhx.*C1 - k1.*kdotfh);
v = ifftns(fhy.*C1 - k2.*kdotfh);
w = ifftns(fhz.*C1 - k3.*kdotfh);

%% SIMULATION TIME STEPPING
% timestep constants
nmax = round(tmax/dt); t = 0;
% plot specs
plotnum = 100; nplt = nmax/plotnum;
nlines = 8;
I = 1:N/nlines:N;

figure(1);

% streamlines
[sx,sy] = ndgrid(x(I),x(I));
sz = L*ones(nlines,nlines);
% quiver cross section
[cross1,cross3] = ndgrid(x(I),x(I));
cross2 = 0.5*L*ones(nlines,nlines);

% timing variables
t_interpol = 0;
t_fft = 0;
t_timestep = 0;
t_plot = 0;

GridIntp = griddedInterpolant(x1,x2,x3,u);

% timestep!
for n = 1:nmax
    t = t + dt;
    
    % calculate forcing function from particles
    hdeltasum = 0;
    tic;
    for i = 1:M
        hdelta1 = max(1-abs(x1-particlex1(i))/epsilon,0);
        hdelta2 = max(1-abs(x2-particlex2(i))/epsilon,0);
        hdelta3 = max(1-abs(x3-particlex3(i))/epsilon,0);
        hdelta = hdelta1.*hdelta2.*hdelta3;
        hdeltasum = hdeltasum + hdelta;
        
        % calculate flow velocity at particle positions

        %particleu(i) = sum(sum(sum(hdelta .* real(u))));
        %particlev(i) = sum(sum(sum(hdelta .* real(v))));
        %particlew(i) = sum(sum(sum(hdelta .* real(w))));    
        
    end
    
    GridIntp.Values = real(u);
    particleu = GridIntp(particlex1,particlex2,particlex3);
    GridIntp.Values = real(v);
    particlev = GridIntp(particlex1,particlex2,particlex3);
    GridIntp.Values = real(w);
    particlew = GridIntp(particlex1,particlex2,particlex3);
    
    fx = fgx * hdeltasum;
    fy = fgy * hdeltasum;
    fz = fgz * hdeltasum;
   
    t_interpol = t_interpol + toc;
    
    % calculate stokes flow from the particle force
    tic;
    fhx = fftns(fx);
    fhy = fftns(fy);
    fhz = fftns(fz);
    
    kdotfh = (k1.*fhx + k2.*fhy + k3.*fhz).*C2;
    
    u = ifftns(fhx.*C1 - k1.*kdotfh);
    v = ifftns(fhy.*C1 - k2.*kdotfh);
    w = ifftns(fhz.*C1 - k3.*kdotfh);
    t_fft = t_fft + toc;
    tic;
    % timestep particles
    particlex1 = particlex1 + dt * particleu;
    particlex1 = particlex1 + L*(particlex1<0) - L*(particlex1>L);
    particlex2 = particlex2 + dt * particlev;
    particlex2 = particlex2 + L*(particlex2<0) - L*(particlex2>L);
    particlex3 = particlex3 + dt * particlew;
    particlex3 = particlex3 + L*(particlex3<0) - L*(particlex3>L);
    t_timestep = t_timestep + toc;
    % plot
    if mod(n,nplt) == 0
        
        clf;
        % STREAMLINES
        %streamline(stream3(x1,x2,x3,u,v,w,sx,sy,sz,[0.1]));
        
        %view(-25,50);
        view(30,40);
        tic;
        plot3(particlex1,particlex2,particlex3,'k.');
        hold on;
        %quiver3(particlex1,particlex2,particlex3,particleu,particlev,particlew);
        %plot3(cross1,cross2,cross3,'r*');
        
        quiver3(cross1,cross2,cross3,...
        squeeze(u(I,N/2,I)),...
        squeeze(v(I,N/2,I)),...
        squeeze(w(I,N/2,I)),'r');
        t_plot = t_plot + toc;
        axis([0 L 0 L 0 L]);
        %
        % might have to pause if:
        %UIJ_AreThereWindowShowsPending - timeout waiting for window to show up
        drawnow;
        
    end
end

%% REPORT

t_interpol/n
t_fft/n
t_timestep/n
t_plot*nplt/n