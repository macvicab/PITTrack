function addDEM(B,thalweg)

defdir = get(B.defdir,'String');
[DEMfile,DEMdir] = uigetfile('*.csv','Select the topography *.csv file',defdir);
set(B.C.VizDEMfile,'String',DEMfile);

DEMfname = [DEMdir,DEMfile];
CalcDEM(DEMfname,thalweg);
        
end