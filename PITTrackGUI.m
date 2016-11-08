function PITTrackGUI
% GUI input, visualization, and analysis of RFID (PIT) tag tracers in rivers 

%% Create figure
% create basic figure
%plt = PITTrackFig;

% add buttons
[plt,B] = makePITTrackButtons;


% % initialize buttons
% set(B.selfile,'String',{GUIControl.miftttdir.name});
% set(B.Select,'Visible','on');
% set(B.replace,'Enable','off');
% set(B.Actions,'Visible','off');
% set(B.Filter,'Visible','off');
% set(B.Y.panel,'Visible','off');
% for nx = 1:plt.nxtot
%     set(B.X(nx).panel,'Visible','off');
% end
% 
% % if files have been preselected (for example for duplicates)
% if ~isempty(selmem)
%     set(B.selfile,'Value',selmem);
% end
% 
%% set callback functions for the different uicontrol buttons
% change active panel
npantot = length(B.panel);
for npan = 1:npantot
    set(B.panelbutton(npan),'Callback',{@hpanCallback,npantot,npan});
end
% Site Properties
set(B.seldefdir,'Callback',@hseldefdirCallback)
set(B.sitename,'Callback',@hsitenameCallback)
set(B.selthalwegfile,'Callback',@hselthalwegfileCallback)
set(B.selbackground,'Callback',@hselbackgroundCallback)
set(B.SiteReachesAdd,'Callback',@hSiteReachesAddCallback)
set(B.SiteReachesReset,'Callback',@hSiteReachesResetCallback)
set(B.saveC,'Callback',@hsaveCCallback)

% Add Tracers
set(B.seladdtags,'Callback',@hseladdtagsCallback)
set(B.seladdtagsmethod,'Callback',@hseladdtagsmethodCallback)
set(B.selplacementfile,'Callback',@hselplacementfileCallback)
set(B.sellabfile,'Callback',@hsellabfileCallback)
set(B.goadd,'Callback',@hgoaddCallback)
set(B.resetplacementdates,'Callback',@hresetplacementdatesCallback)

set(B.selremtags,'Callback',@hselremtagsCallback)
set(B.selremtagsmethod,'Callback',@hselremtagsmethodCallback)
set(B.selcsvremovalfile,'Callback',@hselcsvremovalfileCallback)
set(B.goremove,'Callback',@hgoremoveCallback)

set(B.C.placementdates,'Callback',@hplacementdatesCallback)
set(B.selplacementseemethod,'Callback',@hselplacementseemethodCallback)
set(B.goseeplacement,'Callback',@hgoseeplacementCallback)

% Add Surveys
set(B.seladdsurvey,'Callback',@hseladdsurveyCallback)
set(B.seladdsurveymethod,'Callback',@hseladdsurveymethodCallback)
set(B.selsurveyfile,'Callback',@hselsurveyfileCallback)
set(B.surveydate,'Callback',@hsurveydateCallback)
set(B.goaddsurvey,'Callback',@hgoaddsurveyCallback)

set(B.C.surveydates,'Callback',@hsurveydatesCallback)
set(B.selsurveyseemethod,'Callback',@hselsurveyseemethodCallback)
set(B.goseesurvey,'Callback',@hgoseesurveyCallback)

%set(B.selplacementadd,'Callback',@hselplacementaddCallback)
% Visualize Results
set(B.initializeViz,'Callback',@hinitializeVizCallback)
set(B.VizPlacementClear,'Callback',@hVizPlacementClearCallback)
set(B.VizSurveyClear,'Callback',@hVizSurveyClearCallback)
set(B.Vizselsizeall,'Callback',@hVizselsizeallCallback)
set(B.Vizselreachall,'Callback',@hVizselreachallCallback)
set(B.VizDEM,'Callback',@hVizDEMCallback)
set(B.VizShow,'Callback',@hVizShowCallback)

sizecat = 2.^[3:1:9];
nsztot = length(sizecat);
D50 = 38; % From survey May 2015 in upstream control reach
D84 = 100;
% Analyze Results
set(B.AnaAddData,'Callback',@hAnaAddDataCallback)
set(B.AnaGoAdd,'Callback',@hAnaGoAddCallback)
set(B.AnaRemData,'Callback',@hAnaRemDataCallback)
set(B.AnaGoRem,'Callback',@hAnaGoRemCallback)
set(B.AnaWaveall,'Callback',@hAnaWaveallCallback)

npanftot = length(B.panfig);
for npanf = 1:npanftot
    set(B.panfigbutton(npanf),'Callback',{@hpanfCallback,npanftot,npanf});
end


%% Callbacks
    % executes when a panel activation button is pushed
    function hpanCallback(~, ~, npantot, npan)
        for npani = 1:npantot
            if npani == npan
                set(B.panel(npani),'Visible','on');
            else
                set(B.panel(npani),'Visible','off');
            end
        end
    end
