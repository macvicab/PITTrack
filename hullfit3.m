function k=hullfit3(x,y,p)

%HULLFIT    Fit a polygon hull to a given data set so no data point is on
%           the outside of the hull. Enhancement of CONVHULL.
%
%   K = HULLFIT3(X,Y,P)
%
% Inputs:   x,y vectors of the same size containing the coordinates of the
%               data set points
%           p   fraction of longest hull line length to split hull lines
%               to. Default is 0.5.
% Output:   k   vector of indizes into X and Y containing the hull polygon
%               points in clockwise order.
%
% HULLFIT enhances the functionality of CONVHULL. While CONVHULL gives you
% a hull polygon of minimal outline length, HULLFIT tries to minimize the 
% polygon area by allowing only line lengths of (p).
% this might provide the possibility to skip unwanted interpolation effects
% and only use the inner area.
%
%   programmed by Peter Wasmeier, Technical University of Munich
%   p.wasmeier@bv.tum.de
%   11-11-04
% 
%   hullfit3 modified by Bruce MacVicar, University of Waterloo
%   bmacvicar@uwaterloo.ca
%   24-06-15

%% control parameters
ploty = 0;

if nargin<3,p=10;end
if nargin<2,error('hullfit needs at least two input arguments!'),end
if ~any(size(x)==1),error('hullfit needs x and y inputs be vectors of the same size!'),end
if ~all(size(x)==size(y)),error('hullfit needs x and y inputs be vectors of the same size!'),end


% Create starting convex hull
k=convhull(x,y);

kin = k;
% Calculate the angles from starting point to the second and to the last one
w1=pi-atan2(y(k(2))-y(k(1)),x(k(2))-x(k(1)));
w2=pi-atan2(y(k(end-1))-y(k(1)),x(k(end-1))-x(k(1)));
% From triangulation it is clear, that only if w1>w2 we have
% counterclockwise orientation of the k-index. In this case, change it to
% clockwise indexing.
if w1>w2,k=flipud(k);end

% Calculate maximum distance between two index points from hull
[l,m,mi]=exdist(x(k),y(k));
% Initialize a counter for the added hull points in the following step
ku=0;

% Start a infinite loop to work on all hull lines which are too long
while l>p
    % Calculate the next point which fits on the hull.
    kn=npcw(x,y,k,m,m+1,p);
    % If no new point was successfully added, leave loop
    if ~isempty(kn)
        % Add the point between the starting point with index m and the
        % follow-on.
        k=[k(1:m);kn;k(m+1:end)];

        % Calculate the new longest line length l, its starting index m in the hull
        % vector k and the shortest hull line length mi
        [l,m,mi]=exdist(x(k),y(k));
        % Otherwise increase counter of added points by one.
        ku=ku+1;
    else
        disp('p is too small for the sparse data.  Set a larger value.');
        l = 0;
    end
end

% From definition of adding new points in function npcw, we might have
% added more points than necessary. Try, if we can leave some of them
% away.
% Create a starting index of hull points in k, which might possibly be
% left out. The ending index of that group of points is of course
% m+1+ku.
% Start a loop to leave points out
% for i=m+1:m+1+ku
%     % Look, if there is a point more far to the left hand side of the
%     % bearing from hull point i to hull point m+1+ku. If this is not
%     % the case, all points in between can be left out.
%     [kn,lp]=npcw(x,y,k,i,m+1+ku);
%     % If no point on the left is found, lp is equal to 0
%     if ~lp
%         % Delete all following hull points until m+1+ku and leave loop.
%         k(i+1:m+ku)=[];
%         break
%     end
% end
if ploty
    figure
    plot(x(kin),y(kin));
    hold on;
    plot(x(k),y(k),'g');
    plot(x,y,'r.');
end

end

% Helper functions

function [lmax,mi,lmin]=exdist(x,y)

s=sqrt(diff(x).^2+diff(y).^2);
mi=find(s==max(s), 1, 'first');
lmax=s(mi);
lmin=min(s);

end
function [kn,lp]=npcw(x,y,k,ks,ke,p)
% Calculate the next fitting point for the hull and return its index kn.
% Calculation prinziple is simple:
% Because we know, that hull definition is clockwise, the next candidate
% for a hull point is those having the smallest positive angle with the
% hull line to intersect.
% second condition: the distance to a candidate must be smaller than the
% length of the line to intersect.
% Using this algorithm, either a point close to the starting point or clse
% to the ending point of the hull line is found.
kn=[];
% calculate all angles to the points
%w=pi-atan2(y-y(k(ke)),x-x(k(ke)));
[w2,s]=cart2pol(y-y(k(ke)),x-x(k(ke)));
% Take the angle of the reference line (to be intersected)
wSE=w2(k(ks));
sSE=s(k(ks));
% Calculate the angle differences
dw=w2-wSE;
% find those points with distances less than the reference line
goo = find(s<sSE & s>0);
% if there are points to use
if ~isempty(goo)
    % find the one with the minimum angle
    [~,kni]= min(abs(dw(goo))); % 
    kn = goo(kni);
else
    kn = [];
end
% dw(k(ke))=NaN;
% dw(k(ks))=NaN;
% % Second condition: calculate the distances
% s=sqrt((x-x(k(ke))).^2+(y-y(k(ke))).^2);
% % Take the distance of reference line
% % Skip too long distances
% dw(s>sSE)=NaN;
% % Look if there are negative angles and if it is so, set the flag lp to 1
% if min(dw)>0,lp=0;else,lp=1;end
% % Find the index of the smallest angle
% if isnan(kn),kn=[];end

end