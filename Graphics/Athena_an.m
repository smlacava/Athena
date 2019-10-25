
%Possible names:
%Athena_an (Automatic Toolbox for Handling Easy Neural Analyzes)
%Apheleia (Automatic Pipeline for Handling Easy Localized Initial Analyzes)

% Multi GUI:
% int1 => save data => int2 => load data => save data2 =>...
% delete to delete partial output

function varargout = Athena_an(varargin)

% Begin initialization code
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_an_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_an_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code


% --- Executes just before the GUI is made visible.
function Athena_an_OpeningFcn(hObject, eventdata, handles, varargin)

    handles.output = hObject;
    guidata(hObject, handles);
    myImage = imread('untitled3.png');
    set(handles.axes3,'Units','pixels');
    resizePos = get(handles.axes3,'Position');
    myImage= imresize(myImage, [resizePos(3) resizePos(3)]);
    axes(handles.axes3);
    imshow(myImage);
    set(handles.axes3,'Units','normalized');

    
% --- Outputs from this function are returned to the command line.
function varargout = Athena_an_OutputFcn(hObject, eventdata, handles) 

    varargout{1} = handles.output;




% --- Executes on button press in back.
function back_Callback(hObject, eventdata, handles)
% hObject    handle to back (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    close(Athena_an)
    Athena_epmean


% --- Executes during object creation, after setting all properties.
function axes3_CreateFcn(hObject, eventdata, handles)

% hObject    handle to axes3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes3




% --- Executes on button press in IndCorr.
function IndCorr_Callback(hObject, eventdata, handles)
% hObject    handle to IndCorr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    close(Athena_an)
    Athena_indcorr


% --- Executes on button press in MeasCorr.
function MeasCorr_Callback(hObject, eventdata, handles)
% hObject    handle to MeasCorr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    close(Athena_an)
    Athena_meascorr

% --- Executes on button press in StatAn.
function StatAn_Callback(hObject, eventdata, handles)
% hObject    handle to StatAn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    close(Athena_an)
    Athena_statan


% --- Executes on button press in clasData.
function clasData_Callback(hObject, eventdata, handles)
% hObject    handle to clasData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    close(Athena_an)
    Athena_mergsig


% --- Executes on button press in EpAn.
function EpAn_Callback(hObject, eventdata, handles)
% hObject    handle to EpAn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    close(Athena_an)
    Athena_epan


% --- Executes on button press in meaext.
function meaext_Callback(hObject, eventdata, handles)
% hObject    handle to meaext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(Athena_an)
Athena

% --- Executes on button press in tempav.
function tempav_Callback(hObject, eventdata, handles)
% hObject    handle to tempav (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(Athena_an)
Athena_epmean