%% Site Properties Callbacks
    function hseldefdirCallback(~, ~, ~)
        defdir = uigetdir('E:\Research\Field','Get control text file');
        set(B.defdir,'String',defdir);
    end
    function hsitenameCallback(~, ~, ~)
        defdir = get(B.defdir,'String');
        sitename = get(B.sitename,'String');

        odir = [defdir,filesep,sitename,filesep,'PITTrack'];
        ofile = [odir,filesep,sitename,'PITTrack.mat'];
        % check for clean directory
        chk1 = dir(odir);
        % if clean directory does not exist, make it
        if isempty(chk1)
            mkdir(odir);

        end
        chk2 = dir(ofile);
        % if the *.mat file has been created
        if ~isempty(chk2)
            S = load(ofile);
            if isfield(S,'C')
                B.C = subSetValues(B.C,S.C);
            end

            Snames = fieldnames(S);
            nstot = length(Snames);
            for ns = 1:nstot
                if ~strcmp(Snames(ns),'C')
                    eval(['setappdata(plt.id,''',Snames{ns},''',S.',Snames{ns},');']);
                end
            end
            
            thalweg = getappdata(plt.id,'thalweg');

            set(plt.id,'CurrentAxes',B.mainplanaxes);
            PlotThalweg(thalweg);
            set(B.SiteReachesAdd,'Enable','on')

            placementdates = get(B.C.placementdates,'String');
            if ~isempty(placementdates)
                set(B.resetplacementdates,'Enable','on')
            end
        end
        setappdata(plt.id,'ofile',ofile)

    end
    function hselthalwegfileCallback(~, ~, ~)
        defdir = get(B.defdir,'String');
        [thalwegfile,thalwegdir] = uigetfile('*.csv','Select the thalweg *.csv file',defdir);
        set(B.C.thalwegfile,'String',thalwegfile);
        set(B.C.thalwegfile,'UserData',thalwegdir);

        thalwegfname = [thalwegdir,thalwegfile];
        thalweg = CalcThalweg(thalwegfname);
        
        set(plt.id,'CurrentAxes',B.mainplanaxes)
        PlotThalweg(thalweg);
        
        setappdata(plt.id,'thalweg',thalweg)
        set(B.SiteReachesAdd,'Enable','on')

    end
    function hsellabfileCallback(~, ~, ~)
        defdir = get(B.defdir,'String');
        [labfile,labdir] = uigetfile('*.csv','Select the tracer laboratory *.csv file',defdir);
        set(B.C.labfile,'String',labfile);
        set(B.C.labfile,'UserData',labdir);
        % load tagsize file with 6 columns (tagnum,da_mm,db_mm,dc_mm,mass,site,wavenum)
        labData = ConvCSV2Struct([labdir,labfile],1);
        % 
        nlabtot = length(labData.tagnum);
        labData.placeddate = zeros(nlabtot,1);
        
        setappdata(plt.id,'labData',labData)

    end
    function hselbackgroundCallback(~, ~, ~)
        defdir = get(B.defdir,'String');
        [background,backgrounddir] = uigetfile({'*.jpg','*.tiff','*.tif'},'Select the background image',defdir);
        set(B.C.background,'String',background);
        set(B.C.backgrounddir,'UserData',backgrounddir);
        
    end
    function hSiteReachesAddCallback(~, ~, ~)

        % get thalweg from figure
        thalweg = getappdata(plt.id,'thalweg');

        if ~isfield(thalweg,'reachbreak');
            reachbreak = [1 length(thalweg.ldistmore)];
        else
            reachbreak = thalweg.reachbreak;
        end
        % get data
        [ireach,jreach] = ginput(1);

        % calculate l and h distances based on the thalweg distance
        [~,hdistall] = cart2pol(ireach-thalweg.Emore,jreach-thalweg.Nmore);
        % find the thalweg position closest to the cartesian coordinate
        [~,thalnum] = min(hdistall);
        %
        reachbreak = [reachbreak thalnum];
        
        thalweg.reachbreak=sort(reachbreak);

        set(plt.id,'CurrentAxes',B.mainplanaxes)
        gobj = getappdata(plt.id,'hReach');
        removeGUIobj(gobj);

        X = thalweg.Emore(thalweg.reachbreak);
        Y = thalweg.Nmore(thalweg.reachbreak);
        hReach = line(X,Y,'Color','b','LineStyle','none','Marker','x');
        
        setappdata(plt.id,'thalweg',thalweg);
        setappdata(plt.id,'hReach',hReach);

    end
    function hSiteReachesResetCallback(~, ~, ~)

        % get thalweg from figure
        thalweg = getappdata(plt.id,'thalweg');
        
        if isfield(thalweg,'reachbreak');
            reachbreak = [];
        end

        set(plt.id,'CurrentAxes',B.mainplanaxes)
        gobj = getappdata(plt.id,'hReach');
        removeGUIobj(gobj);
        
        setappdata(plt.id,'thalweg',thalweg);

    end

    function hsaveCCallback(~, ~, ~)
        ofile = getappdata(plt.id,'ofile');
        thalweg = getappdata(plt.id,'thalweg');
        labData = getappdata(plt.id,'labData');
        C = subGetValues(B.C,[]);
        chk = dir(ofile);
        if isempty(chk)
            save(ofile,'C','thalweg');
        else
            save(ofile,'C','thalweg','-append');
        end            

    end

%% Add Tracer Callbacks
    function hseladdtagsCallback(~, ~, ~)
        set(B.seladdtagsmethod,'Enable','on');
    end
    function hseladdtagsmethodCallback(~, ~, ~)
        addtagsmethod = get(B.seladdtagsmethod,'Value');
        if addtagsmethod == 1
            set(B.addtagsmanualpanel,'Visible','off');
            set(B.addtagsfilepanel,'Visible','on');
        elseif addtagsmethod == 2
            set(B.addtagsfilepanel,'Visible','off');
            set(B.addtagsmanualpanel,'Visible','on');
        end            
    end
    function hselplacementfileCallback(~, ~, ~)
        defdir = get(B.defdir,'String');
        [placementfile,placementdir] = uigetfile('*.csv','Select the tracer placement *.csv file',defdir);
        set(B.placementfile,'String',placementfile);
        set(B.placementfile,'UserData',placementdir);
        setappdata(B.SiteReachesAdd,'Enable','on')
        set(B.goadd,'Enable','on');

    end

    function hgoaddCallback(~, ~, ~)
    % to add placement dates
        % get placement file names
        placementfile = get(B.placementfile,'String');
        placementdir = get(B.placementfile,'UserData');
        % get corresponding lab Data
        labData = getappdata(plt.id,'labData');
        % get thalweg from figure
        thalweg = getappdata(plt.id,'thalweg');

        % check existing list of placement dates to determine how to handle placedData
        placementdates = get(B.C.placementdates,'String');
        npdattot = length(placementdates);
        % loop to either add to or replace existing data
        if npdattot>0
            % get existing placedData from figure
            placedData = getappdata(plt.id,'placedData');
            % check if this date has been run already
            reanalyse = strcmp(placementdates,placementfile);
            % if it has not been analyzed already
            if ~any(reanalyse)
                nfile = npdattot+1;
            %elseif it has
            else
                nfile = find(reanalyse);
            end
        % if this is the first placedData    
        else
            nfile = 1;
            set(B.resetplacementdates,'Enable','on');
            
        end
        
        % run placeTags to calculate placedData
        placedData(nfile) = placeTags(placementdir,placementfile,labData,thalweg);
        placementdates{nfile}= placementfile;
        Lia = ismember(labData.tagnum,placedData(nfile).tagnum);
        labData.placeddate(Lia) = placedData(nfile).date(1);
        
        % save placeddate to labData
        
        % save data to figure
        setappdata(plt.id,'placedData',placedData);
        setappdata(plt.id,'labData',labData);
        set(B.C.placementdates,'String',placementdates);
        
        C = subGetValues(B.C,[]);
        ofile = getappdata(plt.id,'ofile');
        save(ofile,'C','placedData','labData','-append');
        
    end
    function hresetplacementdatesCallback(~, ~, ~)
        % get corresponding lab Data
        labData = getappdata(plt.id,'labData');
        % get thalweg from figure
        thalweg = getappdata(plt.id,'thalweg');
        % get existing placedData from figure
        placedData = getappdata(plt.id,'placedData');
        % get list of placement dates to determine how to handle placedData
        placementdir = uigetdir('E:\Research\Field','Get placed tags data directory again please! (sorry)');
        placementdir = [placementdir,filesep];
        placementdates = get(B.C.placementdates,'String');
        npdattot = length(placementdates);
        % loop to either add to or replace existing data
        for npdat = 1:npdattot
            placementfile = placementdates{npdat};

            % run placeTags to calculate placedData
            placedData(npdat) = placeTags(placementdir,placementfile,labData,thalweg);
            placementdates{npdat}= placementfile;
            Lia = ismember(labData.tagnum,placedData(npdat).tagnum);
            % save placeddate to labData
            labData.placeddate(Lia) = placedData(npdat).date(1);
        end

        % save data to figure
        setappdata(plt.id,'placedData',placedData);
        setappdata(plt.id,'labData',labData);
        set(B.C.placementdates,'String',placementdates);
        
        C = subGetValues(B.C,[]);
        ofile = getappdata(plt.id,'ofile');
        save(ofile,'C','placedData','labData','-append');        
    end

    function hplacementdatesCallback(~, ~, ~)
        pdmem = get(B.C.placementdates,'Value');
        nVpdtot = length(pdmem);
        set(B.selplacementseemethod,'Enable','on');
    end
    function hselplacementseemethodCallback(~, ~, ~)
        set(B.goseeplacement,'Enable','on');
    end
    function hgoseeplacementCallback(~, ~, ~)
        pdmem = get(B.C.placementdates,'Value');
        placedData = getappdata(plt.id,'placedData');
        nVpdtot = length(pdmem);
        datVpd = cell(nVpdtot,9);
        for nVpd=1:nVpdtot
            nVpgoo = pdmem(nVpd);
            datVpd(nVpd,1:2) = {datestr(placedData(nVpgoo).date,1) placedData(nVpgoo).nttot};
            datVpd(nVpd,3:9) =  num2cell(prctile(placedData(nVpgoo).db_mm,[5 16 25 50 75 84 95]));
        end
        postable = get(B.surveydatatable,'Position');         
        B.placementdatatable = uitable(B.panel(2),...
            'Units','pixels',...
            'FontSize',10,...
            'Position',postable,...
            'Data',datVpd,...
            'ColumnWidth',{100 60},...
            'ColumnName',{'Date','n_t','D_5','D_16','D_25','D_50','D_75','D_84','D_95'});
        % plot histogram
        
        set(plt.id,'CurrentAxes',B.axesplacementhist);
        cla
        histdat = zeros(nsztot,nVpdtot);
        for nVpd = 1:nVpdtot
            nVpgoo = pdmem(nVpd);
            histdat(:,nVpd) = histc(placedData(nVpgoo).db_mm,sizecat);
        end
        histtype = get(B.selplacementseemethod,'Value');
        if nVpdtot>1 
            if histtype == 1
                bar(log2(sizecat),histdat,'stacked');
            elseif histtype == 2
                bar(log2(sizecat),histdat,'grouped')
            end
        else
            bar(log2(sizecat),histdat)
        end
                
        set(plt.id,'CurrentAxes',B.axesplacementcumulative);
        cla
        histcum = zeros(nsztot,nVpdtot);
        for nVpd = 1:nVpdtot
            nVpgoo = pdmem(nVpd);
            histcum(:,nVpd) = cumsum(histdat(:,nVpd)/placedData(nVpgoo).nttot);
            line(log2(sizecat),histcum(:,nVpd));
        end
            
        
    end
%% Add Survey Callbacks
    function hseladdsurveyCallback(~, ~, ~)
        set(B.seladdsurveymethod,'Enable','on');
    end
    function hseladdsurveymethodCallback(~, ~, ~)
        addsurveymethod = get(B.seladdsurveymethod,'Value');
        if addsurveymethod == 1
            %set(B.addtagsmanualpanel,'Visible','off');
            set(B.addsurveyfilepanel,'Visible','on');
        elseif addsurveymethod == 2
            set(B.addsurveyfilepanel,'Visible','off');
            %set(B.addtagsmanualpanel,'Visible','on');
        end            
    end
    function hselsurveyfileCallback(~, ~, ~)
        defdir = get(B.defdir,'String');
        [surveyfile,surveydir] = uigetfile('*.csv','Select the tracer survey *.csv file',defdir);
        set(B.surveyfile,'String',surveyfile);
        set(B.surveyfile,'UserData',surveydir);
        % extract date from filename
        numberstr = regexp(surveyfile,'(\d+)','tokens');
        set(B.surveydate,'String',numberstr{1});
        set(B.goaddsurvey,'Enable','on');
    end    
    function hgoaddsurveyCallback(~, ~, ~)
    % to add placement dates
        % get placement file names
        surveyfile = get(B.surveyfile,'String');
        surveydir = get(B.surveyfile,'UserData');
        surveyfname = [surveydir,surveyfile];
        % get corresponding lab file name
        labData = getappdata(plt.id,'labData');

        % get thalweg from figure
        thalweg = getappdata(plt.id,'thalweg');

        % check existing list of placement dates to determine how to handle placedData
        surveydates = get(B.C.surveydates,'String');
        nsdattot = length(surveydates);
        % loop to either add to or replace existing data
        if nsdattot>0
            % get existing placedData from figure
            surveyData = getappdata(plt.id,'surveyData');
            % check if this date has been run already
            reanalyse = strcmp(surveydates,surveyfile);
            % if it has not been analyzed already
            if ~any(reanalyse)
                nfile = nsdattot+1;
            %elseif it has
            else
                nfile = find(reanalyse);
            end
        % if this is the first placedData    
        else
            nfile = 1;
        end
        
        % run surveyTags to calculate surveyData
        surveyData(nfile) = placeTags(surveydir,surveyfile,labData,thalweg);
        surveydates{nfile}= surveyfile;
        
        % save data to figure
        setappdata(plt.id,'surveyData',surveyData);
        set(B.C.surveydates,'String',surveydates);
        
        C = subGetValues(B.C,[]);
        ofile = getappdata(plt.id,'ofile');
        save(ofile,'C','surveyData','-append');
        
    end
    function hsurveydatesCallback(~, ~, ~)
        sdmem = get(B.C.surveydates,'Value');
        nsdtot = length(sdmem);
        if nsdtot > 1
            set(B.selsurveyseemethod,'String','combine|compare');
        else
            set(B.selsurveyseemethod,'String','combine|compare|single|');
        end            
        set(B.selsurveyseemethod,'Enable','on');
    end
    function hselsurveyseemethodCallback(~, ~, ~)
        set(B.goseesurvey,'Enable','on');
    end
    function hgoseesurveyCallback(~, ~, ~)
        sdmem = get(B.C.surveydates,'Value');
        surveyData = getappdata(plt.id,'surveyData');
        nsdtot = length(sdmem);
        datVpd = cell(nsdtot,9);
        for nsd=1:nsdtot
            nVpgoo = sdmem(nsd);
            datVpd(nsd,1:2) = {datestr(surveyData(nVpgoo).date,1) surveyData(nVpgoo).nttot};
            datVpd(nsd,3:9) =  num2cell(prctile(surveyData(nVpgoo).db_mm,[5 16 25 50 75 84 95]));
        end
        postable = get(B.surveydatatable,'Position');         
        B.surveydatatable = uitable(B.panel(3),...
            'Units','pixels',...
            'FontSize',10,...
            'Position',postable,...
            'Data',datVpd,...
            'ColumnWidth',{100 60},...
            'ColumnName',{'Date','n_f','D_5','D_16','D_25','D_50','D_75','D_84','D_95'});
        % plot histogram
        
        set(plt.id,'CurrentAxes',B.axessurveyhist);
        cla
        histdat = zeros(nsztot,nsdtot);
        for nsd = 1:nsdtot
            nVpgoo = sdmem(nsd);
            histdat(:,nsd) = histc(surveyData(nVpgoo).db_mm,sizecat);
        end
        histtype = get(B.selsurveyseemethod,'Value');
        if nsdtot>1 
            if histtype == 1
                bar(log2(sizecat),histdat,'stacked');
            elseif histtype == 2
                bar(log2(sizecat),histdat,'grouped')
            end
        else
            bar(log2(sizecat),histdat)
        end
                
        set(plt.id,'CurrentAxes',B.axessurveycumulative);
        cla
        histcum = zeros(nsztot,nsdtot);
        for nsd = 1:nsdtot
            nVpgoo = sdmem(nsd);
            histcum(:,nsd) = cumsum(histdat(:,nsd)/surveyData(nVpgoo).nttot);
            line(log2(sizecat),histcum(:,nsd));
        end
            
        
    end

%% Visualize Results Callbacks
    function hinitializeVizCallback(~, ~, ~)
        thalweg = getappdata(plt.id,'thalweg');
        set(plt.id,'CurrentAxes',B.Vizplanaxes);
        PlotThalweg(thalweg);
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
            setappdata(plt.id,'hReach',hReach);
            set(B.VizReaches,'String',rchlist);
            set(B.VizReaches,'Value',1:nrtot-1);
            set(B.Vizselreachall,'Value',1);
        end
        if isfield(B.C,'placementdates')
            placementdates = get(B.C.placementdates,'String');
            set(B.Vizplacementdates,'String',placementdates);
            set(B.VizShow,'Enable','on');
        end
        if isfield(B.C,'surveydates') 
            surveydates = get(B.C.surveydates,'String');
            set(B.Vizsurveydates,'String',surveydates);
        end
    end
    function hVizShowCallback(~, ~, ~)

        %Show = getappdata('Show');
        placedData = getappdata(plt.id,'placedData');
        surveyData = getappdata(plt.id,'surveyData');
        thalweg = getappdata(plt.id,'thalweg');
        
        pdmem = get(B.Vizplacementdates,'Value');
        sdmem = get(B.Vizsurveydates,'Value');
        selsize = get(B.Vizselsize,'Value');
        selsize = [selsize selsize(end)+1];
        sizes = sizecat(selsize);

        reachnum = get(B.VizReaches,'Value');
        reaches = thalweg.ldistmore(thalweg.reachbreak([reachnum reachnum+1]));
        
        nVpdtot = length(pdmem);
        nVsdtot = length(sdmem);

        hVpd = zeros(1,nVpdtot);
        hVsd = zeros(1,nVsdtot);
        
        datVpd = cell(nVpdtot,6);
        datVsd = cell(nVsdtot,6);

        set(plt.id,'CurrentAxes',B.Vizplanaxes);

        gobj = getappdata(plt.id,'hVpd');
        removeGUIobj(gobj);
        gobj = getappdata(plt.id,'hVsd');
        removeGUIobj(gobj);
        
        %loop through selected placed data
        for nVpd=1:nVpdtot
            % get appropriate index to placedData
            nVpgoo = pdmem(nVpd);
            % save date and total number of particles
            datVpd(nVpd,1:2) = {datestr(placedData(nVpgoo).date,1) num2str(placedData(nVpgoo).nttot)};
            % find selected particles
            goo = IntersectTracerData(placedData(nVpgoo),surveyData(sdmem),sizes,reaches);
            % count selected particles
            datVpd(nVpd,3) = {num2str(sum(goo))};
            % calculate size percentiles of placed data
            datVpd(nVpd,4) = {num2str(prctile(placedData(nVpgoo).db_mm,16),'%4.0f')};
            datVpd(nVpd,5) = {num2str(prctile(placedData(nVpgoo).db_mm,50),'%4.0f')};
            datVpd(nVpd,6) = {num2str(prctile(placedData(nVpgoo).db_mm,84),'%4.0f')};
            % draw line of placed data
            if str2double(datVpd{nVpd,3})>0
                hVpd(nVpd) = line(placedData(nVpgoo).Easting(goo),placedData(nVpgoo).Northing(goo),'LineStyle','none','Color','k','MarkerFaceColor','w','Marker','v');
            end
        end
        % rewrite placed data table
        posptable = get(B.Vizplacementdatatable,'Position');
        B.Vizplacementdatatable2 = uitable(B.panel(4),...
            'Units','pixels',...
            'FontSize',10,...
            'Position',posptable,...
            'Data',datVpd,...
            'ColumnWidth',{80 40 40 40 40 40},...
            'ColumnName',{'Date','n_t','n_s','D_16','D_50','D_84'});

        % create colors for surveyed tags
        nctot = nVsdtot;
        cmap = copper;%jet;% % jet coloring, could also be used with bone, autumn, etc.
        njettot = length(cmap);
        ngooc = floor(1:njettot/nctot:njettot);
        col = cmap(ngooc,:);


        % loop through selected survey data
        %loop through selected placed data
        for nVsd=1:nVsdtot
            % get appropriate index to placedData
            nVsgoo = sdmem(nVsd);
            % save date and total number of particles
            datVsd(nVsd,1:2) = {datestr(surveyData(nVsgoo).date,1) num2str(surveyData(nVsgoo).nttot)};
            % find selected particles
            goo = IntersectTracerData(surveyData(nVsgoo),placedData(pdmem),sizes,reaches);
            % count selected particles
            datVsd(nVsd,3) = {num2str(sum(goo))};
            % calculate size percentiles of placed data
            datVsd(nVsd,4) = {num2str(prctile(surveyData(nVsgoo).db_mm,16),'%4.0f')};
            datVsd(nVsd,5) = {num2str(prctile(surveyData(nVsgoo).db_mm,50),'%4.0f')};
            datVsd(nVsd,6) = {num2str(prctile(surveyData(nVsgoo).db_mm,84),'%4.0f')};
            % draw line of placed data
            if str2double(datVsd{nVsd,3})>0
                hVsd(nVsd) = line(surveyData(nVsgoo).Easting(goo),surveyData(nVsgoo).Northing(goo),'LineStyle','none','Color','k','MarkerFaceColor','k','Marker','^');%,'MarkerFaceColor',col(nVsd,:)
                hVsd(nVsd) = line(surveyData(nVsgoo).Easting(goo),surveyData(nVsgoo).Northing(goo),'LineStyle','none','Color','k','MarkerFaceColor','k','Marker','^');%,'MarkerFaceColor',col(nVsd,:)
            end
        end

        posstable = get(B.Vizsurveydatatable,'Position');         
        B.Vizsurveydatatable2 = uitable(B.panel(4),...
            'Units','pixels',...
            'FontSize',10,...
            'Position',posstable,...
            'Data',datVsd,...
            'ColumnWidth',{80 40 40 40 40 40},...
            'ColumnName',{'Date','n_t','n_s','D_16','D_50','D_84'});
        
        set(B.VizPlacementClear,'Enable','on');
        set(B.VizSurveyClear,'Enable','on');

        setappdata(plt.id,'hVpd',hVpd);
        %setappdata(plt.id,'pdmem',pdmem);
        setappdata(plt.id,'hVsd',hVsd);
        %setappdata(plt.id,'sdmem',sdmem);
                    
    end
    function hVizPlacementClearCallback(~, ~, ~)
    % radio button to show the placement data or not
        gobj = getappdata(plt.id,'hVpd');

        removeGUIobj(gobj);
             
    end
    function hVizSurveyClearCallback(~, ~, ~)
    % radio button to show the placement data or not
        gobj = getappdata(plt.id,'hmob');

        removeGUIobj(gobj);
            
    end
    function hVizselsizeallCallback(~, ~, ~)
        allon = get(B.C.placementdates,'Value'); % note Is this referring to the right cell?
        if allon == 1
            set(B.Vizselsize,'Value',1:length(sizecat)-1);
        end
    end
    function hVizselreachallCallback(~, ~, ~)
        allon = get(B.Vizselreachall,'Value');
        if allon == 1
            rchlist = B.VizReaches;
            nrtot = length(rchlist);
            set(B.VizReaches,'Value',1+nrtot);
        end
    end
    function hVizDEMCallback(~, ~, ~)
        thalweg = getappdata(plt.id,'thalweg');

        addDEM(B,thalweg)
%         defdir = get(B.defdir,'String');
%         [DEMfile,DEMdir] = uigetfile('*.csv','Select the topography *.csv file',defdir);
%         set(B.C.VizDEMfile,'String',DEMfile);
% 
%         DEMfname = [DEMdir,DEMfile];
%         CalcDEM(DEMfname,thalweg);
%         
        set(plt.id,'CurrentAxes',B.mainplanaxes)
        PlotThalweg(thalweg);
        
        setappdata(plt.id,'thalweg',thalweg)
        set(B.SiteReachesAdd,'Enable','on')

    end

        
%% Analysze functions
    function hAnaAddDataCallback(~,~,~)
        placedData = getappdata(plt.id,'placedData');
        surveyData = getappdata(plt.id,'surveyData');
        thalweg = getappdata(plt.id,'thalweg');

        set(B.AnaAddDataPanel,'Visible','on')

        % write dates
        datelist = sort([placedData.date surveyData.date]);
        set(B.AnaStart,'String',datestr(datelist));
        set(B.AnaEnd,'String',datestr(datelist));
       
        % set reach data
        reaches = thalweg.ldistmore(thalweg.reachbreak);
        nrtot = length(reaches);
        
        rchlist = cell(1,nrtot-1);
        for nr = 1:nrtot
            rchlist(nr) = cellstr(num2str(nr));
        end
        set(B.AnaFrom,'String',rchlist);
        set(B.AnaTo,'String',rchlist);
        
        % set wave data
        labData = getappdata(plt.id,'labData');
        wavenums = unique(labData.wavenum);
        set(B.AnaWaveList,'String',wavenums);
        
        set(B.AnaGoAdd,'Enable','on');
        
    end
    function hAnaWaveallCallback(~, ~, ~)
        allon = get(B.AnaWaveall,'Value'); % note Is this referring to the right cell?
        wavenums = get(B.AnaWaveList,'String');

        if allon == 1
            set(B.AnaWaveList,'Value',1:length(wavenums));
        else
            set(B.AnaWaveList,'Value',1);
        end
    end
    function hAnaGoAddCallback(~,~,~)
        %D50 = 31;
        %D84 = 128;
        % get color and symbol data
        lcols = get(B.AnaColor,'String');
        lcol = lcols(get(B.AnaColor,'Value'));
        lmarks = get(B.AnaSymbol,'String');
        lmark = lmarks(get(B.AnaSymbol,'Value'));

        placedData = getappdata(plt.id,'placedData');
        surveyData = getappdata(plt.id,'surveyData');
        labData = getappdata(plt.id,'labData');
        thalweg = getappdata(plt.id,'thalweg');

        datestart = get(B.AnaStart,'Value');
        dateend = get(B.AnaEnd,'Value');

        reachup = get(B.AnaFrom,'Value');
        reachdown = get(B.AnaTo,'Value');
        reachldist = thalweg.ldistmore(thalweg.reachbreak);
        reaches = reachldist([reachup reachdown]);

        waves = get(B.AnaWaveList,'Value');

        sizes = 2.^[3:1:9];%sizecat;%

        % sort by date
        tracerData = [placedData surveyData];
        [~,idx] = sort([tracerData.date]);
        tracerData = tracerData(idx);
        
        % find positions for start and end dates
        found1 = FindPositions(datestart,tracerData,labData);
        found2 = FindPositions(dateend,tracerData,labData);
        
        % intersect start and end dates
        % find data that meets the size criteria
        gooz = labData.db_mm>=sizes(1) & labData.db_mm<sizes(end);
        % find data that started in or were last seen in the reach 
        goor = nanmax([found1.ldist found1.ldistlast],[],2)>=reaches(1) & nanmax([found1.ldist found1.ldistlast],[],2)<reaches(end);
        % find data that was in the requested wave(s)
        goow = ismember(labData.wavenum,waves);
        % intersect size and position criteria
        classed = gooz & goor & goow;
        
        % calculate pathlengths
        pathlength = found1.ldist-found2.ldist;
        
        

        % determine all classed particles
        tmem = found1.in & classed;
        nt = sum(tmem);
        
        % determine found and inferred classed particles on the start and end dates
        f1mem = (found1.found|found1.inferred) & classed;
        f2mem = (found2.found|found2.inferred) & classed;
        fimem = f1mem & f2mem; %data on which length statistics can be calculated
        nf1 = sum(f1mem);
        nf2 = sum(f2mem);
        ni = sum(fimem);

        % determine inferred and indeterminite classed particles
        infmem = found2.inferred & classed;
        indmem = found2.indeterminite & classed;
        ninf = sum(infmem);
        nind = sum(indmem);

        % determine missing and lost classed particles
        missmem = found2.missing & classed;
        lostmem = found2.lost & classed;
        nmiss = sum(missmem);
        nlost = sum(lostmem);

        % determine moved and unmoved classed particles
        movmem = pathlength>=1.0 & fimem;
        unmovmem = pathlength<1.0 & fimem;
        
        nmov = sum(movmem);
        nunmov = sum(unmovmem);
        
        % calculate the LD50
        LD50 = CalcLD50(D50,found1.db_mm,pathlength,movmem);

        %% data table
        % create data table
        datAna = getappdata(plt.id,'datAna');
        if isempty(datAna)
            natot = 1;
            datAna = cell(1,14);
        else
            [natot,dum] = size(datAna);
            natot = natot+1;
        end
        
        % add data to the datAna table
        AnaName = get(B.AnaName,'String');
        if isempty(AnaName)
            AnaName = num2str(natot);
        end
        datAna(natot,1:3) = {AnaName datestr(found1.tracerData.date,1) datestr(found2.tracerData.date,1)};
        datAna(natot,4) = {[num2str(reachup),' - ',num2str(reachdown)]};
        datAna(natot,5:end-1) = {num2str(nt) num2str(nf1) num2str(nf2) num2str(ni) num2str(ninf) num2str(nind) num2str(nmiss) num2str(nlost) num2str(nmov)};
        datAna(natot,end) = {num2str(LD50,'%4.1f')};
            
        % set the datAna table
        postable = get(B.AnaSeriesData,'Position');         
        B.AnaSeriesData = uitable(B.panel(5),...
        'Units','pixels',...
        'FontSize',10,...
        'Position',postable,...
        'ColumnWidth',{40 80 80 40 40 40 40 40 40 40 40 40 40 40},...
        'Data',datAna,...
        'ColumnName',{'Series','Start Date','End Date','Reach','ntot','nfnd1','nfnd2','nfint','ninf','nind','nmiss','nlst','nmov','LD50'});

        %% mobility plot
        % add data to mobility plot
        szcat = sizecat;%2.^[3 5 6 7 9];
        set(plt.id,'CurrentAxes',B.AnaMobility);
        hmob = getappdata(plt.id,'hmob');
        hmobupper = getappdata(plt.id,'hmob');
        hmoblower = getappdata(plt.id,'hmob');
        if natot == 1
            % add d50 and d84 lines to mobility plot
            line([log2(D50) log2(D50)],[0 1]);
            text(log2(D50),.95,'D_{50}','Rotation',90,'HorizontalAlignment','Right','VerticalAlignment','bottom');
            line([log2(D84) log2(D84)],[0 1]);
            text(log2(D84),.95,'D_{84}','Rotation',90,'HorizontalAlignment','Right','VerticalAlignment','bottom');
        end
        % find number per size class
        n = histc(labData.db_mm(fimem),szcat);
        % find number moved per size class
        m = histc(labData.db_mm(movmem),szcat);
        % add line ratio moved per size class to AnaMobility
        
        avgsize = (szcat(1:end-1)+szcat(2:end))/2;
        pmean = (m(1:end-1)./n(1:end-1));
        hmob(natot) = line(log2(avgsize),pmean,...
            'Color',lcol,...
            'Marker',lmark,...
            'Linestyle','none',...
            'LineWidth',1);
        
        legend('D50','D84',datAna{:,1});
        % add 95% confidence limits
        % from example 2.1 in Modelling Binary Data, 3rd method, which
        % assumes normal approximation to the binomial distribution
        pse = (pmean.*(1-pmean)./n(1:end-1)).^0.5;
        zse = 1.96; % 95% confidence
        pupper = pmean+zse*pse;
        plower = pmean-zse*pse;

        hmobupper(natot) = line(log2(avgsize),pupper,...
            'Color',lcol,...
            'Marker','+',...
            'Linestyle','--',...
            'LineWidth',1);
        hmoblower(natot) = line(log2(avgsize),plower,...
            'Color',lcol,...
            'Marker','+',...
            'Linestyle','--',...
            'LineWidth',1);    
        hmboth = line(log2([avgsize;avgsize]),[plower pupper]',...
            'Color',lcol,...
            'Marker','none',...
            'Linestyle','none',...
            'LineWidth',1);    
        
        %% normalized distance plot 
        set(plt.id,'CurrentAxes',B.AnaNormPathLength);
        hnormpath = getappdata(plt.id,'hnormpath');
        % draw Hassan and Church line
        if natot == 1
            xch = 10.^[-1:.1:1];
            ych = 10^0*(1-log10(xch)).^1.35;
            line(xch,ych,'LineStyle','--','Color','k','LineWidth',1);
        end
        % calculate stats by size category
        szcat = [4 5 6 7 8];
        nsztot = length(szcat);
        distSize = zeros(nsztot,9);
        nD50 = find(histc(log2(D50),szcat));
        % for each size category
        for ns = 1:nsztot-1
       
            gooD = log2(labData.db_mm)>=szcat(ns) & log2(labData.db_mm)<szcat(ns+1);
            gooS = gooD & movmem;
            % calculate statistics for this size class
            if any(gooS)
                distSize(ns,1) = sum(gooS);
                distSize(ns,2) = mean(pathlength(gooS));
                distSize(ns,3) = std(pathlength(gooS));
                distSize(ns,4) = 10^(mean(log10(pathlength(gooS))));
                distSize(ns,5) = 10^(log10(distSize(ns,4))+(std(log10(pathlength(gooS)))/sqrt(distSize(ns,1))));
                distSize(ns,6) = 10^(log10(distSize(ns,4))-(std(log10(pathlength(gooS)))/sqrt(distSize(ns,1))));
                distSize(ns,7) = mean(labData.db_mm(gooS));
%                distSize(ns,8) = kstest((pathlength(gooS)-distSize(ns,2))/distSize(ns,3),'Alpha',0.05); %kolmogorov-smirnov test for normality 
%                distSize(ns,9) = kstest((log10(pathlength(gooS))-log10(distSize(ns,4)))/std(log10(pathlength(gooS))),'Alpha',0.05); %kolmogorov-smirnov test for normality 
                
            end
        end
        LpD50 = distSize(nD50,4); % geometric mean
        % normalize using the geometric mean path length from phi category with the D50 from Hassan et al 1992
        if LpD50 > 0
            a = distSize(:,1)>1;
            xx = distSize(a,7)/D50;
            yy = distSize(a,4)/LpD50;
            yup = distSize(a,5)/LpD50;
            ydown = distSize(a,6)/LpD50;
        %    yup = (distSize(:,2,nd)+(distSize(:,3,nd)./(distSize(ns,1,nd).^0.5)))/LD50;
        %    ydown = (distSize(:,2,nd)-(distSize(:,3,nd)./(distSize(ns,1,nd).^0.5)))/LD50;
            lin = line(xx,yy,'LineStyle','none','Color',lcol,'LineWidth',1,'Marker',lmark)
            linup = line(xx,yup,'LineStyle','none','Color',lcol,'Marker','+');
            linup = line(xx,ydown,'LineStyle','none','Color',lcol,'Marker','+');
            linj = line([xx xx]',[yup ydown]','Color',lcol,'Marker','none');
        end

        setappdata(plt.id,'datAna',datAna);
        setappdata(plt.id,'hmob',hmob);
        setappdata(plt.id,'hmobupper',hmobupper);
        setappdata(plt.id,'hmoblower',hmoblower);
        setappdata(plt.id,'hmboth',hmboth);
        
        %% image
        set(plt.id,'CurrentAxes',B.Anaplanaxes);
        %addDEM(B,thalweg)
        PlotThalweg(thalweg);
        
        varnames = {'fimem','infmem','missmem','lostmem','movemem'};
        col = {'r','b','r','b','k'};

        %hvarImage(1) = line(found2.Eastinglast(fimem),found2.Northinglast(fimem),'LineStyle','none','Color',col{1},'MarkerFaceColor','w','Marker','v');
        %hvarImage(2) = line(found2.Eastinglast(infmem),found2.Northinglast(infmem),'LineStyle','none','Color',col{2},'MarkerFaceColor','w','Marker','v');
        if any(missmem)
            %hvarImage(3) = line(found2.Eastinglast(missmem),found2.Northinglast(missmem),'LineStyle','none','Color',col{3},'MarkerFaceColor','k','Marker','p');
        else
            1
        end
        if any(lostmem)
            hvarImage(4) = line(found2.Eastinglast(lostmem),found2.Northinglast(lostmem),'LineStyle','none','Color','b','MarkerFaceColor','b','Marker','p');
        else
            2
        end
        %hvarImage(5) = line(found2.Eastinglast(movmem),found2.Northinglast(movmem),'LineStyle','none','Color',col{5},'MarkerFaceColor','w','Marker','v');

        
        set(B.AnaAddDataPanel,'Visible','off')
        
    end
    function hAnaRemDataCallback(~,~,~)
        datAna = getappdata(plt.id,'datAna');
        [nrtot,~] = size(datAna);
        datAnanm = datAna{1,1};
        if nrtot>1
            for nr = 2:nrtot
                datAnanm = [datAnanm,'|',datAna{nr,1},' '];
            end
        end
        set(B.AnaRemName,'String',datAnanm);
        
        set(B.AnaRemDataPanel,'Visible','on');
        set(B.AnaGoRem,'Enable','on'); 
    end
    function hAnaGoRemCallback(~,~,~)
        datAna = getappdata(plt.id,'datAna');
        hmob = getappdata(plt.id,'hmob');
        hmobupper = getappdata(plt.id,'hmobupper');
        hmoblower = getappdata(plt.id,'hmoblower');
        hmboth = getappdata(plt.id,'hmboth');
        AnaRemValue = get(B.AnaRemName,'Value');
        
        % remove from data table
        datAna(AnaRemValue,:) = [];
        postable = get(B.AnaSeriesData,'Position');         
        B.AnaSeriesData = uitable(B.panel(5),...
        'Units','pixels',...
        'FontSize',10,...
        'Position',postable,...
        'ColumnWidth',{40 80 80 40 40 40 40 40 40 40 40 40 40 40},...
        'Data',datAna,...
        'ColumnName',{'Series','Start Date','End Date','Reach','ntot','nfnd1','nfnd2','nfint','ninf','nind','nmiss','nlst','nmov','LD50'});

        % remove from mobility figure
        gobj = getappdata(plt.id,'hmob');
        removeGUIobj(gobj(AnaRemValue));
        hmob(AnaRemValue) = [];
        gobj = getappdata(plt.id,'hmobupper');
        removeGUIobj(gobj(AnaRemValue));
        hmobupper(AnaRemValue) = [];
        gobj = getappdata(plt.id,'hmoblower');
        removeGUIobj(gobj(AnaRemValue));
        hmoblower(AnaRemValue) = [];
        gobj = getappdata(plt.id,'hmboth');
        removeGUIobj(gobj(AnaRemValue));
        hmboth(AnaRemValue) = [];
        legend(datAna{:,1});
        
        setappdata(plt.id,'datAna',datAna);
        setappdata(plt.id,'hmob',hmob);
        setappdata(plt.id,'hmobupper',hmobupper);
        setappdata(plt.id,'hmoblower',hmoblower);
        setappdata(plt.id,'hmboth',hmboth);
        
        set(B.AnaRemDataPanel,'Visible','off')
        
    end

    % executes when a panel activation button is pushed
    function hpanfCallback(~, ~, npanftot, npanf)
        for npanfi = 1:npanftot
            if npanfi == npanf
                set(B.panfig(npanfi),'Visible','on');
            else
                set(B.panfig(npanfi),'Visible','off');
            end
        end
    end

end
