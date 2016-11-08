function PlotThalweg(thalweg)

xi = ~isnan(thalweg.Easting)&~isnan(thalweg.Northing);
X = thalweg.Easting(xi);
Y = thalweg.Northing(xi);
Z = thalweg.elevation(xi);
L = thalweg.ldistance(xi);

markdist = 0:1000:6000;

xmark = interp1(L,X,markdist);
ymark = interp1(L,Y,markdist);

line(X,Y,'Color','k','LineWidth',1,'HandleVisibility','off');
line(xmark,ymark,'Color','green','Marker','+','LineStyle','none','MarkerSize',10,'HandleVisibility','off');

hold on

% XS = shaperead('SB_Transects.shp')
% nXStot = length(XS)
% hold on
% 
% for nXS = 1:nXStot
% line(XS(nXS).X,XS(nXS).Y,'Color','r','LineWidth',2)
% end
grid on

if isfield(thalweg,'reachbreak')
    X = thalweg.Emore(thalweg.reachbreak);
    Y = thalweg.Nmore(thalweg.reachbreak);
    hReach = line(X,Y,'Color','b','LineStyle','none','Marker','x');
    nrtot = length(thalweg.reachbreak);
    rchlist = cell(1,nrtot-1);
    for nr = 1:nrtot
        text(X(nr)+10,Y(nr)+10,num2str(nr),'Color','b');
        if nr~=nrtot
            rchlist(nr) = cellstr([num2str(nr),' - ',num2str(nr+1)]);
        end
    end
end
