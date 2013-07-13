function fixFig(fig, hleg, loc, boolleg)%, noMark, linMark, repMark, offMark, noLine, allMark, thinLine,boxPlt)

set(findall(fig,'type','text'),'fontName','Book Antiqua','fontSize',10, 'fontWeight', 'bold')

if nargin < 9
    boxPlt = 0;
end
if nargin < 8
    thinLine = 0;
end
if nargin < 7
    allMark = 0;
end
if nargin < 6
    noLine = 0;
end
if nargin < 5
    offMark = 0;
end
if nargin < 5
    repMark = 0;
end
if nargin < 9
    linMark = 0;
end
if nargin < 9
    noMark = 0;
end
if nargin < 1
    fig = figure(1);
end

noMark = 1;

linMark = 1;
figure(fig)
A = axis;
axis(A);


set(fig,'Units','inches');
curPos = get(fig,'Position');
set(fig,'Position',[curPos(1) curPos(2) 5 3]);
set(fig,'PaperPosition', [0 0 5 3])

if boolleg == true
    set(hleg, 'Location', loc);
    set(hleg, 'fontsize', 8);
    set(hleg, 'Box', 'off');
end

if boxPlt
    lineH = findall(fig,'type','line');
else
    lineH = get(gca,'Children');
end

for i=1:length(lineH)
    marker = ['o' 's' 'd' '^' 'v' '<' '>' '+' '*' 'x'];
    
    if noLine
        set(lineH(i),'LineStyle','none');
    end
    
    
    set(lineH(i),'Color','k');
    if(thinLine)
        set(lineH(i),'LineWidth',0.5);
    else
        set(lineH(i),'LineWidth',1.5);
    end
    
    markIndex = mod(i,repMark) + offMark;
    if markIndex == 0
        markIndex = repMark + offMark;
    end
    
    if ~noMark
        set(lineH(i),'Marker',marker(markIndex));
        set(lineH(i),'MarkerSize',6);
    end
end

if ~noMark & ~allMark
    nummarkers(gca,10,linMark);
end
    
grid off

lineAxes = gca;

if (strcmp(get(lineAxes,'color'),'none'))
    set(lineAxes,'color','none')
    set(lineAxes,'xcolor','k')
    set(lineAxes,'ycolor','k')
    uistack(lineAxes,'top')
else
    gridAxes = copyobj(lineAxes,gcf);
    
    delete(get(gridAxes,'children'))
    
    set(gridAxes,'xgrid','on')
    set(gridAxes,'xcolor',[0.75 0.75 0.75])
    set(gridAxes,'ygrid','on')
    set(gridAxes,'ycolor',[0.75 0.75 0.75])
    set(gridAxes,'gridlinestyle','-')
    set(gridAxes,'minorgridlinestyle','-')
    
    set(lineAxes,'color','none')
    set(lineAxes,'xcolor','k')
    set(lineAxes,'ycolor','k')
    
    uistack(gridAxes,'top')
    uistack(lineAxes,'top')
end





