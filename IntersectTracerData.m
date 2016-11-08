function gooP1 = IntersectTracerData(position1Data,position2Data,sizes,reaches)

%
np2tot = length(position2Data);
goos = zeros(length(position1Data.tagnum),np2tot);

% find data found in any of the position 2 surveys
for np2 = 1:np2tot
    goos(:,np2) = ismember(position1Data.tagnum,position2Data(np2).tagnum);
end
% find data that meets the size criteria
gooz = position1Data.db_mm>=sizes(1) & position1Data.db_mm<sizes(end);
% find data that meets the reach criteria
goor = position1Data.ldist>=reaches(1) & position1Data.ldist<reaches(end);


% intersection of all three criteria
gooP1 = any(goos,2) & gooz & goor;

% %% SurveyData
% 
% % intersection of all three criteria
% gooSD = ismember(position2Data.tagnum,position1Data.tagnum(gooPD));

end
