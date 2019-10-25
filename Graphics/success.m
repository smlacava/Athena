function success()
    im=imread('untitled3.png');
    h=msgbox('Operation Completed','Success','custom',im);
    set(h, 'color', [0.67 0.98 0.92])
end