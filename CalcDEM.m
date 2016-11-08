function CalcDEM(DEMfname,thalweg)
% program to calculate DEM from sparse river data and a thalweg line
% optional lines include bank top and toe
% roughly based on MasterTopo v1p2

%% control block
%ppoint = 0; %controls activation of points plotting
prelative = 1; % controls relative (= 1) vs absolute (= 0) elevation 
plotlocal = 0;
%pcont = 1; %controls topography plot
%perode = 0; daterode = '110504'; %controls erosion plot  'dateerode' is the file with which erosion is to be calculated
%pwithGPS = 0; %controls the insertion of the data into the larger GPS file (041203)

%% user parameters
fint = 20; % 2; controls grid spacing
vres = 0.25; % controls vertical resolution of map
vert = [0 4]; % controls vertical extent of topo lines
llimit = 50; % length of outline line for hullfit program
%cmap = gray;

%% directories
% get sparse data set(s)
topoData = ConvCSV2Struct(DEMfname,1);

% determine outline
% use homemade function lastpoint to delineate area
topopoly = hullfit3(topoData.UTM_X,topoData.UTM_Y,llimit);


if prelative
    % calculate thalweg and radial distances\
    [ldist,~] = CalcLdistance(topoData.UTM_X,topoData.UTM_Y,thalweg.Emore,thalweg.Nmore,thalweg.ldistmore);

    % find thalweg in polygonremove overall slope based on thalweg at top and bottom of section
    INthalweg = find(inpolygon(thalweg.Easting,thalweg.Northing,topoData.UTM_X(topopoly),topoData.UTM_Y(topopoly)));
    % thalweg slope
    %[maxthal,maxi] = max(thalweg.ldistance(INthalweg)) ;
    %[minthal,mini] = min(thalweg.ldistance(INthalweg)) ;
    %hardcode for Wilket restored reach
    S = (117-112)/(1600-1155);
    % find minimum elevation
    [minel,mineli]=min(thalweg.elevation(INthalweg));
    RelativeElevation = topoData.Elevation-(minel+S*(ldist-ldist(mineli)));
    topo = [topoData.Pt topoData.UTM_X topoData.UTM_Y RelativeElevation]; 
else
    topo = [topoData.Pt topoData.UTM_X topoData.UTM_Y topoData.Elevation];
end
    
%% set up grid
north = [floor(min(topoData.UTM_Y)/fint)*fint ceil(max(topoData.UTM_Y)/fint)*fint]; % [926 946]; %controls extent of grid
east = [floor(min(topoData.UTM_X)/fint)*fint ceil(max(topoData.UTM_X)/fint)*fint];%[970 1010]; %[992 1010]; % controls horizontal extent of grid
if plotlocal
    CreateMap(north,east)
    grid on
end


plotcont(topo,fint,vres,north,east,vert,topopoly);
% 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function makeLegend(pcont,ptit,col)
 
pctot = length(pcont);
 
a = get(gca,'Position');
xi = a(1)+a(3)+0.7;
axel = axes('Units','centimeters','Position',[16 3 0.5 4]);
set(axel,'NextPlot','add');
set(axel,'XLim',[0.5 1.5]);
set(axel,'YLim',[0.5 pctot-0.5]);
set(axel,'YAxisLocation','right');
set(axel,'YTick',[0.5:2:pctot]);
set(axel,'YTickLabel',pcont(1:2:pctot));
 
set(axel,'XTick',[]);
 
