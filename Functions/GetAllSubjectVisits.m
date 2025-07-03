function subject_visit_tab = GetAllSubjectVisits(AudioTab)
% Get unique visit numbers and subject IDs
unique_visits = unique(AudioTab.VisitNum(~isnan(AudioTab.VisitNum)));
unique_subjects = unique(AudioTab.Subject(contains(AudioTab.Subject,'MVI')));
subject_visit_tab = nan(length(unique_subjects),length(unique_visits));

% Create a matrix of subject indices and visit numbers
subj_idx = zeros(size(AudioTab, 1), 1);
for i = 1:numel(unique_subjects)
    subj_idx(strcmp(AudioTab.Subject,unique_subjects(i))) = i;
end

% Loop through each subject
for i = 1:numel(unique_subjects)
    subject_idx = strcmp(AudioTab.Subject,unique_subjects(i));
    subject_visits = AudioTab.VisitNum(subject_idx);

    % Loop through each unique visit
    for j = 1:numel(unique_visits)
        if any(subject_visits == unique_visits(j))
            subject_visit_tab(i, j) = unique_visits(j);
        end
    end
end
end