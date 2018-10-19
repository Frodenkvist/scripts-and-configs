#!/usr/bin/env bash

JIRA_HOME="$HOME/.jira"
FETCH_PROJECTS="$JIRA_HOME/FETCH_PROJECTS"
FETCH_SPRINTS="$JIRA_HOME/FETCH_SPRINTS"
FETCH_BOARDS="$JIRA_HOME/FETCH_BOARDS"
FETCH_ISSUES="$JIRA_HOME/FETCH_ISSUES"

olderThanMinutes() {
    local MATCHES
    local FIND_EXIT_CODE

    if [[ -z "$FIND_COMAND" ]]; then
        if command -v gfin > /dev/null; then
            FIND_COMMAND=gfind
        else
            FIND_COMMAND=find
        fi
    fi
    
    MATCHES=$("$FIND_COMMAND" "$1" -mmin +"$2" 2> /dev/null)
    FIND_EXIT_CODE=$?
    if [[ -n "$MATCHES" ]]; then
        return 0
    else
        return 1
    fi
}

get_projects() {
    if [[ -e "$FETCH_PROJECTS\.tmp" && -s "$FETCH_PROJECTS\.tmp" ]]; then
        mv "$FETCH_PROJECTS\.tmp" "$FETCH_PROJECTS"
    fi

    if [[ ! -e "$FETCH_PROJECTS" ]] || olderThanMinutes "$FETCH_PROJECTS" "10" ; then
        touch "$FETCH_PROJECTS"
        cat "$FETCH_PROJECTS"

        # Extract the project list in the background and cache it
        ((jira project ls | tail -n +3 | sed -n 's,.*\(^│.*│ \).*,\1,p' | sed 's/.\{1\}$//' | sed -n 's,.*\(^│.*│ \).*,\1,p' | sed 's,│,,g' | sed 's, ,,g' | sed ':a;N;$!ba;s/\n/ /g') </dev/null > "$FETCH_PROJECTS\.tmp" 2>/dev/null & disown -h)
        return
    fi

    cat "$FETCH_PROJECTS"
}

get_sprints() {
    local boards

    if [[ -e "$FETCH_BOARDS\.tmp" && -s "$FETCH_BOARDS\.tmp" ]]; then
        mv "$FETCH_BOARDS\.tmp" "$FETCH_BOARDS"
    fi

    if [[ ! -e "$FETCH_BOARDS" ]] || olderThanMinutes "$FETCH_BOARDS" "10" ; then
        touch "$FETCH_BOARDS"
        boards=$(cat "$FETCH_BOARDS")
        # Extract the project list in the background and cache it
        ((jira board ls | tail -n +3 | sed -n 's,.*\(^│.*│ \).*,\1,p' | sed 's/.\{1\}$//' | sed -n 's,.*\(^│.*│ \).*,\1,p' | sed 's,│,,g' | sed 's, ,,g' | sed ':a;N;$!ba;s/\n/ /g') </dev/null > "$FETCH_BOARDS\.tmp" 2>/dev/null & disown -h)
    else
        boards=$(cat "$FETCH_BOARDS")
    fi

    if [[ -e "$FETCH_SPRINTS\.tmp" && -s "$FETCH_SPRINTS\.tmp" ]]; then
        mv "$FETCH_SPRINTS\.tmp" "$FETCH_SPRINTS"
    fi

    if [[ ! -e "$FETCH_SPRINTS" ]] || olderThanMinutes "$FETCH_SPRINTS" "10" ; then
        touch "$FETCH_SPRINTS"
        cat "$FETCH_SPRINTS" | sed ':a;N;$!ba;s/\n/ /g'
        
        # Extract the sprint list in the background and cache it
        for board_id in $boards; do
            ((jira sprint ls -b $board_id | tail -n +3 | sed -n 's,.*\(^│.*│ \).*,\1,p' | sed 's/.\{1\}$//' | sed 's,│,,g' | sed 's, ,,g' | sed ':a;N;$!ba;s/\n/ /g') </dev/null >> "$FETCH_SPRINTS\.tmp" 2>/dev/null & disown -h)
        done
        return
    fi

    cat "$FETCH_SPRINTS" | sed ':a;N;$!ba;s/\n/ /g'
}

get_issues() {
    if [[ -e "$FETCH_ISSUES\.tmp" && -s "$FETCH_ISSUES\.tmp" ]]; then
        mv "$FETCH_ISSUES\.tmp" "$FETCH_ISSUES"
    fi

    if [[ ! -e "$FETCH_ISSUES" ]] || olderThanMinutes "$FETCH_ISSUES" "1" ; then
        touch "$FETCH_ISSUES"
        cat "$FETCH_ISSUES"

        # Extract the project list in the background and cache it
        ((jira issue ls -a ALL -s OPEN | tail -n +3 | sed -n 's,.*\(^│.*│ \).*,\1,p' | sed 's/.\{1\}$//' | sed 's,│,,g' | sed 's, ,,g' | sed ':a;N;$!ba;s/\n/ /g') </dev/null > "$FETCH_ISSUES\.tmp" 2>/dev/null & disown -h)
    else
        cat "$FETCH_ISSUES"
    fi
}

_project_completions() {
    local projects

    if [ ! -d "$JIRA_HOME" ]; then
        mkdir "$JIRA_HOME"
    fi

    projects=$(get_projects)
    
    COMPREPLY=($(compgen -W "help ls $projects" "${COMP_WORDS[2]}"))
}

_board_completions() {
    COMPREPLY=($(compgen -W "help ls backlog" "${COMP_WORDS[2]}"))
}

_sprint_completions() {
    local sprints

    if [ ! -d "$JIRA_HOME" ]; then
        mkdir "$JIRA_HOME"
    fi
    
    sprints=$(get_sprints)

    COMPREPLY=($(compgen -W "help ls active $sprints" "${COMP_WORDS[2]}"))
}

_issue_completions() {
    local issues

    if [ ! -d "$JIRA_HOME" ]; then
        mkdir "$JIRA_HOME"
    fi
    
    issues=$(get_issues)

    COMPREPLY=($(compgen -W "help ls jql search assign attach_file comment edit_comment delete edit new open url take trans $issues" "${COMP_WORDS[2]}"))
}

_issue_id_completion() {
    local issues

    if [ ! -d "$JIRA_HOME" ]; then
        mkdir "$JIRA_HOME"
    fi

    issues=$(get_issues)

    COMPREPLY=($(compgen -W "$issues" "${COMP_WORDS[3]}"))
}

_jira_completions() {
    if [ "${#COMP_WORDS[@]}" == "2" ]; then
        COMPREPLY=($(compgen -W "login logout project board sprint issue" "${COMP_WORDS[1]}"))
    elif [ "${#COMP_WORDS[@]}" == "3" ]; then
        case "${COMP_WORDS[1]}" in
            project)
                _project_completions
                ;;
            board)
                _board_completions
                ;;
            sprint)
                _sprint_completions
                ;;
            issue)
                _issue_completions
                ;;
        esac
    elif [ "${#COMP_WORDS[@]}" == "4" ]; then
        if [ "${COMP_WORDS[1]}" == "issue" ]; then
            case "${COMP_WORDS[2]}" in
                assign|attach_file|comment|edit_comment|delete|edit|open|url|take|trans)
                    _issue_id_completion
                    ;; 
            esac
        fi 
    fi


}

complete -F _jira_completions jira

