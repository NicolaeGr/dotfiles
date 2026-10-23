# ht: {{ name }}

set -g status-style "bg={{ background }},fg={{ foreground }}"
set -g status-left "#[fg={{ background }},bg={{ accent }},bold] #S #[bg={{ background }},fg={{ foreground }}] "
set -g status-right "#[fg={{ accent }}]#{?pane_in_mode,COPY ,}#{?client_prefix,PREFIX ,}#{?window_zoomed_flag,ZOOM ,}#[fg={{ light_foreground }}]#h "
set -g window-status-format "#[fg={{ muted }}] #I:#W "
set -g window-status-current-format "#[fg={{ accent }},bold] #I:#W "
set -g pane-border-style "fg={{ muted }}"
set -g pane-active-border-style "fg={{ accent }}"
set -g message-style "bg={{ background }},fg={{ accent }}"
set -g message-command-style "bg={{ background }},fg={{ accent }}"
set -g mode-style "bg={{ accent }},fg={{ background }}"
setw -g clock-mode-colour "{{ cyan }}"
