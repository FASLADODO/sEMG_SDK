function AR_rc_CEP_feature_CheckCallback(source, eventdata)
	handles = guidata(source);

	if get(handles.Check_Feature_AR_rc_CEP, 'Value')
		handles.Cell_Feature_SelectedName{end+1} = 'Feature_AR_rc_CEP';
	else
		handles.Cell_Feature_SelectedName( ...
			find( strcmp(handles.Cell_Feature_SelectedName, ...
			'Feature_AR_rc_CEP')) ) ...
		= [];
	end
	%Update handles.
	guidata(source, handles);