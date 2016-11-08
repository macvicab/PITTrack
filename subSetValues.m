function B = subSetValues(B,val)
% set values for buttons, editable fields and other GUI input fields
% called from MITT and ClassifyArrayGUI

Bname = subFieldnames(val);
%set display filter parameters from BC
nBtot = length(Bname);
% check for UserData fields
ngoo = strfind(Bname,'UserData');
% get faQC parameters from figure

for nB = 1:nBtot
    if isempty(ngoo{nB})
        eval(['Bstyle = get(B.',Bname{nB},',''Style'');']);
        switch Bstyle
            case 'edit'
                eval(['set(B.',Bname{nB},',''String'',num2str(val.',Bname{nB},'));']);
            case 'text'
                eval(['set(B.',Bname{nB},',''String'',val.',Bname{nB},');']);
            case 'checkbox'
                eval(['set(B.',Bname{nB},',''Value'',val.',Bname{nB},');']);
            case 'listbox'
                eval(['set(B.',Bname{nB},',''String'',val.',Bname{nB},');']);
            case 'popupmenu'
                eval(['set(B.',Bname{nB},',''Value'',val.',Bname{nB},');']);
        end
        eval(['chk = isfield(val,''',Bname{nB},'UserData'');']);
        if chk
            eval(['set(B.',Bname{nB},',''UserData'',val.',Bname{nB},'UserData'');']);
        end
    end
end
