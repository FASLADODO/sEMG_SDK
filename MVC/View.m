classdef View < handle
	
	properties
		% -- basic parameters on device
		hChannels = [1 2];
		hPartSelection = {'Upper'}

		hFigure
		% --EMG
		hAxesEMG = []
		hPlotsEMG = []
		hPanelEMG

		% --guiding pictures to display
		% hPictureReady
		hAxesPictureBed
		nthPicture = 1
		hPicturesStack = {'Snooze', ...
						  'Grasp', ...
						  'Snooze', ...
						  'Open', ...
						  'End'};
		TimerPictures

		% --Buttons
		hButtonStart
		hButtonAnalyze

		modelObj
		controllerObj

		dataAxesEMG = []
	end
	methods
		% --Construct
		function obj = View(modelObj)
			% ===================basic & static figure displays=================
			addpath('..\MaxFigure');addpath('..\pictures');
			obj.hFigure = figure();maximize(obj.hFigure);
			obj.hPanelEMG = uipanel('Parent', obj.hFigure, ...
								  'Units', 'normalized', ...
								  'Position', [0 0 0.5 0.96]);
			% --hAxesEMG, hPlotsEMG
			% nChannels = length(obj.hChannels);
			nChannels = 2;
			dWidth= 0.95/nChannels;
			for ch=1:nChannels
				obj.hAxesEMG(ch) = axes('Parent', obj.hPanelEMG, ...
										'Units', 'normalized', ...
										'Position', [0.04 1- dWidth *ch, 0.98 dWidth*0.9]); 
				obj.hPlotsEMG(ch) = plot(obj.hPanelEMG, 0, '-y', 'LineWidth', 1);
				title(['Channel', num2str(ch)]);
			end

			% --hAxesPictureBed
			obj.hAxesPictureBed = axes('Parent', obj.hFigure, ...
									   'Units', 'normalized', ...
									   'Position', [0.51 0.45 0.48 0.5]);
			hPictureReady = imread('Ready.jpg');
			imshow(hPictureReady, 'Parent', obj.hAxesPictureBed);
			obj.TimerPictures = timer('Period', 2, ...
									  'ExecutionMode', 'fixedSpacing', ...
									  'TasksToExecute', length(obj.hPicturesStack), ...
									  'TimerFcn', {@TimerFcn_PicturesChanging, obj});
			start(obj.TimerPictures);
			%  --- part selection
			% namePartSelection = {'Body', 'Upper'};
			% hPopupPartSelection = uicontrol('Parent', obj.hFigure, ...
			% 								'Style', 'popupmenu', ...
			% 								'Units', 'normalized', ...
			% 								'Position', [0.52 0.4 0.04 0.02], ...
			% 								'String', namePartSelection);
			obj.hButtonStart = uicontrol('Parent', obj.hFigure, ...
									 	 'Style', 'pushbutton', ...
									 	 'Units', 'normalized', ...
									 	 'Position', [0.8 0.35 0.1 0.05], ...
									 	 'FontSize', 16, ...
									 	 'String', 'Start');
			obj.hButtonAnalyze = uicontrol('Parent', obj.hFigure, ...
										   'Style', 'pushbutton', ...
										   'Units', 'normalized', ...
										   'Position', [0.8 0.25 0.1 0.05], ...
										   'FontSize', 16, ...
										   'String', 'Analyze');
			% ===================basic & static figure displays=================
			% --===Model===--subscribe to the event
			obj.modelObj = modelObj;
			obj.modelObj.addlistener('dataEMGChanged', @obj.UpdateAxesEMG);
			obj.modelObj.addlistener('dataEMGChanged', @obj.Write2FilesEMG);

			% --===Controller===--controller to responde
			obj.controllerObj = obj.makeController(); % to new a Controller object

			% --register controller responde functions as view callback functions
			obj.attachToController(obj.controllerObj); 
		end
        % -- event [dataEMGChanged] responde function
        function UpdateAxesEMG(obj, source, event)
        	% disp('UpdateAxesEMG...');
        	if(length(obj.dataAxesEMG) < 32832)
        		obj.dataAxesEMG = [obj.dataAxesEMG; ...
        						   obj.modelObj.dataEMG];
        	else
        		obj.dataAxesEMG = [obj.dataAxesEMG(length(obj.modelObj.dataEMG)+1:end); ...
        						   obj.modelObj.dataEMG];
        	end
        	% --==seperate [obj.dataAxesEMG] into 16-Channel-Axes
        	for ch=1:length(obj.hPlotsEMG)
        		data_ch = obj.dataAxesEMG(ch:16:end);
        		% set(obj.hPlotsEMG(ch), 'Ydata', data_ch);
        		plot(obj.hAxesEMG(ch), data_ch);
        		drawnow;
        	end
        end
        % -- event [dataEMGChanged] responde function
        function Write2FilesEMG(obj, source, event)
        	% disp('Write2FilesEMG...');
        	% --==write [obj.modelObj.dataEMG] into txt file with appending format.
        end

        function controllerObj = makeController(obj)
        	controllerObj = [];
        end

        function attachToController(obj, controller)
        end

	end
end

% ---===local functions===---
function data = ReadTCPIPdata(interfaceObjects)

end

function TimerFcn_PicturesChanging(source, eventdata, object)
	namePicture = object.hPicturesStack{object.nthPicture}; % char
	hPicture = imread([namePicture, '.jpg']);
	imshow(hPicture, 'Parent', object.hAxesPictureBed);
	object.nthPicture = object.nthPicture + 1;
end