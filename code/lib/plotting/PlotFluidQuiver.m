function PlotFluidQuiver(S,P,Plt)

    quiver3(Plt.cross1,Plt.cross2,Plt.cross3,...
        squeeze(S.u(S.N/2,Plt.I,Plt.I)),...
        squeeze(S.v(S.N/2,Plt.I,Plt.I)),...
        squeeze(S.w(S.N/2,Plt.I,Plt.I)),'r');
    
end
