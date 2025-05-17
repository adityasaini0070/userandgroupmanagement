#!/bin/bash
clear
banner "usermgmt"
sleep 2
# CONFIGURATION
LOGFILE="./usermgmt.log"
DB_USER="aditya"
DB_PASS="aditya"
DB_NAME="usermgmt"
DB_TABLE="log"
DB_HOST="localhost"

# FUNCTIONS
log_action() {
    echo "$(date): $1" >> "$LOGFILE"
}

log_to_mysql() {
    local action="$1"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    mysql -u aditya -paditya -D usermgmt -e \
    "INSERT INTO log (action, timestamp) VALUES ('$action', '$timestamp');" \
    2>>mysql_error.log
}


authenticate_user() {
    username=$(get_input "Enter your username:")
    sudo chage -l "$username" &>/dev/null || { dialog --msgbox "User does not exist!" 6 40; return 1; }

    dialog --insecure --passwordbox "Enter your password:" 8 40 2>temp_pass
    password=$(<temp_pass)
    rm -f temp_pass

    echo "$password" | sudo -S -u "$username" echo "Authenticated" &>/dev/null
    if [[ $? -ne 0 ]]; then
        dialog --msgbox "Authentication failed!" 6 40
        return 1
    fi

    expiry=$(sudo chage -l "$username" | grep "Password expires" | cut -d: -f2 | xargs)
    if [[ "$expiry" == "never" ]]; then
        dialog --msgbox "Password is valid and does not expire." 6 50
    else
        exp_date=$(date -d "$expiry" +%s)
        now=$(date +%s)
        if (( now > exp_date )); then
            dialog --msgbox "Password has expired!" 6 40
            log_action "Password expired for $username"
            log_to_mysql "PASSWORD_EXPIRED $username"
        else
            dialog --msgbox "Password is valid and not expired." 6 50
        fi
    fi
    log_action "Authenticated user $username"
    log_to_mysql "AUTHENTICATE_USER $username"
    return 0
}

validate_name() {
    [[ -z "$1" || "$1" =~ [^a-zA-Z0-9] ]] && dialog --msgbox "Invalid input. Only letters and numbers allowed." 7 40 && return 1
    return 0
}

get_input() {
    local title="$1"
    local result
    result=$(dialog --inputbox "$title" 8 40 3>&1 1>&2 2>&3)
    echo "$result"
}

add_user() {
    username=$(get_input "Enter new username:")
    validate_name "$username" || return

    if id "$username" &>/dev/null; then
        dialog --msgbox "User already exists!" 6 40
        return
    fi

    sudo useradd -m "$username"
    dialog --msgbox "User '$username' added." 6 40
    log_action "Added user $username"
    log_to_mysql "ADD_USER $username"
}

delete_user() {
    username=$(get_input "Enter username to delete:")
    validate_name "$username" || return

    if ! id "$username" &>/dev/null; then
        dialog --msgbox "User does not exist!" 6 40
        return
    fi

    sudo userdel -r "$username"
    dialog --msgbox "User '$username' deleted." 6 40
    log_action "Deleted user $username"
    log_to_mysql "DELETE_USER $username"
}

add_group() {
    groupname=$(get_input "Enter new group name:")
    validate_name "$groupname" || return

    if getent group "$groupname" &>/dev/null; then
        dialog --msgbox "Group already exists!" 6 40
        return
    fi

    sudo groupadd "$groupname"
    dialog --msgbox "Group '$groupname' added." 6 40
    log_action "Added group $groupname"
    log_to_mysql "ADD_GROUP $groupname"
}

delete_group() {
    groupname=$(get_input "Enter group name to delete:")
    validate_name "$groupname" || return

    if ! getent group "$groupname" &>/dev/null; then
        dialog --msgbox "Group does not exist!" 6 40
        return
    fi

    sudo groupdel "$groupname"
    dialog --msgbox "Group '$groupname' deleted." 6 40
    log_action "Deleted group $groupname"
    log_to_mysql "DELETE_GROUP $groupname"
}

