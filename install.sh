#!/bin/bash
# HEX666 v1.2.1 Installer
# by: Deley Selem

set -e

VERSION="1.2.1"                                                                  
SCRIPT_NAME="hex666.py"
COMMAND_NAME="hex666"
LIB_NAME="libhex64hash.so"
C_SOURCE="hex64hash.c"
MAN_PAGE="hex666.1"

# Termux specific configuration
if [ -d "/data/data/com.termux/files/usr" ]; then
    BIN_PATH="/data/data/com.termux/files/usr/bin"
    LIB_PATH="/data/data/com.termux/files/usr/lib"
    MAN_PATH="/data/data/com.termux/files/usr/share/man/man1"
    TERMUX=true
    # Use Termux's tmp directory to avoid read-only issues
    TMP_DIR="/data/data/com.termux/files/usr/tmp"
    mkdir -p "$TMP_DIR"
else
    # Linux configuration
    if [ "$(id -u)" -ne 0 ] && [ "$1" != "--user" ]; then
        echo "Please run as root or use: ./install.sh --user"
        exit 1
    fi
    BIN_PATH="/usr/local/bin"
    LIB_PATH="/usr/lib"
    MAN_PATH="/usr/share/man/man1"
    TMP_DIR="/tmp"
fi

# User installation mode
if [ "$1" = "--user" ]; then
    if [ -d "$HOME/.local/bin" ]; then
        BIN_PATH="$HOME/.local/bin"
        LIB_PATH="$HOME/.local/lib"
        MAN_PATH="$HOME/.local/share/man/man1"
    else                                                                                 mkdir -p "$HOME/.local/bin" "$HOME/.local/lib" "$HOME/.local/share/man/man1"
        BIN_PATH="$HOME/.local/bin"
        LIB_PATH="$HOME/.local/lib"
        MAN_PATH="$HOME/.local/share/man/man1"
    fi
    echo "Installing to user directory: $BIN_PATH"
fi

# Create necessary directories
mkdir -p "$BIN_PATH" "$LIB_PATH" "$MAN_PATH" "$TMP_DIR"

# Installation options
echo
echo "┌──────────────────────────────────────────────────┐"
echo "│              HEX666 v1.2.1 Installer             │"
echo "│                by: Deley Selem                   │"
echo "├──────────────────────────────────────────────────┤"
echo "│ Choose installation version:                     │"
echo "│                                                  │"
echo "│ 1) Pure Python Version (Recommended)             │"
echo "│    - No dependencies, works everywhere           │"
echo "│    - Full feature set including mass encryption  │"
echo "│                                                  │"
echo "│ 2) C-Optimized Version (For Developers)          │"
echo "│    - 3-5x faster hashing performance             │"
echo "│    - Allows low-level C modifications            │"
echo "└──────────────────────────────────────────────────┘"
echo

read -p "Select version [1/2]: " choice
echo

case $choice in
    1)
        echo "Installing Pure Python Version..."
        INSTALL_TYPE="python"
        ;;
    2)
        echo "Installing C-Optimized Version..."
        INSTALL_TYPE="c"
        ;;
    *)
        echo "Invalid selection. Installation canceled."
        exit 1
        ;;
esac

# Verify required files
[ ! -f "$SCRIPT_NAME" ] && echo "Error: $SCRIPT_NAME missing!" && exit 1

if [ "$INSTALL_TYPE" = "c" ]; then
    [ ! -f "$C_SOURCE" ] && echo "Error: $C_SOURCE missing!" && exit 1
fi

# Install Python script
echo "Installing HEX666 command..."
cp "$SCRIPT_NAME" "$BIN_PATH/$COMMAND_NAME"
chmod 755 "$BIN_PATH/$COMMAND_NAME"

# Add shebang if missing
if ! head -1 "$BIN_PATH/$COMMAND_NAME" | grep -q python3; then
    sed -i '1i#!/usr/bin/env python3' "$BIN_PATH/$COMMAND_NAME"
fi

