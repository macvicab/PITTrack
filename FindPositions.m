function foundData = FindPositions(datenum,tracerData,labData)
% determine found missing reemerged and lost tags and infer positions
% note: tracerData should be sorted by date for this to work

Data = tracerData(datenum);
nttot = length(labData.tagnum);
ndtot = length(tracerData);

removed = zeros(nttot,1); % removed = 1 after the date when the previously placed tracer was removed from the river

found = zeros(nttot,ndtot); 
ldist = zeros(nttot,ndtot)/0; % storage for centerline distance;

missing = zeros(nttot,1); % missing = 1 if the tracer was not found but was found at a later date
%lost = zeros(nttot,1); % lost = 1 if the tracer was not found on this date or any date from this point

inferred = zeros(nttot,1); % inferred = 1 if the tracer was missing and its position could be inferred based on pre and post surveys that showed it had not moved
indeterminite = zeros(nttot,1); % indeterminite = 1 if the tracer was missing and its position could not be confirmed because it had moved between pre and post surveys in which it was found

ldistlast = zeros(nttot,1); % ldistlast gives the last know position of missing and indeterminate particles
Eastingall = zeros(nttot,ndtot)/0; % storage for centerline distance;
Northingall = zeros(nttot,ndtot)/0; % storage for centerline distance;
elevationall = zeros(nttot,ndtot)/0; % storage for centerline distance;

%easy ones
placed = labData.placeddate ~= 0 & Data.date>=labData.placeddate; % placed = 1 after the date when the tracer was first placed in the river
in = placed &~removed; % in = 1 if the tracer was in the river on the survey date
out = ~in; % out = 1 if the tracer was not in the river on the survey date

% determine particles that were found on the survey dates
% found = 1 if the tracer was detected and located on the survey date
for nd = 1:ndtot
    [found(:,nd),idx] = ismember(labData.tagnum,tracerData(nd).tagnum);
    fidx = find(idx);
    ldist(fidx,nd) = tracerData(nd).ldist;
    Eastingall(fidx,nd) = tracerData(nd).Easting;
    Northingall(fidx,nd) = tracerData(nd).Northing;
    elevationall(fidx,nd) = tracerData(nd).elevation;
end

Eastinglast = Eastingall(:,datenum);
Northinglast = Northingall(:,datenum);
elevationlast = elevationall(:,datenum);

% classify lost and missing particles
if datenum<ndtot
    lost = in & ~found(:,datenum) & ~any(found(:,datenum+1:end),2);
    missing = in & ~found(:,datenum) & any(found(:,datenum+1:end),2);
else
    lost = in & ~found(:,datenum);
end

% infer positions for missing particles
if any(missing)
    missingmem = find(missing);
    nmtot = length(missingmem);
    for nm = 1:nmtot
        nmi = missingmem(nm);
        % find previous positions of missing particles
        previouspos = find(found(nmi,1:datenum-1),1,'last');
        % find post positions of missing particles
        postpos = datenum+find(found(nmi,datenum+1:end),1,'first');
        % calculate difference
        ldistlast(nmi) = ldist(nmi,previouspos);
        ldistfuture = ldist(nmi,postpos);
        posdiff =  ldistlast(nmi)- ldistfuture;
        % infer positions of particles that had not moved
        if posdiff<1
            inferred(nmi) = 1;
            % save ldist to the Data structure
            ldist(nmi,datenum) = (ldistlast(nmi) + ldistfuture)/2;
            ldistlast(nmi) = 0; % clear last known position to prevent confusion
        else
            % indeterminate position
            indeterminite(nmi) = 1;
        end
        % save all last known positions
        Eastinglast(nmi) = Eastingall(nmi,previouspos);
        Northinglast(nmi) = Northingall(nmi,previouspos);
        elevationlast(nmi) = elevationall(nmi,previouspos);
        
    end

% 
end
% record last positions for lost particles
if any(lost)
    lostmem = find(lost);
    nltot = length(lostmem);
    for nl = 1:nltot
        nli = lostmem(nl);
        % find previous positions of lost particles
        previouspos = find(found(nli,1:datenum-1),1,'last');
        if ~isempty(previouspos)
            % save all last known positions
            ldistlast(nli) = ldist(nli,previouspos);
            Eastinglast(nli) = Eastingall(nli,previouspos);
            Northinglast(nli) = Northingall(nli,previouspos);
            elevationlast(nli) = elevationall(nli,previouspos);
        else
            
            disp(['tag ',num2str(Data.tagnum(nli)),' is lost but has no previous position data']);
        end
    end

% 
end

foundData.tagnum = labData.tagnum;
foundData.db_mm = labData.db_mm;
foundData.ldist = ldist(:,datenum);
foundData.ldistlast = ldistlast;
foundData.Eastinglast = Eastinglast;
foundData.Northinglast = Northinglast;
foundData.elevationlast = elevationlast;
foundData.placed = placed;
foundData.removed = removed;
foundData.in = in;
foundData.out = out;
foundData.found = found(:,datenum);
foundData.missing = missing;
foundData.lost = lost;
foundData.inferred = inferred;
foundData.indeterminite = indeterminite;
foundData.tracerData = Data;
end
