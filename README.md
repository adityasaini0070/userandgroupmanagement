# Linux User & Group Management System 🐧

A powerful, interactive bash script for comprehensive Linux user and group management with database logging and authentication features. Built for system administrators to streamline user lifecycle management operations.

## ✨ Features

### User Management
- 👤 **Add User** - Create new system users with home directories
- 🗑️ **Delete User** - Remove users and their home directories
- 🔒 **Lock User** - Disable user accounts without deletion
- 🔓 **Unlock User** - Re-enable locked user accounts
- 📊 **Show User Details** - Display comprehensive user information (UID, GID, groups)
- 🔐 **User Authentication** - Validate user credentials with password verification

### Group Management
- 👥 **Add Group** - Create new system groups
- 🗑️ **Delete Group** - Remove existing groups
- ➕ **Add User to Group** - Assign users to groups
- ➖ **Remove User from Group** - Revoke group memberships
- 🔄 **Grant Cross-Group Access** - Enable users to access multiple group resources

### Security & Authentication
- 🔑 **Password Expiry Check** - Validate password expiration status
- 🛡️ **User Authentication** - Secure login verification before system access
- ⏰ **Expiry Alerts** - Automatic detection of expired passwords
- 🔐 **Input Validation** - Sanitize user inputs to prevent injection attacks

### Logging & Audit
- 📝 **File Logging** - All actions logged to `usermgmt.log`
- 💾 **MySQL Database Logging** - Persistent audit trail in MySQL database
- ⏱️ **Timestamped Entries** - Every action recorded with precise timestamps
- 📊 **Audit Trail** - Complete history of user and group modifications

### User Interface
- 🎨 **Interactive Dialog Menus** - User-friendly TUI (Text User Interface)
- 🖥️ **Banner Display** - Professional ASCII art banners
- ✅ **Input Validation** - Real-time validation with error messages
- 🔄 **Menu Navigation** - Easy-to-use numbered menu system

## 🛠️ Tech Stack

- **Bash Scripting** - Core scripting language
- **Dialog** - Terminal-based UI toolkit
- **MySQL** - Database for audit logging
- **Linux System Commands** - `useradd`, `userdel`, `groupadd`, `groupdel`, `usermod`, `passwd`, `chage`
- **Banner** - ASCII art text generator

## 📋 Prerequisites

- Linux operating system (Ubuntu, Debian, CentOS, RHEL, etc.)
- Root or sudo privileges
- MySQL/MariaDB server installed
- Required packages:
  ```bash
  sudo apt-get install dialog mysql-server banner
  # or for RHEL/CentOS
  sudo yum install dialog mariadb-server banner




##Screenshota

<img width="1447" height="647" alt="image" src="https://github.com/user-attachments/assets/bd8d9347-a6d5-4c74-a6e9-afa5624d6f6b" />
