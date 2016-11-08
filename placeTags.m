function placedData = placeTags(placementdir,placementfile,labData,thalweg)

% get taggedCSV 
placementfname = [placementdir,placementfile];
placementRaw = ConvCSV2Struct(placementfname,1);

% extract date from filename
numberstr = regexp(placementfile,'(\d+)','tokens');
placedData.date = datenum(numberstr{1},'yyyymmdd');

placedData.placementfname = placementfname;
%placedData.labfname = labData.labfname;

%% find placed tags in the lab data and create indexes
[Lia,Locb] = ismember(labData.tagnum,placementRaw.tagnum);
foundIdx = find(Lia);
[~,sortIdx] = sort(Locb(foundIdx)); 

% check for errors
nraw = length(placementRaw.tagnum);
nconfirm = length(sortIdx);
if nraw ~= nconfirm
    disp('error in survey data');
    % check for double tags
    tagsort = sort(placementRaw.tagnum);
    doublediff = diff(tagsort);
    if any(doublediff==0)
        ndd = find(doublediff==0);
        doubletag = tagsort(ndd);
        for nd = 1:length(doubletag)
            disp(['double tagnum detected for tag ',num2str(doubletag(nd))]);
        end
    end
    % check for wrong numbers
    [a,b] = ismember(placementRaw.tagnum,labData.tagnum);
    wrongtag = placementRaw.tagnum(~a);
    for nw = 1:length(wrongtag)
        disp(['tagnum ',num2str(wrongtag(nw)),' is not found in the tracers characteristics file.']);
    end
end
%% transfer labData data to placedData
labDatanames = fieldnames(labData);
% initialize loop to list substructure fieldnames (e.g. Vel.x)
nntot = length(labDatanames);
for nn = 1:nntot
    eval(['placedData.',labDatanames{nn},' = labData.',labDatanames{nn},'(foundIdx);']);
end

%% transfer placementRaw data to placedData
placementRawnames = fieldnames(placementRaw);
% initialize loop to list substructure fieldnames (e.g. Vel.x)
nn2tot = length(placementRawnames);
eval(['placedData.nttot = length(placementRaw.',placementRawnames{1},');']);

for nn2 = 1:nn2tot
    chk = ~strcmp(placementRawnames{nn2},'tagnum');
    chk2 = ~strcmp(placementRawnames{nn2},'precision');
    
    if chk && chk2
        eval(['placedData.',placementRawnames{nn2},' = zeros(placedData.nttot,1);']);
        eval(['placedData.',placementRawnames{nn2},'(sortIdx) = placementRaw.',placementRawnames{nn2},''';']);
    end
end

% create zero matrices for the positions
[ldist,hdist] = CalcLdistance(placedData.Easting,placedData.Northing,thalweg.Emore,thalweg.Nmore,thalweg.ldistmore);

placedData.ldist = ldist;
placedData.hdist = hdist;
placedData.lrange = [min(ldist) max(ldist)];

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