image([1:pctot-1]','CDataMapping','direct');
colormap(col)
text(0,(pctot-1)/2, ptit,'Rotation',90,'VerticalAlignment','middle');%HorizontalAlignment','center')
end

function plotcont(topo,fint,vres,north,east,vert,topopoly,col)
% this function plots the topography of the specified plot and the
% difference compared to the previous plot

nptot = length(topo);

[xmin,ymin,xmax,ymax,xmem,ymem] = rangefind(topo(:,2:4),fint,fint,north,east);
    
% interpolate from point measurements to complete matrix 
% use linspace to generate points (could also use colon operator)
xlin = linspace(xmin,xmax,(xmax-xmin)/(vres));
ylin = linspace(ymin,ymax,(ymax-ymin)/(vres));

% use meshgrid to generate two matrices with number of columns of xlin and
% number of rows of ylin
[X,Y] = meshgrid(xlin,ylin);
[r,c] = size(X);

Z = zeros(r,c);

lim = 2.5; % radial distance limit for nearest point
amax = 150;

IN = find(inpolygon(X,Y,topo(topopoly,2),topo(topopoly,3)));
Z(IN) = griddata(topo(:,2),topo(:,3),topo(:,4),X(IN),Y(IN),'linear');
zzero = Z == 0;
Z(zzero)=NaN;

if ~isempty(vert)
    zmin =  vert(1);
    zmax = vert(2);%
else
    zmin = fix((min(topo(:,4)))/vres)*vres; %
    zmax = (fix((max(topo(:,4)))/vres)+1)*vres; %
end
pcont = [zmin:vres:zmax];

nctot = length(pcont)-1;
cmap = jet; % jet coloring, could also be used with bone, autumn, etc.
njettot = length(cmap);
ngooc = floor(1:njettot/nctot:njettot);
col = cmap(ngooc,:);


% create filled contour map 
[beau,belle] = contourf(X,Y,Z,pcont);
colormap(col);
% remove black lines between colours (makes it harder to see tags)
set(belle,'LineColor','none')

ptit = 'Detrended Elevation (m)';
makeLegend(pcont,ptit,col);


end

function [minx,miny,maxx,maxy,xmem,ymem] = rangefind(data,xint,yint,north,east)
% fuction called from lab3 to calculate ranges
if isempty(north)
    miny = fix((min(data(:,2)))/yint)*yint;
    maxy = (fix((max(data(:,2)))/yint)+1)*yint;
else
    miny = north(1);
    maxy = north(2);
end
if isempty(east);
    minx = fix((min(data(:,1)))/xint)*xint;
    maxx = (fix((max(data(:,1)))/xint)+1)*xint;
else
    minx = east(1);
    maxx = east(2);
end
xmem = minx:xint:maxx;
ymem = miny:yint:maxy;
end

%% CreateMap
function CreateMap(north,east)

xdiff = diff(east);
ydiff = diff(north);
ymultscale=ydiff/xdiff;

% multiple axes
plt1 = figure
titlespace = .5; % distance above plots
figxi = 1; % corner position of first figure
figyi = 1; 
nxtot = 1; % number of axes in x direction
nytot = 1; % number of axes in y direction
axescale = 20; % multiplier for axes
axex = axescale;
axey = axescale*ymultscale;
axespace = .4; % space between axes
axexi = 1.1; % corner position of 
axeyi = 1.3;
figx = axexi+nxtot*(axex+axespace)+1.5*titlespace;
figy = axeyi+nytot*(axey+axespace)+titlespace;
set(plt1,'Units','centimeters','Position',[figxi figyi figx figy],'PaperPositionMode','auto');
% axes
%set(axe1,'XTick',)
% multiple axes
for nx = 1:nxtot
    axexin = axexi+(nx-1)*(axex+axespace);
    for ny = 1:nytot 
        axeyin = axeyi+(ny-1)*(axey+axespace);
        axe(nx,ny) = axes('Units','centimeters','Position',[axexin axeyin axex axey]);
        set(axe(nx,ny),'YLim',north);
        set(axe(nx,ny),'NextPlot','add');
        set(axe(nx,ny),'XLim',east)

    end
end
end


function [ldist,hdist] = CalcLdistance(E,N,Ethalweg,Nthalweg,Ldistance)

nttot = length(E);

ldist = zeros(nttot,1);
hdist = zeros(nttot,1);

for nt = 1:nttot
    % calculate l and h distances based on the thalweg distance
    [~,hdall] = cart2pol(E(nt)-Ethalweg,N(nt)-Nthalweg);
    % find the thalweg position closest to the cartesian coordinate
    [hdist(nt),thalnum] = min(hdall);
    % save the ldistance
    ldist(nt) = Ldistance(thalnum);
end
end