add_user_to_group() {
    username=$(get_input "Enter username:")
    groupname=$(get_input "Enter group to add user to:")
    validate_name "$username" || return
    validate_name "$groupname" || return

    if ! id "$username" &>/dev/null || ! getent group "$groupname" &>/dev/null; then
        dialog --msgbox "User or group doesn't exist!" 6 40
        return
    fi

    sudo usermod -aG "$groupname" "$username"
    dialog --msgbox "Added '$username' to group '$groupname'." 6 40
    log_action "Added $username to group $groupname"
    log_to_mysql "ADD_USER_TO_GROUP $username to $groupname"
}

remove_user_from_group() {
    username=$(get_input "Enter username:")
    groupname=$(get_input "Enter group to remove user from:")
    validate_name "$username" || return
    validate_name "$groupname" || return

    if ! id "$username" &>/dev/null || ! getent group "$groupname" &>/dev/null; then
        dialog --msgbox "User or group doesn't exist!" 6 40
        return
    fi

    sudo gpasswd -d "$username" "$groupname"
    dialog --msgbox "Removed '$username' from group '$groupname'." 6 40
    log_action "Removed $username from group $groupname"
    log_to_mysql "REMOVE_USER_FROM_GROUP $username from $groupname"
}

lock_user() {
    username=$(get_input "Enter username to lock:")
    validate_name "$username" || return

    sudo passwd -l "$username"
    dialog --msgbox "User '$username' locked." 6 40
    log_action "Locked user $username"
    log_to_mysql "LOCK_USER $username"
}

unlock_user() {
    username=$(get_input "Enter username to unlock:")
    validate_name "$username" || return

    sudo passwd -u "$username"
    dialog --msgbox "User '$username' unlocked." 6 40
    log_action "Unlocked user $username"
    log_to_mysql "UNLOCK_USER $username"
}

show_user_details() {
    username=$(get_input "Enter username to show details:")
    validate_name "$username" || return

    if id "$username" &>/dev/null; then
        details=$(id "$username")
        dialog --msgbox "User Info:\n$details" 10 50
        log_action "Viewed details for $username"
        log_to_mysql "SHOW_USER_DETAILS $username"
    else
        dialog --msgbox "User does not exist!" 6 40
    fi
}

grant_cross_group_access() {
    username=$(get_input "Enter username:")
    groupname=$(get_input "Enter group to add user to:")
    validate_name "$username" || return
    validate_name "$groupname" || return

    if ! id "$username" &>/dev/null || ! getent group "$groupname" &>/dev/null; then
        dialog --msgbox "User or group doesn't exist!" 6 40
        return
    fi

    sudo usermod -aG "$groupname" "$username"
    dialog --msgbox "Granted access: '$username' -> '$groupname'" 6 50
    log_action "Granted $username access to group $groupname"
    log_to_mysql "GRANT_CROSS_GROUP_ACCESS $username to $groupname"
}

# MAIN MENU
clear
banner "User & Group Management Project"
authenticate_user || exit 1

while true; do
    choice=$(dialog --clear --backtitle "Linux User & Group Manager" \
        --title "Main Menu" \
        --menu "Choose an action:" 20 60 13 \
        1 "Add User" \
        2 "Delete User" \
        3 "Add Group" \
        4 "Delete Group" \
        5 "Add User to Group" \
        6 "Remove User from Group" \
        7 "Lock User" \
        8 "Unlock User" \
        9 "Show User Details" \
        10 "Grant Cross-Group Access" \
        11 "Authenticate & Check Password Expiry" \
        12 "Exit" \
        3>&1 1>&2 2>&3)

    case "$choice" in
        1) add_user ;;
        2) delete_user ;;
        3) add_group ;;
        4) delete_group ;;
        5) add_user_to_group ;;
        6) remove_user_from_group ;;
        7) lock_user ;;
        8) unlock_user ;;
        9) show_user_details ;;
        10) grant_cross_group_access ;;
        11) authenticate_user ;;
        12) break ;;
        *) dialog --msgbox "Invalid option!" 6 40 ;;
    esac

done

clear

