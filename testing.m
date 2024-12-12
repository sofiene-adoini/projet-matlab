function varargout = testing(varargin)
% TESTING MATLAB code for testing.fig
%      TESTING, by itself, creates a new TESTING or raises the existing
%      singleton*.
%
%      H = TESTING returns the handle to a new TESTING or the handle to
%      the existing singleton*.

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @testing_OpeningFcn, ...
                   'gui_OutputFcn',  @testing_OutputFcn, ...
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
% End initialization code - DO NOT EDIT

% --- Executes just before testing is made visible.
function testing_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
handles.running = false;  % Add state variable for detection loops

% Initialize axes with blank image
axes(handles.axes1);
try
    imshow('blank.jpg');
catch
    % Create a blank image if file doesn't exist
    blankImage = zeros(480, 640, 3, 'uint8');
    imshow(blankImage);
end
axis off;

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = testing_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

% --- Executes on button press in start.
function start_Callback(hObject, eventdata, handles)
try
    % Initialize video input
    if ~isfield(handles, 'vid') || ~isvalid(handles.vid)
        handles.vid = videoinput('winvideo', 1, 'YUY2_640X480');
        handles.vid.ReturnedColorspace = 'rgb';
        handles.vid.Timeout = 5;
        
        % Configure video input
        triggerconfig(handles.vid, 'manual');
        set(handles.vid, 'TriggerRepeat', inf);
        set(handles.vid, 'FramesPerTrigger', 1);
    end
    
    guidata(hObject, handles);
    msgbox('Camera initialized successfully', 'Success');
catch ME
    errordlg(['Error initializing camera: ' ME.message], 'Error');
end

% --- Executes on button press in face.
function face_Callback(hObject, eventdata, handles)
try
    if ~isfield(handles, 'vid') || ~isvalid(handles.vid)
        errordlg('Please initialize the camera first', 'Error');
        return;
    end
    
    % Stop any existing detection
    handles.running = false;
    pause(0.1);
    
    % Start new detection
    handles.running = true;
    guidata(hObject, handles);
    
    % Configure face detector
    facedetector = vision.CascadeObjectDetector;
    start(handles.vid);
    
    while handles.running && isvalid(handles.vid)
        try
            trigger(handles.vid);
            handles.im = getdata(handles.vid, 1);
            bbox = step(facedetector, handles.im);
            hello = insertObjectAnnotation(handles.im, 'rectangle', bbox, 'Face');
            imshow(hello);
            drawnow limitrate;  % Keep GUI responsive
        catch ME
            disp(['Frame processing error: ' ME.message]);
        end
    end
    
catch ME
    errordlg(['Face detection error: ' ME.message], 'Error');
end

% --- Executes on button press in stop.
function stop_Callback(hObject, eventdata, handles)
try
    handles.running = false;
    guidata(hObject, handles);
    
    if isfield(handles, 'vid') && isvalid(handles.vid)
        stop(handles.vid);
        delete(handles.vid);
    end
    
    % Display blank image
    axes(handles.axes1);
    try
        imshow('blank.jpg');
    catch
        imshow(zeros(480, 640, 3, 'uint8'));
    end
    
catch ME
    errordlg(['Error stopping camera: ' ME.message], 'Error');
end

% --- Executes on button press in eyes.
function eyes_Callback(hObject, eventdata, handles)
try
    if ~isfield(handles, 'vid') || ~isvalid(handles.vid)
        errordlg('Please initialize the camera first', 'Error');
        return;
    end
    
    % Stop any existing detection
    handles.running = false;
    pause(0.1);
    
    % Start new detection
    handles.running = true;
    guidata(hObject, handles);
    
    % Configure eye detector
    bodyDetector = vision.CascadeObjectDetector('EyePairBig');
    bodyDetector.MinSize = [11 45];
    start(handles.vid);
    
    while handles.running && isvalid(handles.vid)
        try
            trigger(handles.vid);
            handles.im = getdata(handles.vid, 1);
            bbox = step(bodyDetector, handles.im);
            hello = insertObjectAnnotation(handles.im, 'rectangle', bbox, 'EYE');
            imshow(hello);
            drawnow limitrate;
        catch ME
            disp(['Frame processing error: ' ME.message]);
        end
    end
    
catch ME
    errordlg(['Eye detection error: ' ME.message], 'Error');
end

% --- Executes on button press in upperbody.
function upperbody_Callback(hObject, eventdata, handles)
try
    if ~isfield(handles, 'vid') || ~isvalid(handles.vid)
        errordlg('Please initialize the camera first', 'Error');
        return;
    end
    
    % Stop any existing detection
    handles.running = false;
    pause(0.1);
    
    % Start new detection
    handles.running = true;
    guidata(hObject, handles);
    
    % Configure upper body detector
    bodyDetector = vision.CascadeObjectDetector('UpperBody');
    bodyDetector.MinSize = [60 60];
    bodyDetector.ScaleFactor = 1.05;
    start(handles.vid);
    
    while handles.running && isvalid(handles.vid)
        try
            trigger(handles.vid);
            handles.im = getdata(handles.vid, 1);
            bbox = step(bodyDetector, handles.im);
            hello = insertObjectAnnotation(handles.im, 'rectangle', bbox, 'UpperBody');
            imshow(hello);
            drawnow limitrate;
        catch ME
            disp(['Frame processing error: ' ME.message]);
        end
    end
    
catch ME
    errordlg(['Upper body detection error: ' ME.message], 'Error');
end
