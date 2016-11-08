function removeGUIobj(gobj)

if ~isempty(gobj)
    goozero = gobj==0;
    gobj(goozero)=[];
    if isgraphics(gobj);
        delete(gobj);
    end
end
