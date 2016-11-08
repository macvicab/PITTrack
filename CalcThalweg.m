function thalweg = CalcThalweg(fname)

thalweg = ConvCSV2Struct(fname,1);

% interpolate thalweg to a finer grid
int = 0.1;

% calculate ldistance
nthaltot = length(thalweg.Easting);
thalweg.ldistance = zeros(1,nthaltot);

[~,rdist] = cart2pol(thalweg.Easting(2:end)-thalweg.Easting(1:end-1),thalweg.Northing(2:end)-thalweg.Northing(1:end-1));
thalweg.ldistance(2:end) = cumsum(rdist);

% increase resolution of thalweg data
thalweg.ldistmore = 0:int:thalweg.ldistance(end);

thalweg.Nmore = interp1(thalweg.ldistance,thalweg.Northing,thalweg.ldistmore);
thalweg.Emore = interp1(thalweg.ldistance,thalweg.Easting,thalweg.ldistmore);
thalweg.Zmore = interp1(thalweg.ldistance,thalweg.elevation,thalweg.ldistmore);

end