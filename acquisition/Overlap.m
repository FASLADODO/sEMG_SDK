function data_type = Overlap(data_type, width, data)
	if (size(data_type, 1) < width)
		data_type = [data_type; ...
					 data];
	else
		data_type = [data_type(size(data, 1)+1: ...
			         size(data_type,1)); ...
					 data];
	end	