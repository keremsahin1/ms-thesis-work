function varargout = OOLCC(varargin)
%OOLCC M-file for OOLCC.fig
%      OOLCC, by itself, creates a new OOLCC or raises the existing
%      singleton*.
%
%      H = OOLCC returns the handle to a new OOLCC or the handle to
%      the existing singleton*.
%
%      OOLCC('Property','Value',...) creates a new OOLCC using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to OOLCC_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      OOLCC('CALLBACK') and OOLCC('CALLBACK',hObject,...) call the
%      local function named CALLBACK in OOLCC.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help OOLCC

% Last Modified by GUIDE v2.5 14-Jan-2013 15:30:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @OOLCC_OpeningFcn, ...
                   'gui_OutputFcn',  @OOLCC_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before OOLCC is made visible.
function OOLCC_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for OOLCC
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes OOLCC wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = OOLCC_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function textBoxSRMQ_Callback(hObject, eventdata, handles)
% hObject    handle to textBoxSRMQ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textBoxSRMQ as text
%        str2double(get(hObject,'String')) returns contents of textBoxSRMQ as a double


% --- Executes during object creation, after setting all properties.
function textBoxSRMQ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textBoxSRMQ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function textBoxSRMDeltaCoefficient_Callback(hObject, eventdata, handles)
% hObject    handle to textBoxSRMDeltaCoefficient (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textBoxSRMDeltaCoefficient as text
%        str2double(get(hObject,'String')) returns contents of textBoxSRMDeltaCoefficient as a double


% --- Executes during object creation, after setting all properties.
function textBoxSRMDeltaCoefficient_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textBoxSRMDeltaCoefficient (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkBoxSRMSmoothingActive.
function checkBoxSRMSmoothingActive_Callback(hObject, eventdata, handles)
% hObject    handle to checkBoxSRMSmoothingActive (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkBoxSRMSmoothingActive


% --- Executes on selection change in comboBoxSRMSortingFunctionType.
function comboBoxSRMSortingFunctionType_Callback(hObject, eventdata, handles)
% hObject    handle to comboBoxSRMSortingFunctionType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns comboBoxSRMSortingFunctionType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from comboBoxSRMSortingFunctionType


% --- Executes during object creation, after setting all properties.
function comboBoxSRMSortingFunctionType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comboBoxSRMSortingFunctionType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in comboBoxSRMMergeThreshType.
function comboBoxSRMMergeThreshType_Callback(hObject, eventdata, handles)
% hObject    handle to comboBoxSRMMergeThreshType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns comboBoxSRMMergeThreshType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from comboBoxSRMMergeThreshType


% --- Executes during object creation, after setting all properties.
function comboBoxSRMMergeThreshType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comboBoxSRMMergeThreshType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editRegionMergingScaleThreshold1_Callback(hObject, eventdata, handles)
% hObject    handle to editRegionMergingScaleThreshold1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRegionMergingScaleThreshold1 as text
%        str2double(get(hObject,'String')) returns contents of editRegionMergingScaleThreshold1 as a double


% --- Executes during object creation, after setting all properties.
function editRegionMergingScaleThreshold1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRegionMergingScaleThreshold1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editRegionMergingSpectralWeight_Callback(hObject, eventdata, handles)
% hObject    handle to editRegionMergingSpectralWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRegionMergingSpectralWeight as text
%        str2double(get(hObject,'String')) returns contents of editRegionMergingSpectralWeight as a double


% --- Executes during object creation, after setting all properties.
function editRegionMergingSpectralWeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRegionMergingSpectralWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function textBoxRegionMergingECognitionWeightShape_Callback(hObject, eventdata, handles)
% hObject    handle to textBoxRegionMergingECognitionWeightShape (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textBoxRegionMergingECognitionWeightShape as text
%        str2double(get(hObject,'String')) returns contents of textBoxRegionMergingECognitionWeightShape as a double


% --- Executes during object creation, after setting all properties.
function textBoxRegionMergingECognitionWeightShape_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textBoxRegionMergingECognitionWeightShape (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editRegionMergingSmoothnessWeight_Callback(hObject, eventdata, handles)
% hObject    handle to editRegionMergingSmoothnessWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRegionMergingSmoothnessWeight as text
%        str2double(get(hObject,'String')) returns contents of editRegionMergingSmoothnessWeight as a double


% --- Executes during object creation, after setting all properties.
function editRegionMergingSmoothnessWeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRegionMergingSmoothnessWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function textBoxRegionMergingECognitionWeightCompactness_Callback(hObject, eventdata, handles)
% hObject    handle to textBoxRegionMergingECognitionWeightCompactness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textBoxRegionMergingECognitionWeightCompactness as text
%        str2double(get(hObject,'String')) returns contents of textBoxRegionMergingECognitionWeightCompactness as a double


% --- Executes during object creation, after setting all properties.
function textBoxRegionMergingECognitionWeightCompactness_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textBoxRegionMergingECognitionWeightCompactness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in comboBoxRegionMergingECognitionAlgoType.
function comboBoxRegionMergingECognitionAlgoType_Callback(hObject, eventdata, handles)
% hObject    handle to comboBoxRegionMergingECognitionAlgoType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns comboBoxRegionMergingECognitionAlgoType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from comboBoxRegionMergingECognitionAlgoType


% --- Executes during object creation, after setting all properties.
function comboBoxRegionMergingECognitionAlgoType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comboBoxRegionMergingECognitionAlgoType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonExperimentApply.
function pushbuttonExperimentApply_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonExperimentApply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

iInputImg = imread(get(handles.textBoxExperimentImageName,'String'));
fShowImage(iInputImg,'Input Image',true);

dPreFilteringOutput = applyPreFiltering(handles);

if get(handles.checkboxAutoManualSelection,'Value') == false
    % Multi-scale Segmentation
    dMSSIndex = get(handles.popupmenuMSSType,'Value');

    if dMSSIndex <= 3
        [dLabels,IsWatershedLineExist] = applyRegionMergingBasedMSS(handles,dPreFilteringOutput);
    else
        [dLabels,IsWatershedLineExist] = applyWaveletBasedMSS(handles,dPreFilteringOutput);
    end

    dSegCnt = max(dLabels(:));
    dSegmentedImg = fGetSegmentedImg(iInputImg,dLabels,IsWatershedLineExist);

    fShowImage(dSegmentedImg,['Segmented Image - Segment Count: ' num2str(dSegCnt)],true);
else    
    % H-Image
    isShowWatershedInputResult = get(handles.checkboxShowWatershedInputResult,'Value');
    dHImageWindowSize = fAutomaticSelectH_ImageWindowSize(iInputImg,dPreFilteringOutput);
    [dWatershedInput,dWatershedInputComputTime] = fGetHImg(dPreFilteringOutput,dHImageWindowSize);
    
    disp(['H-Image Optimum Window Size: ' num2str(dHImageWindowSize)]);
    fShowImage(dWatershedInput,'H-Image',isShowWatershedInputResult);
    
    % Watershed Application
    isShowWatershedResult = get(handles.checkboxShowWatershedResult,'Value');
    [dWSLabels,dWSSegCnt,dWatershedComputTime] = fVincentSoilleWatershed(dWatershedInput,8);
    
    % RM3 Application
    isShowMSSResult = get(handles.checkboxShowMSSResult,'Value');
    
    dOptimumRM1ScaleThreshold = fAutomaticSelectRM1ScaleThreshold(iInputImg,dWSLabels,dPreFilteringOutput);
    [dRM1Labels,dRM1SegCnt,dRM1ComputTime] = fRegionMerge1(iInputImg,dWSLabels,dOptimumRM1ScaleThreshold,1,0,true);
    
    dOptimumRM2ScaleThreshold = fAutomaticSelectRM2ScaleThreshold(iInputImg,dRM1Labels,dPreFilteringOutput);
    [dRM2Labels,dRM2SegCnt,dRM2ComputTime] = fRegionMerge2(iInputImg,dRM1Labels,dOptimumRM2ScaleThreshold,1,0,true);
    
    disp(['RM1 Scale Threshold: ' num2str(dOptimumRM1ScaleThreshold) ' - RM2 Scale Threshold: ' num2str(dOptimumRM2ScaleThreshold)]);
    dSegmentedImg = fGetSegmentedImg(iInputImg,dRM2Labels,true);
    fShowImage(dSegmentedImg,['Region Merged Img - Segment Count:' num2str(dRM2SegCnt)],isShowMSSResult);
end

function [dRMLabels,IsWatershedLineExist]  = applyRegionMergingBasedMSS(handles,dPreFilteringOutput)

iInputImg = imread(get(handles.textBoxExperimentImageName,'String'));

% Watershed Input

isShowWatershedInputResult = get(handles.checkboxShowWatershedInputResult,'Value');
contentsWatershedInputType=cellstr(get(handles.popupmenuWatershedInputType,'String'));
watershedInputType=contentsWatershedInputType{get(handles.popupmenuWatershedInputType,'Value')};

switch watershedInputType
    case 'H-Image'
        dHImageWindowSize = 1 + 2*get(handles.popupmenuHImageWindowSize,'Value');
        [dWatershedInput,dWatershedInputComputTime] = fGetHImg(dPreFilteringOutput,dHImageWindowSize);
    case 'MSGM'
        contentsMSGMFilterType=cellstr(get(handles.popupmenuMSGMFilterType,'String'));
        MSGMFilterType=contentsMSGMFilterType{get(handles.popupmenuMSGMFilterType,'Value')};
        [dWatershedInput,dWatershedInputComputTime] = fGetGradMagIm(dPreFilteringOutput,MSGMFilterType);
end
disp(['Watershed Input Generation Computation Time: ' num2str(dWatershedInputComputTime)]);
fShowImage(dWatershedInput,'Watershed Input',isShowWatershedInputResult);

% Watershed Type

isShowWatershedResult = get(handles.checkboxShowWatershedResult,'Value');
contentsWatershedType=cellstr(get(handles.popupmenuWatershedType,'String'));
watershedType=contentsWatershedType{get(handles.popupmenuWatershedType,'Value')};

switch watershedType
    case 'RF'
        IsWatershedLineExist = false;
        dRFRDT = (get(handles.popupmenuRFRDT,'Value') - 1)/100;
        contentsRFNeighborhood=cellstr(get(handles.popupmenuRFNeighborhood,'String'));
        dRFNeighborhood=str2double(contentsRFNeighborhood{get(handles.popupmenuRFNeighborhood,'Value')});
        [dWSLabels,dWSSegCnt,dWatershedComputTime] = fRainfallingWatershed(dWatershedInput,dRFRDT,dRFNeighborhood);
    case 'VS'
        IsWatershedLineExist = true;
        contentsVSNeighborhood=cellstr(get(handles.popupmenuVSNeighborhood,'String'));
        dVSNeighborhood=str2double(contentsVSNeighborhood{get(handles.popupmenuVSNeighborhood,'Value')});
        [dWSLabels,dWSSegCnt,dWatershedComputTime] = fVincentSoilleWatershed(dWatershedInput,dVSNeighborhood);
end
dSegmentedImg = fGetSegmentedImg(iInputImg,dWSLabels,IsWatershedLineExist);
dSimpleImg = fSimplifyImage(iInputImg,dWSLabels);

disp(['Watershed Computation Time: ' num2str(dWatershedComputTime)]);
fShowImage(dSegmentedImg,['Watershed Segmented Img - Segment Count:' num2str(dWSSegCnt)],isShowWatershedResult);
fShowImage(dSimpleImg,'Simplified Image After Watershed Segmentation ',isShowWatershedResult);

% Region Merging Type

isShowMSSResult = get(handles.checkboxShowMSSResult,'Value');
dMSSIndex = get(handles.popupmenuMSSType,'Value');

dRMScaleThresh1 = str2double(get(handles.editRegionMergingScaleThreshold1,'String'));
dRMScaleThresh2 = str2double(get(handles.editRegionMergingScaleThreshold2,'String'));
dRMSpectralWeight = str2double(get(handles.editRegionMergingSpectralWeight,'String'));
dRMSmoothnessWeight = str2double(get(handles.editRegionMergingSmoothnessWeight,'String'));

switch dMSSIndex
    case 1
        [dRMLabels,dRMSegCnt,dRMComputTime] = fRegionMerge1(iInputImg,dWSLabels,dRMScaleThresh1,dRMSpectralWeight,dRMSmoothnessWeight,IsWatershedLineExist);
    case 2
        [dRMLabels,dRMSegCnt,dRMComputTime] = fRegionMerge2(iInputImg,dWSLabels,dRMScaleThresh2,dRMSpectralWeight,dRMSmoothnessWeight,IsWatershedLineExist);
    case 3
        [dRMLabels,dRMSegCnt,dRMComputTime] = fRegionMerge_Proposed(iInputImg,dWSLabels,dRMScaleThresh1,dRMScaleThresh2,dRMSpectralWeight,dRMSmoothnessWeight,IsWatershedLineExist);
end
dSegmentedImg = fGetSegmentedImg(iInputImg,dRMLabels,IsWatershedLineExist);
dSimpleImg = fSimplifyImage(iInputImg,dRMLabels);

disp(['Region Merging Computation Time: ' num2str(dRMComputTime)]);
fShowImage(dSegmentedImg,['Region Merged Img - Segment Count:' num2str(dRMSegCnt)],isShowMSSResult);
fShowImage(dSimpleImg,'Simplified Image After Region Merging ',isShowMSSResult);

function [dProjectedLabels,IsWatershedLineExist] = applyWaveletBasedMSS(handles,dPreFilteringOutput)

isShowMSSResult = get(handles.checkboxShowMSSResult,'Value');

dMSSIndex = get(handles.popupmenuMSSType,'Value');
iInputImg = imread(get(handles.textBoxExperimentImageName,'String'));

dScaleLevel = str2double(get(handles.editWaveletScaleLevel,'String'));
contentsWatershedInputMethod = cellstr(get(handles.popupmenuWatershedInputType,'String'));
sWatershedInputMethod=contentsWatershedInputMethod{get(handles.popupmenuWatershedInputType,'Value')};

switch sWatershedInputMethod
    case 'H-Image'
        watershedInputParam = 1 + 2*get(handles.popupmenuHImageWindowSize,'Value');
    case 'MSGM'
        contentsMSGMFilterType=cellstr(get(handles.popupmenuMSGMFilterType,'String'));
        watershedInputParam=contentsMSGMFilterType{get(handles.popupmenuMSGMFilterType,'Value')};
end

switch dMSSIndex
    case 4 %Jung's
        IsWatershedLineExist = false;
        [dProjectedImg,dProjectedLabels,dWaveletMSSSegCnt,dWaveletMSSComputTime] = fProjectImByJung(dPreFilteringOutput,dScaleLevel,sWatershedInputMethod,watershedInputParam);
    case 5 %Kim&Kim's
        IsWatershedLineExist = true;
        [dProjectedImg,dProjectedLabels,dWaveletMSSSegCnt,dWaveletMSSComputTime] = fProjectImByKimKim(dPreFilteringOutput,dScaleLevel,sWatershedInputMethod,watershedInputParam);
end

dSegmentedImg = fGetSegmentedImg(iInputImg,dProjectedLabels,IsWatershedLineExist);
dSimpleImg = fSimplifyImage(iInputImg,dProjectedLabels);

disp(['Wavelet-based MSS Computation Time: ' num2str(dWaveletMSSComputTime)]);
fShowImage(dProjectedImg,'Projected Image',isShowMSSResult);
fShowImage(dSegmentedImg,['Wavelet based MSS - Segment Count:' num2str(dWaveletMSSSegCnt)],isShowMSSResult);
fShowImage(dSimpleImg,'Simplified Image After Projection',isShowMSSResult);

function dPreFilteringOutput = applyPreFiltering(handles)

iInputImg = imread(get(handles.textBoxExperimentImageName,'String'));
isShowPreFilteringResult = get(handles.checkboxShowPreFilteringResult,'Value');

% Pre-Filtering
if get(handles.checkboxAutoManualSelection,'Value') == false
    contentsPreFilteringType=cellstr(get(handles.popupmenuPreFilteringType,'String'));
    preFilteringType=contentsPreFilteringType{get(handles.popupmenuPreFilteringType,'Value')};

    switch preFilteringType
        case 'PGF'
            dPGFWindowSize = 1 + 2*get(handles.popupmenuPGFWindowSize,'Value');
            [dPreFilteringOutput,dPreFilteringComputTime] = fPeerGroupFiltering(iInputImg,dPGFWindowSize);
        case 'EPSF'
            dEPSFWindowSize = 1 + 2*get(handles.popupmenuEPSFWindowSize,'Value');
            dEPSFSmoothingFactor = str2double(get(handles.editEPSFSmoothingFactor,'String'));
            dEPSFIterationCount = str2double(get(handles.editEPSFIterationCount,'String'));
            [dPreFilteringOutput,dPreFilteringComputTime] = fEdgePreservedSmoothingFilter(iInputImg,dEPSFWindowSize,dEPSFSmoothingFactor,dEPSFIterationCount);
        case 'VMF'
            dVMFWindowSize = 1 + 2*get(handles.popupmenuVMFWindowSize,'Value');
            [dPreFilteringOutput,dPreFilteringComputTime] = fVectoralMedianFilter(iInputImg,dVMFWindowSize);
        case 'None'
            dPreFilteringOutput = double(iInputImg);
            dPreFilteringComputTime = 0;
    end
    disp(['Pre-Filtering Computation Time: ' num2str(dPreFilteringComputTime)]);
else
    dOptEPSFWinSize = fAutomaticSelectEPSFWindowSize(iInputImg);
    [dPreFilteringOutput,dPreFilteringComputTime] = fEdgePreservedSmoothingFilter(iInputImg,dOptEPSFWinSize,10,1);
    disp(['Optimum EPSF Window Size: ' num2str(dOptEPSFWinSize)]);
end

fShowImage(dPreFilteringOutput,'Filtering Result',isShowPreFilteringResult);

function textBoxExperimentImageName_Callback(hObject, eventdata, handles)
% hObject    handle to textBoxExperimentImageName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textBoxExperimentImageName as text
%        str2double(get(hObject,'String')) returns contents of textBoxExperimentImageName as a double


% --- Executes during object creation, after setting all properties.
function textBoxExperimentImageName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textBoxExperimentImageName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkBoxExperimentShowIntermediateSteps.
function checkBoxExperimentShowIntermediateSteps_Callback(hObject, eventdata, handles)
% hObject    handle to checkBoxExperimentShowIntermediateSteps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkBoxExperimentShowIntermediateSteps


% --- Executes on selection change in popupmenuPreFilteringType.
function popupmenuPreFilteringType_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuPreFilteringType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuPreFilteringType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuPreFilteringType


% --- Executes during object creation, after setting all properties.
function popupmenuPreFilteringType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuPreFilteringType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuWatershedInputType.
function popupmenuWatershedInputType_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuWatershedInputType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuWatershedInputType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuWatershedInputType


% --- Executes during object creation, after setting all properties.
function popupmenuWatershedInputType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuWatershedInputType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuWatershedType.
function popupmenuWatershedType_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuWatershedType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuWatershedType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuWatershedType


% --- Executes during object creation, after setting all properties.
function popupmenuWatershedType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuWatershedType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuMSSType.
function popupmenuMSSType_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuMSSType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuMSSType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuMSSType


% --- Executes during object creation, after setting all properties.
function popupmenuMSSType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuMSSType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in comboBoxMRAWaveletType.
function comboBoxMRAWaveletType_Callback(hObject, eventdata, handles)
% hObject    handle to comboBoxMRAWaveletType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns comboBoxMRAWaveletType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from comboBoxMRAWaveletType


% --- Executes during object creation, after setting all properties.
function comboBoxMRAWaveletType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comboBoxMRAWaveletType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editWaveletScaleLevel_Callback(hObject, eventdata, handles)
% hObject    handle to editWaveletScaleLevel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editWaveletScaleLevel as text
%        str2double(get(hObject,'String')) returns contents of editWaveletScaleLevel as a double


% --- Executes during object creation, after setting all properties.
function editWaveletScaleLevel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editWaveletScaleLevel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonCompareWatersheds.
function pushbuttonCompareWatersheds_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCompareWatersheds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sImageName = get(handles.textBoxExperimentImageName,'String');
boSaveFigures = get(handles.checkboxWatershedSaveFigures,'Value');

disp(['Image:' sImageName ' SaveFigures:' num2str(boSaveFigures)]);

[ dRFTotalResults, dVSTotalResults ] = fCompareWatersheds( sImageName, boSaveFigures );

set(handles.tableRFWatershed, 'Data', dRFTotalResults);
set(handles.tableVSWatershed, 'Data', dVSTotalResults);


% --- Executes on button press in checkboxWatershedSaveFigures.
function checkboxWatershedSaveFigures_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxWatershedSaveFigures (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxWatershedSaveFigures


% --- Executes on selection change in popupmenu21.
function popupmenu21_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu21 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu21


% --- Executes during object creation, after setting all properties.
function popupmenu21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkBoxGLCMAngle0.
function checkBoxGLCMAngle0_Callback(hObject, eventdata, handles)
% hObject    handle to checkBoxGLCMAngle0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkBoxGLCMAngle0


% --- Executes on button press in checkBoxGLCMAngle45.
function checkBoxGLCMAngle45_Callback(hObject, eventdata, handles)
% hObject    handle to checkBoxGLCMAngle45 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkBoxGLCMAngle45


% --- Executes on button press in checkBoxGLCMAngle90.
function checkBoxGLCMAngle90_Callback(hObject, eventdata, handles)
% hObject    handle to checkBoxGLCMAngle90 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkBoxGLCMAngle90


% --- Executes on button press in checkBoxGLCMAngle135.
function checkBoxGLCMAngle135_Callback(hObject, eventdata, handles)
% hObject    handle to checkBoxGLCMAngle135 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkBoxGLCMAngle135



function textBoxGLCMDistance_Callback(hObject, eventdata, handles)
% hObject    handle to textBoxGLCMDistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textBoxGLCMDistance as text
%        str2double(get(hObject,'String')) returns contents of textBoxGLCMDistance as a double


% --- Executes during object creation, after setting all properties.
function textBoxGLCMDistance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textBoxGLCMDistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in comboBoxGLCMWindowSize.
function comboBoxGLCMWindowSize_Callback(hObject, eventdata, handles)
% hObject    handle to comboBoxGLCMWindowSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns comboBoxGLCMWindowSize contents as cell array
%        contents{get(hObject,'Value')} returns selected item from comboBoxGLCMWindowSize


% --- Executes during object creation, after setting all properties.
function comboBoxGLCMWindowSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comboBoxGLCMWindowSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in comboBoxGLCMTextureMeasure.
function comboBoxGLCMTextureMeasure_Callback(hObject, eventdata, handles)
% hObject    handle to comboBoxGLCMTextureMeasure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns comboBoxGLCMTextureMeasure contents as cell array
%        contents{get(hObject,'Value')} returns selected item from comboBoxGLCMTextureMeasure


% --- Executes during object creation, after setting all properties.
function comboBoxGLCMTextureMeasure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comboBoxGLCMTextureMeasure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function textBoxGLCMGrayLevelNumber_Callback(hObject, eventdata, handles)
% hObject    handle to textBoxGLCMGrayLevelNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textBoxGLCMGrayLevelNumber as text
%        str2double(get(hObject,'String')) returns contents of textBoxGLCMGrayLevelNumber as a double


% --- Executes during object creation, after setting all properties.
function textBoxGLCMGrayLevelNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textBoxGLCMGrayLevelNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuMSGMFilterType.
function popupmenuMSGMFilterType_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuMSGMFilterType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuMSGMFilterType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuMSGMFilterType


% --- Executes during object creation, after setting all properties.
function popupmenuMSGMFilterType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuMSGMFilterType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function tableRFWatershed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tableRFWatershed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes when entered data in editable cell(s) in tableRFWatershed.
function tableRFWatershed_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to tableRFWatershed (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when selected cell(s) is changed in tableRFWatershed.
function tableRFWatershed_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to tableRFWatershed (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popupmenuVMFWindowSize.
function popupmenuVMFWindowSize_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuVMFWindowSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuVMFWindowSize contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuVMFWindowSize


% --- Executes during object creation, after setting all properties.
function popupmenuVMFWindowSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuVMFWindowSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuEPSFWindowSize.
function popupmenuEPSFWindowSize_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuEPSFWindowSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuEPSFWindowSize contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuEPSFWindowSize


% --- Executes during object creation, after setting all properties.
function popupmenuEPSFWindowSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuEPSFWindowSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editEPSFSmoothingFactor_Callback(hObject, eventdata, handles)
% hObject    handle to editEPSFSmoothingFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editEPSFSmoothingFactor as text
%        str2double(get(hObject,'String')) returns contents of editEPSFSmoothingFactor as a double


% --- Executes during object creation, after setting all properties.
function editEPSFSmoothingFactor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editEPSFSmoothingFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editEPSFIterationCount_Callback(hObject, eventdata, handles)
% hObject    handle to editEPSFIterationCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editEPSFIterationCount as text
%        str2double(get(hObject,'String')) returns contents of editEPSFIterationCount as a double


% --- Executes during object creation, after setting all properties.
function editEPSFIterationCount_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editEPSFIterationCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuPGFWindowSize.
function popupmenuPGFWindowSize_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuPGFWindowSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuPGFWindowSize contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuPGFWindowSize


% --- Executes during object creation, after setting all properties.
function popupmenuPGFWindowSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuPGFWindowSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu25.
function popupmenu25_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu25 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu25


% --- Executes during object creation, after setting all properties.
function popupmenu25_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxShowPreFilteringResult.
function checkboxShowPreFilteringResult_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxShowPreFilteringResult (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxShowPreFilteringResult


% --- Executes on selection change in popupmenuHImageWindowSize.
function popupmenuHImageWindowSize_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuHImageWindowSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuHImageWindowSize contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuHImageWindowSize


% --- Executes during object creation, after setting all properties.
function popupmenuHImageWindowSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuHImageWindowSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxShowWatershedInputResult.
function checkboxShowWatershedInputResult_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxShowWatershedInputResult (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxShowWatershedInputResult


% --- Executes on selection change in popupmenuVSNeighborhood.
function popupmenuVSNeighborhood_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuVSNeighborhood (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuVSNeighborhood contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuVSNeighborhood


% --- Executes during object creation, after setting all properties.
function popupmenuVSNeighborhood_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuVSNeighborhood (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in popupmenuRFRDT.
function popupmenuRFRDT_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuRFRDT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function popupmenuRFRDT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuRFRDT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in popupmenuRFNeighborhood.
function popupmenuRFNeighborhood_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuRFNeighborhood (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuRFNeighborhood contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuRFNeighborhood


% --- Executes during object creation, after setting all properties.
function popupmenuRFNeighborhood_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuRFNeighborhood (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuRFRDT.
function popupmenu31_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuRFRDT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuRFRDT contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuRFRDT


% --- Executes during object creation, after setting all properties.
function popupmenu31_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuRFRDT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxShowWatershedResult.
function checkboxShowWatershedResult_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxShowWatershedResult (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxShowWatershedResult



function editRegionMergingScaleThreshold2_Callback(hObject, eventdata, handles)
% hObject    handle to editRegionMergingScaleThreshold2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRegionMergingScaleThreshold2 as text
%        str2double(get(hObject,'String')) returns contents of editRegionMergingScaleThreshold2 as a double


% --- Executes during object creation, after setting all properties.
function editRegionMergingScaleThreshold2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRegionMergingScaleThreshold2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxShowMSSResult.
function checkboxShowMSSResult_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxShowMSSResult (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxShowMSSResult



function editClusterCount_Callback(hObject, eventdata, handles)
% hObject    handle to editClusterCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editClusterCount as text
%        str2double(get(hObject,'String')) returns contents of editClusterCount as a double


% --- Executes during object creation, after setting all properties.
function editClusterCount_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editClusterCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonCompareWatershed.
function pushbuttonCompareWatershed_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCompareWatershed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

isShowComparisonImages = get(handles.checkboxShowComparisonImages,'Value');
iInputImg = imread(get(handles.editComparisonOrigImg,'String'));
iGTImg = imread(get(handles.editComparisonGTImg,'String'));

fWatershedComparison(iInputImg,iGTImg,isShowComparisonImages);


function editComparisonOrigImg_Callback(hObject, eventdata, handles)
% hObject    handle to editComparisonOrigImg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editComparisonOrigImg as text
%        str2double(get(hObject,'String')) returns contents of editComparisonOrigImg as a double


% --- Executes during object creation, after setting all properties.
function editComparisonOrigImg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editComparisonOrigImg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editComparisonGTImg_Callback(hObject, eventdata, handles)
% hObject    handle to editComparisonGTImg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editComparisonGTImg as text
%        str2double(get(hObject,'String')) returns contents of editComparisonGTImg as a double


% --- Executes during object creation, after setting all properties.
function editComparisonGTImg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editComparisonGTImg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxShowComparisonImages.
function checkboxShowComparisonImages_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxShowComparisonImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxShowComparisonImages


% --- Executes on button press in pushbuttonComparePreFiltering.
function pushbuttonComparePreFiltering_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonComparePreFiltering (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

isShowComparisonImages = get(handles.checkboxShowComparisonImages,'Value');
iInputImg = imread(get(handles.editComparisonOrigImg,'String'));
iGTImg = imread(get(handles.editComparisonGTImg,'String'));

fComparePreFilters(iInputImg,iGTImg,isShowComparisonImages);


% --- Executes on selection change in popupmenuComparisonEPSFWindowSize.
function popupmenuComparisonEPSFWindowSize_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuComparisonEPSFWindowSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuComparisonEPSFWindowSize contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuComparisonEPSFWindowSize


% --- Executes during object creation, after setting all properties.
function popupmenuComparisonEPSFWindowSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuComparisonEPSFWindowSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuComparisonHImageWindowSize.
function popupmenuComparisonHImageWindowSize_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuComparisonHImageWindowSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuComparisonHImageWindowSize contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuComparisonHImageWindowSize


% --- Executes during object creation, after setting all properties.
function popupmenuComparisonHImageWindowSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuComparisonHImageWindowSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

isShowComparisonImages = get(handles.checkboxShowComparisonImages,'Value');
dEPSFWindowSize = 1 + 2*get(handles.popupmenuComparisonEPSFWindowSize,'Value');
iInputImg = imread(get(handles.editComparisonOrigImg,'String'));
iGTImg = imread(get(handles.editComparisonGTImg,'String'));

fCompareWatershedInputs(iInputImg,iGTImg,dEPSFWindowSize,isShowComparisonImages);


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

isShowComparisonImages = get(handles.checkboxShowComparisonImages,'Value');
dEPSFWindowSize = 1 + 2*get(handles.popupmenuComparisonEPSFWindowSize,'Value');
dHImageWindowSize = 1 + 2*get(handles.popupmenuComparisonHImageWindowSize,'Value');
iInputImg = imread(get(handles.editComparisonOrigImg,'String'));
iGTImg = imread(get(handles.editComparisonGTImg,'String'));

fCompareWaveletBasedMSS(iInputImg,iGTImg,dEPSFWindowSize,dHImageWindowSize,isShowComparisonImages);


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

isShowComparisonImages = get(handles.checkboxShowComparisonImages,'Value');
dEPSFWindowSize = 1 + 2*get(handles.popupmenuComparisonEPSFWindowSize,'Value');
dHImageWindowSize = 1 + 2*get(handles.popupmenuComparisonHImageWindowSize,'Value');
dScaleStep1 = str2double(get(handles.editComparisonScaleStep1,'String'));
dScaleStep2 = str2double(get(handles.editComparisonScaleStep2,'String'));
iInputImg = imread(get(handles.editComparisonOrigImg,'String'));
iGTImg = imread(get(handles.editComparisonGTImg,'String'));

fCompareRegionMergingBasedMSS(iInputImg,iGTImg,dEPSFWindowSize,dHImageWindowSize,dScaleStep1,dScaleStep2,isShowComparisonImages);

% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function editComparisonScaleStep1_Callback(hObject, eventdata, handles)
% hObject    handle to editComparisonScaleStep1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editComparisonScaleStep1 as text
%        str2double(get(hObject,'String')) returns contents of editComparisonScaleStep1 as a double


% --- Executes during object creation, after setting all properties.
function editComparisonScaleStep1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editComparisonScaleStep1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editComparisonScaleStep2_Callback(hObject, eventdata, handles)
% hObject    handle to editComparisonScaleStep2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editComparisonScaleStep2 as text
%        str2double(get(hObject,'String')) returns contents of editComparisonScaleStep2 as a double


% --- Executes during object creation, after setting all properties.
function editComparisonScaleStep2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editComparisonScaleStep2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxAutoManualSelection.
function checkboxAutoManualSelection_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxAutoManualSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxAutoManualSelection

if get(hObject,'Value') == false
    set(handles.popupmenuPGFWindowSize,'Enable','on');
    set(handles.popupmenuEPSFWindowSize,'Enable','on');
    set(handles.editEPSFSmoothingFactor,'Enable','on');
    set(handles.editEPSFIterationCount,'Enable','on');
    set(handles.popupmenuVMFWindowSize,'Enable','on');
    set(handles.popupmenuMSGMFilterType,'Enable','on');
    set(handles.popupmenuHImageWindowSize,'Enable','on');
    set(handles.editRegionMergingScaleThreshold1,'Enable','on');
    set(handles.editRegionMergingScaleThreshold2,'Enable','on');
    set(handles.editRegionMergingSpectralWeight,'Enable','on');
    set(handles.editRegionMergingSmoothnessWeight,'Enable','on');
    set(handles.editWaveletScaleLevel,'Enable','on');
    set(handles.popupmenuRFRDT,'Enable','on');
    set(handles.popupmenuRFNeighborhood,'Enable','on');
    set(handles.popupmenuVSNeighborhood,'Enable','on');
    set(handles.popupmenuPreFilteringType,'Enable','on');
    set(handles.popupmenuWatershedInputType,'Enable','on');
    set(handles.popupmenuWatershedType,'Enable','on');
    set(handles.popupmenuMSSType,'Enable','on');
else
    set(handles.popupmenuPGFWindowSize,'Enable','off');
    set(handles.popupmenuEPSFWindowSize,'Enable','off');
    set(handles.editEPSFSmoothingFactor,'Enable','off');
    set(handles.editEPSFIterationCount,'Enable','off');
    set(handles.popupmenuVMFWindowSize,'Enable','off');
    set(handles.popupmenuMSGMFilterType,'Enable','off');
    set(handles.popupmenuHImageWindowSize,'Enable','off');
    set(handles.editRegionMergingScaleThreshold1,'Enable','off');
    set(handles.editRegionMergingScaleThreshold2,'Enable','off');
    set(handles.editRegionMergingSpectralWeight,'Enable','off');
    set(handles.editRegionMergingSmoothnessWeight,'Enable','off');
    set(handles.editWaveletScaleLevel,'Enable','off');
    set(handles.popupmenuRFRDT,'Enable','off');
    set(handles.popupmenuRFNeighborhood,'Enable','off');
    set(handles.popupmenuVSNeighborhood,'Enable','off');
    set(handles.popupmenuPreFilteringType,'Enable','off');
    set(handles.popupmenuWatershedInputType,'Enable','off');
    set(handles.popupmenuWatershedType,'Enable','off');
    set(handles.popupmenuMSSType,'Enable','off');
end
