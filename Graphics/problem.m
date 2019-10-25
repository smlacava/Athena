function problem(message)
    if nargin==0
        message="We found some problems";
    end
    im=imread('untitled3.png');
    h=msgbox(message,'Error','custom',im);
    set(h, 'color', [0.67 0.98 0.92])
end