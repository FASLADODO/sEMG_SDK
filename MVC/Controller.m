classdef Controller < handle
	properties
		viewObj
		modelObj

		% pictures changing
		nthPicture = 1
		hTimerPictures
		hPicturesStack = {'Snooze', ...
						  'Grasp', ...
						  'Snooze', ...
						  'Open', ...
						  'Snooze', ...
						  'Index'}
		RawData = []
		% dimensions: (2000*t) X nCh
	end

	methods
		function obj = Controller(viewObj0, modelObj0)
			obj.viewObj = viewObj0;
			obj.modelObj = modelObj0;
			obj.hTimerPictures = timer('Period', 3, ...
									   'ExecutionMode', 'fixedSpacing', ...
									   'TasksToExecute', length(obj.hPicturesStack)+1, ...
									   'TimerFcn', {@obj.TimerFcn_PicturesChanging});	
		end

		% --Callback of widgets in View
		function Callback_ButtonStart(obj, source, eventdata)
			tic
			disp('Start Button was pressed...');
			start(obj.hTimerPictures);
			obj.viewObj.flagEMGWrite2Files = 1; % --allow to write the EMG signal to files
		end

		function Callback_ButtonAnalyze(obj, source, eventdata)
			disp('Analyze Button was pressed...');
			obj.modelObj.Stop(); disp('Hardware Connection Stop.');
			obj.viewObj.flagEMGWrite2Files = 0;  % --stop writing to files...
			disp('Stop Writing data to files...');
			delete(obj.hTimerPictures);

			% enlarge the axes for better SplitLines
			set(obj.viewObj.hPanelEMG, 'Position', [0 0 1 1]);
			set(obj.viewObj.hButtonStart, 'Visible', 'off');
			set(obj.viewObj.hButtonAnalyze, 'Visible', 'off');
			% split lines
			set(obj.viewObj.hTextSplitLines, 'Visible', 'on');
			set(obj.viewObj.hEditSplitLines, 'Visible', 'on');
			set(obj.viewObj.hButtonSplitLines, 'Visible', 'on');
			% load acquired data & shown in View Axes
			for ch=1:length(obj.viewObj.hChannels)
				data_file = load([obj.viewObj.folder_name, '\EMG', ...
								'\Channel', num2str(obj.viewObj.hChannels(ch)), '.txt']);
				obj.RawData= [obj.RawData, data_file];
				plot(obj.viewObj.hAxesEMG(ch), data_file);
				XTick = 0:1000:length(data_file);
				set(obj.viewObj.hAxesEMG(ch), 'XTick', XTick)
			end
		end

		function Callback_EditSplitLines(obj, source, eventdata)
			hEditInputs = get(obj.viewObj.hEditSplitLines, 'String');
			hEditInputsCell = strsplit(hEditInputs);
			obj.viewObj.xSplitLines = [];
			for i=1:length(hEditInputsCell)
				obj.viewObj.xSplitLines = [obj.viewObj.xSplitLines; ...
										   str2num(hEditInputsCell{i})*1000];
			end

			% --==draw split vertical lines in the axes.
			% clear historical lines
			delete(obj.viewObj.hSplitLines);
			obj.viewObj.hSplitLines = [];
			for ch=1:length(obj.viewObj.hChannels)
				YLim = get(obj.viewObj.hAxesEMG(ch), 'YLim');
				for xn=1:length(obj.viewObj.xSplitLines)
					obj.viewObj.hSplitLines= [obj.viewObj.hSplitLines, ...
											 line([obj.viewObj.xSplitLines(xn), obj.viewObj.xSplitLines(xn)], ...
												  [YLim(1), YLim(2)], ...
						 						  'Parent', obj.viewObj.hAxesEMG(ch)) ];
				end
			end
			% --splitting positions are stored in obj.viewObj.xSplitLines, 
			% --a column vector.
		end

		function Callback_ButtonSplitLines(obj, source, eventdata)
			% Split Raw sEMG signal and store in Movements-corresponding files.
			xColumn2 = [obj.viewObj.xSplitLines; size(obj.RawData, 1)];
			xColumn1 = [0; xColumn2(1:end-1)];
			% --inward contraction
			xColumn1 = xColumn1 + 1000; % - every 2000samples a second
			xColumn2 = xColumn2 - 1000; % - every 2000samples a second
			xSplitLinesPaires = [xColumn1, xColumn2];

			disp('Writing data to name-dependent files.');
			totalStack = {};
			for mp=1:(size(xSplitLinesPaires,1)/length(obj.hPicturesStack))
				totalStack = cat(2, totalStack, obj.hPicturesStack);
			end
			for xn=1:size(xSplitLinesPaires, 1)
				nameMovement = totalStack{xn}

				a = xSplitLinesPaires(xn, 1);
				b = xSplitLinesPaires(xn, 2);
				data_mv = obj.RawData(a:b, :);
				dlmwrite([obj.viewObj.folder_name, '\EMG\', nameMovement, '.txt'], data_mv, '-append');
			end
		end

		function Callback_ButtonOnlineControl(obj, source, eventdata)
			% features extraction

			% modelling

			% training data accuracy computation

			% [listdlg] or [questdlg] to 
				% 1. show trainingset accuracy
				% 2. show testingset accuracy
				% 3. go on to online-control or not
				% 4. select a control objects
					% 1. pictures showing
					% 2. iLimb
					% 3. KangfuHand
					% 4. VirtualHand
		end
		function TimerFcn_PicturesChanging(obj, source, eventdata)
			% the End pictures?
			if( obj.nthPicture == (length(obj.hPicturesStack)+1) )
				obj.nthPicture = 1;
				obj.viewObj.flagEMGWrite2Files = 0; % --stop writing to files.
				
				hPicture = imread(['End', '.jpg']);
				imshow(hPicture, 'Parent', obj.viewObj.hAxesPictureBed);
				drawnow;
			else
				namePicture = obj.hPicturesStack{obj.nthPicture};
				hPicture = imread([namePicture, '.jpg']);
				imshow(hPicture, 'Parent', obj.viewObj.hAxesPictureBed);
				drawnow;
				toc
				obj.nthPicture = obj.nthPicture + 1;
			end
			

		end
	end
end