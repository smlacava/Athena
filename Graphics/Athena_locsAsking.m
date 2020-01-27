stages = 5;
fig = figure('Visible','off');
box = zeros(stages,1);
panel = uipanel('parent',fig,...
    'Title','Choose stages to plot',... 
    'position',[.01 .05 .25 .95]);
A=zeros(stages,1);
for i = 1:stages
      box(i,1) = uicontrol('parent',panel,'style','checkbox',...
          'string',i,...
          'position',[20 360-i*25 40 20],...
          'callback',@(src,evt)mycb(src,evt,i))); 
end
set(fig,'Visible','on')

function mycb(src,evt,i)
    A(i,1) = 1
    % Do whatever with A
end