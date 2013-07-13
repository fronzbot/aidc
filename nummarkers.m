function nummarkers(a,numMark,linMark)

% NUMMARKERS takes an axis handle in a and reduces the number of plot 
% markers on the lines to num. This is useful for closely sampled data.
%
% example:
% t = 0:0.01:pi;
% plot(t,sin(t),'-*',t,cos(t),'r-o');
% nummarkers(gca,10);
% legend('sin(t)','cos(t)')
%

% Magnus Sundberg Feb 08, 2001
% Mark Pude Jan 25 2013

if nargin < 3
    linMark = 0;
end

h = get(a,'children');

for n = 1:length(h)
    if strcmp(get(h(n),'type'),'line')
        % Get data and find points for markers
        x = get(h(n),'xdata');
        y = get(h(n),'ydata');
        
        if linMark
            xi = x(round(linspace(1,length(x),numMark)));
            yi = y(round(linspace(1,length(y),numMark)));
        else
            t = 1:length(x);
            s = [0 cumsum(sqrt(diff(x).^2+diff(y).^2))];
            si = (0:numMark-1)*s(end)/(numMark-1);
            ti = round(interp1(s,t,si));
            xi = x(ti);
            yi = y(ti);
        end
        
        % make a line with just the markers
        h_mark = copyobj(h(n),a);
        set(h_mark,'linestyle','none');
        set(h_mark,'xdata',xi);
        set(h_mark,'ydata',yi);
        
        % make a copy of the old line with no markers
        h_mark = copyobj(h(n),a);
        set(h_mark,'marker','none');
        
        % set the x- and ydata of the old line to [], this tricks legend 
        % to keep on working
        set(h(n),'xdata',[],'ydata',[]);
    end
end