# C-Optimized installation for all environments
if [ "$INSTALL_TYPE" = "c" ]; then
    # Check for build tools in Termux
    if [ "$TERMUX" = true ]; then
        if ! command -v gcc &> /dev/null; then
            echo "Installing required build tools for Termux..."
            pkg update
            pkg install -y clang binutils
        fi
    else
        if ! command -v gcc &> /dev/null; then
            echo "Error: gcc not found. Install with:"
            echo "  Debian/Ubuntu: sudo apt install build-essential"
            echo "  RedHat/Fedora: sudo dnf install gcc"
            exit 1
        fi
    fi

    echo "Compiling optimized C library..."
    gcc -shared -fPIC -o "$TMP_DIR/$LIB_NAME" "$C_SOURCE"

    echo "Installing C library..."
    install -m 644 "$TMP_DIR/$LIB_NAME" "$LIB_PATH/"

    # Configure library path
    if [ -z "$TERMUX" ]; then
        echo "Updating library cache..."
        ldconfig
    fi

    # Cleanup temporary build files
    rm -f "$TMP_DIR/$LIB_NAME"
fi

# Create compatibility symlink
ln -sf "$BIN_PATH/$COMMAND_NAME" "$BIN_PATH/hex64"

# Install man page
echo "Installing documentation..."
cat > "$TMP_DIR/$MAN_PAGE" << 'EOM'
.TH HEX666 1 "2023-08-15" "v1.2.1" "HEX666 Manual"
.SH NAME
hex666 \- I Ching-based secure file encoder
.SH SYNOPSIS
.B hex666
[\fIOPTIONS\fR]...
.SH DESCRIPTION
HEX666 transforms files using I Ching hexagrams and military-grade encryption. Developed by Deley Selem, it combines ancient symbolism with modern cryptography.
.SH OPTIONS
.TP
\fB-f, --file FILE\fR
Encode specified file
.TP
\fB-d, --decode FILE\fR
Decode specified file
.TP
\fB-p, --pass PHRASE\fR
Encryption passphrase (required for security)
.TP
\fB-x, --iter NUM\fR
Seed iterations (default: 1, increase for security)
.TP
\fB-666, --hex666\fR
Encrypt ALL files in current directory (overwrite)
.TP
\fB--unhex666\fR
Decrypt ALL files in current directory (overwrite)
.TP
\fB-rp, --run-py FILE\fR
Run encoded Python script from memory
.TP
\fB-rb, --run-sh FILE\fR
Run encoded Bash script from memory
.TP
\fB-v, --verbose\fR
Show detailed processing information
.TP
\fB-h, --help\fR
Show this help message
.SH EXAMPLES
Encode file with passphrase:
.B hex666 -f secret.txt -p "Passphrase123!" -x 100
.br
Mass encrypt current directory:
.B hex666 --hex666 -p "StrongPass#2023" -x 500
.br
Run encoded script:
.B hex666 -rp encoded_script.hex64 -p "RuntimePass!"
.SH AUTHOR
Deley Selem <deley@hex666.security>
.SH "SEE ALSO"
gpg(1), openssl(1), sha256sum(1)
EOM

install -m 644 "$TMP_DIR/$MAN_PAGE" "$MAN_PATH/"
rm -f "$TMP_DIR/$MAN_PAGE"

# Update man database if available
if command -v mandb &> /dev/null; then
    mandb -q
fi

echo
echo "┌──────────────────────────────────────────────────┐"
echo "│      HEX666 v1.2.1 Installation Complete!        │"
echo "├──────────────────────────────────────────────────┤"
echo "│  Run:                                            │"
echo "│    hex666 --help    # Show usage                 │"
echo "│    man hex666       # View manual                │"
echo "│                                                  │"
if [ "$INSTALL_TYPE" = "c" ]; then
echo "│  C-accelerated version installed                 │"
else
echo "│  Pure Python version installed                   │"
fi
if [ "$TERMUX" = true ]; then
echo "│  Termux environment detected                     │"
fi
echo "└──────────────────────────────────────────────────┘"
echo
