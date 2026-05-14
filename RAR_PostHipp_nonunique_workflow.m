function RAR_PostHipp_nonunique_workflow (Patient_List_ExcelFile, MNI_Recruited_Channels_ExcelFile)

	posterior_cutoff = -22;

	[recruited_channels, patient_list] = RAR_PostHipp_import (Patient_List_ExcelFile, MNI_Recruited_Channels_ExcelFile);
	patients_recruited_hippocampal_Y = RAR_PostHipp_extract_hipp_Y (recruited_channels);
	concat_hipp_Y = RAR_PostHipp_concat_Y (patients_recruited_hippocampal_Y);

	is_posterior_hippocampal_Y = {};
	posterior_index = {};

	% iterates through each patient
	for k = 1:numel(concat_hipp_Y(:,1))
	
		is_posterior_hippocampal_Y{k,1} = concat_hipp_Y{k,1};
		is_posterior_hippocampal_Y{k,2} = (concat_hipp_Y{k,2} < posterior_cutoff);

		posterior_index{k,1} = concat_hipp_Y{k,1};

		num_posterior = nnz(is_posterior_hippocampal_Y{k,2});
		num_recruited = length(is_posterior_hippocampal_Y{k,2});
		posterior_index{k,2} = (num_posterior / num_recruited);

	end

	filestem = MNI_Recruited_Channels_ExcelFile(1:end-5);

	concat_filename = strcat(filestem, "_concat_recruited_hippocampal_Y.csv");
	isposterior_filename = strcat(filestem, "_isposterior_recruited_hippocampal_Y.csv");
	post_index_filename = strcat(filestem, "_post_index_hippocampal_Y.csv");

	writecell(concat_hipp_Y, concat_filename);
	writecell(is_posterior_hippocampal_Y, isposterior_filename);
	writecell(posterior_index, post_index_filename);

end


function [recruited_channels, patient_list] = RAR_PostHipp_import (Patient_List_ExcelFile, MNI_Recruited_Channels_ExcelFile)

	patient_list = readtable(Patient_List_ExcelFile, 'VariableNamingRule','preserve', ReadRowNames=true);

	recruited_channels_sheets = sheetnames(MNI_Recruited_Channels_ExcelFile);
	recruited_channels = {};
	for i=1:numel(recruited_channels_sheets)
  		this_sheet = readtable(MNI_Recruited_Channels_ExcelFile,'Sheet',recruited_channels_sheets(i),'VariableNamingRule','preserve');
		this_sheet_cell = {recruited_channels_sheets(i), this_sheet(:,1:15)};
		recruited_channels{i} = this_sheet_cell;
	end

end

function patients_recruited_hippocampal_Y = RAR_PostHipp_extract_hipp_Y (recruited_channels)

	% initiates cell array
	patients_recruited_hippocampal_Y = {};

	% iterates through the individual "sheets" of recruited_channels
	for i=1:numel(recruited_channels)

		% initiate arrays
		sz_recruited_hipp_Y = [];
		patient_recruited_hipp_Y = [];
		patient_entry = [];

		% extracts the sheet from the cell array and parses the patient and seizure from the sheet name
		sheet_cell = recruited_channels{i};
		identifier = string(sheet_cell(1));
		table = sheet_cell{2};
		identifier_parts = split(identifier,"-");
		patient = identifier_parts(1);

		% iterates through each row of the current sheet and extracts MNI Y from any channel containing "Hippocampus" or "x"
		for j = 1:numel(table.sorting);
			localization_string = string(table.Localization(j));
			hcx_subloc_string = string(table{j,"HCx Subloc"});
			if (contains(localization_string, "Hippocampus") || contains(hcx_subloc_string, "x"))
				Y = table.Var14(j);
				sz_recruited_hipp_Y = [sz_recruited_hipp_Y, Y];
			end
		end

		patient_entry = {patient, sz_recruited_hipp_Y};
		patients_recruited_hippocampal_Y = [patients_recruited_hippocampal_Y;patient_entry];

	end

end

function concat_hipp_Y = RAR_PostHipp_concat_Y (patients_recruited_hippocampal_Y)

	concat_hipp_Y = {};
	last_patient = "";

	for n = 1:numel(patients_recruited_hippocampal_Y(:,1))

		current_patient = string(patients_recruited_hippocampal_Y{n,1});
		current_Y = patients_recruited_hippocampal_Y{n,2};

		if current_patient ~= last_patient
			concat_hipp_Y = [concat_hipp_Y;{current_patient, current_Y}];

		elseif current_patient == last_patient
			concat_hipp_Y{end,2} = [concat_hipp_Y{end,2},current_Y];

		end	

		last_patient = current_patient;

	end

end