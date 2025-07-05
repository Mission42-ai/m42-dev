#!/bin/bash
# Logging utilities

log_info() {
    echo -e "${COLOR_BLUE}${EMOJI_INFO}${COLOR_RESET} $*"
}

log_success() {
    echo -e "${COLOR_GREEN}${EMOJI_SUCCESS}${COLOR_RESET} $*"
}

log_error() {
    echo -e "${COLOR_RED}${EMOJI_ERROR}${COLOR_RESET} $*" >&2
}

log_warning() {
    echo -e "${COLOR_YELLOW}${EMOJI_WARNING}${COLOR_RESET} $*"
}

log_debug() {
    if [[ "${M42_DEBUG:-false}" == "true" ]]; then
        echo -e "${COLOR_BLUE}[DEBUG]${COLOR_RESET} $*"
    fi
}

log_section() {
    echo ""
    echo -e "${COLOR_BLUE}=== $* ===${COLOR_RESET}"
    echo ""
}

log_subsection() {
    echo -e "${COLOR_YELLOW}--- $* ---${COLOR_RESET}"
}