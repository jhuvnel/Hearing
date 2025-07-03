function output_table = SelectSubjectVisits(AudioTab, substitutions, desired_visits)
    % substitutions: Nx3 array where each row is [subject_index, missing_visit, replacement_visit]
    % desired_visits: optional array/cell specifying which visits to analyze
    %                 e.g., [0, 3, 9], 'most recent', or {0, 'most recent'}
    
    if nargin < 2
        substitutions = [];
    end
    
    % Get all subject visits using your function
    subject_visit_tab = GetAllSubjectVisits(AudioTab);
    unique_subjects = unique(AudioTab.Subject(contains(AudioTab.Subject,'MVI')));
    unique_visits = unique(AudioTab.VisitNum(~isnan(AudioTab.VisitNum)));
    
    % Handle desired visits input
    if nargin < 3 || isempty(desired_visits)
        % Ask user which visits they want to see
        fprintf('Available visit numbers: %s\n', mat2str(unique_visits));
        fprintf('Options:\n');
        fprintf('  - Enter "most recent" for everyone''s most recent visit\n');
        fprintf('  - Enter visit numbers as array, e.g., [0, 3, 9, 10]\n');
        fprintf('  - Mix numbers and "most recent", e.g., [0, "most recent"]\n');
        
        user_input = input('Enter desired visits: ', 's');
        
        % Parse user input
        if strcmp(user_input, 'most recent')
            desired_visits = {'most recent'};
        else
            % Try to evaluate as array, handling mixed numeric and string
            try
                if contains(user_input, '"most recent"') || contains(user_input, '''most recent''')
                    % Handle mixed array with "most recent"
                    desired_visits = eval(user_input);
                else
                    % Pure numeric array
                    desired_visits = eval(user_input);
                end
            catch
                error('Invalid input format');
            end
        end
    else
        % Use provided desired_visits
        if ischar(desired_visits) && strcmp(desired_visits, 'most recent')
            desired_visits = {'most recent'};
        elseif isnumeric(desired_visits)
            % Keep as is - numeric array
        elseif iscell(desired_visits) || isstring(desired_visits)
            % Keep as is - mixed array
        else
            error('Invalid desired_visits format');
        end
    end
    
    % Convert desired visits to actual visit numbers for each subject
    num_subjects = length(unique_subjects);
    num_desired_visits = length(desired_visits);
    final_visits = nan(num_subjects, num_desired_visits);
    
    % Get max visit for each subject to determine which missing visits are "truly missing" vs "beyond max"
    max_visits_per_subject = nan(num_subjects, 1);
    for s = 1:num_subjects
        available_visits = subject_visit_tab(s, ~isnan(subject_visit_tab(s, :)));
        if ~isempty(available_visits)
            max_visits_per_subject(s) = max(available_visits);
        end
    end
    
    % Process each desired visit
    for v = 1:num_desired_visits
        if iscell(desired_visits)
            current_desired = desired_visits{v};  % Extract from cell
        else
            current_desired = desired_visits(v);  % Direct indexing for numeric array
        end
        
        if (ischar(current_desired) && strcmp(current_desired, 'most recent')) || ...
           (isstring(current_desired) && strcmp(current_desired, "most recent"))
            % Get most recent visit for each subject
            for s = 1:num_subjects
                available_visits = subject_visit_tab(s, ~isnan(subject_visit_tab(s, :)));
                if ~isempty(available_visits)
                    final_visits(s, v) = max(available_visits);
                end
            end
        else
            % Specific visit number requested
            visit_num = double(current_desired);
            visit_col = find(unique_visits == visit_num);
            if ~isempty(visit_col)
                final_visits(:, v) = subject_visit_tab(:, visit_col);
            end
            
            % For subjects where this visit is higher than their max visit, keep as NaN
            % (don't classify as "missing" for interactive replacement)
            for s = 1:num_subjects
                if ~isnan(max_visits_per_subject(s)) && visit_num > max_visits_per_subject(s)
                    final_visits(s, v) = NaN; % Explicitly set to NaN (already is, but for clarity)
                end
            end
        end
    end
    
    % Apply pre-specified substitutions
    if ~isempty(substitutions)
        for sub_idx = 1:size(substitutions, 1)
            subj_num = substitutions(sub_idx, 1);
            missing_visit = substitutions(sub_idx, 2);
            replacement_visit = substitutions(sub_idx, 3);
            
            % Find which column corresponds to the missing visit
            for v = 1:num_desired_visits
                if iscell(desired_visits)
                    current_desired = desired_visits{v};
                else
                    current_desired = desired_visits(v);
                end
                
                % Check if this column matches the missing visit we want to substitute
                if ~((ischar(current_desired) && strcmp(current_desired, 'most recent')) || ...
                     (isstring(current_desired) && strcmp(current_desired, "most recent"))) && ...
                   double(current_desired) == missing_visit
                    
                    % Check if this subject actually has missing data for this visit
                    if isnan(final_visits(subj_num, v))
                        % Verify the replacement visit is available for this subject
                        available_visits = subject_visit_tab(subj_num, ~isnan(subject_visit_tab(subj_num, :)));
                        if ismember(replacement_visit, available_visits)
                            final_visits(subj_num, v) = replacement_visit;
                            fprintf('Applied substitution: Subject %d, Visit %g -> Visit %g\n', ...
                                    subj_num, missing_visit, replacement_visit);
                        else
                            fprintf('Warning: Subject %d does not have visit %g available for substitution\n', ...
                                    subj_num, replacement_visit);
                        end
                    end
                end
            end
        end
    end
    
    % Find subjects with missing visits and ask for replacements 
    % (excluding visits that are beyond their max visit number)
    for v = 1:num_desired_visits
        if iscell(desired_visits)
            current_desired = desired_visits{v};
        else
            current_desired = desired_visits(v);
        end
        
        % Skip "most recent" since it can't be missing
        if (ischar(current_desired) && strcmp(current_desired, 'most recent')) || ...
           (isstring(current_desired) && strcmp(current_desired, "most recent"))
            continue;
        end
        
        visit_num = double(current_desired);
        missing_subjects = find(isnan(final_visits(:, v)));
        
        % Filter out subjects where this visit is beyond their max visit
        truly_missing_subjects = [];
        for s = missing_subjects'
            if ~isnan(max_visits_per_subject(s)) && visit_num <= max_visits_per_subject(s)
                truly_missing_subjects = [truly_missing_subjects, s];
            end
        end
        
        for s = truly_missing_subjects
            fprintf('\nSubject %s (index %d) is missing visit %g (max visit: %g)\n', ...
                    unique_subjects{s}, s, visit_num, max_visits_per_subject(s));
            
            % Show available visits for this subject
            available_visits = subject_visit_tab(s, ~isnan(subject_visit_tab(s, :)));
            if isempty(available_visits)
                fprintf('No visits available for this subject.\n');
                continue;
            end
            
            fprintf('Available visits for %s: %s\n', unique_subjects{s}, ...
                    mat2str(available_visits));
            fprintf('Enter visit number to use as replacement, or press Enter for NaN: ');
            
            choice = input('', 's');
            
            if ~isempty(choice)
                choice_num = str2double(choice);
                if ~isnan(choice_num) && ismember(choice_num, available_visits)
                    final_visits(s, v) = choice_num;
                else
                    fprintf('Invalid visit number. Leaving as NaN.\n');
                end
            end
            % If empty input, leave as NaN
        end
    end
    
    % Create output table
    visit_names = cell(1, num_desired_visits);
    for v = 1:num_desired_visits
        if iscell(desired_visits)
            current_desired = desired_visits{v};
        else
            current_desired = desired_visits(v);
        end
        
        if (ischar(current_desired) && strcmp(current_desired, 'most recent')) || ...
           (isstring(current_desired) && strcmp(current_desired, "most recent"))
            visit_names{v} = 'MostRecent';
        else
            visit_names{v} = sprintf('Visit_%g', current_desired);
        end
    end
    
    % Create table with subjects as rows and desired visits as columns
    output_table = array2table(final_visits, 'RowNames', unique_subjects, ...
                              'VariableNames', visit_names);
    
    fprintf('\nFinal visit selection:\n');
    disp(output_table);
end