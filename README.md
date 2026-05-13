# ExtUp - Extension Upload Tester 🚀

[![Bash](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Security](https://img.shields.io/badge/Security-Pentesting-red)](https://github.com/topics/pentesting)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

**ExtUp** is an automated tool for testing file extensions in vulnerable upload systems. It helps identify which extensions are accepted, whether the file is actually saved on the server, and whether PHP code is executed through a webshell.

![ExtUp Logo](https://via.placeholder.com/800x200?text=ExtUp+Logo)

## 📋 About

ExtUp was created to support security professionals during authorized penetration tests, CTFs, and lab environments. It automates the process of fuzzing file extensions in upload forms and provides a clear, organized report.

### 🎯 Features

- ✅ Automatically tests multiple extensions
- ✅ Checks whether the file was actually saved
- ✅ Tests PHP code execution through a webshell
- ✅ Supports custom wordlists compatible with SecLists
- ✅ Automatically detects the upload directory
- ✅ Colorized and organized output
- ✅ Generates logs and timestamped reports
- ✅ Lightweight and fast: Bash + curl only

## 🔧 Installation

```bash
# Clone the repository
git clone https://github.com/your-username/extup.git
cd extup

# Grant execution permission
chmod +x extup.sh

# Optional: install SecLists for the default wordlist
sudo apt install seclists -y
```

## 📖 Usage

### Basic syntax

```bash
./extup.sh -u <UPLOADER_URL>
```

### Parameters

| Parameter | Description | Required |
|---|---|---|
| `-u` | URL of the upload script, for example: `http://target.com/upload.php` | ✅ Yes |
| `-w` | Path to the extension wordlist | ❌ No, uses the default wordlist |
| `-b` | Base URL where files are saved | ❌ No, attempts auto-detection |
| `-h` | Shows help | ❌ No |

### Practical examples

```bash
# 1. Basic test using the default wordlist
./extup.sh -u http://192.168.9.117/internal/index.php

# 2. Using a custom wordlist
./extup.sh -u http://target.com/upload.php -w /tmp/my_list.txt

# 3. Specifying the upload directory
./extup.sh -u http://target.com/upload.php -b http://target.com/uploads/

# 4. Using a SecLists wordlist
./extup.sh -u http://target.com/index.php -w /usr/share/seclists/Fuzzing/extensions-most-common.txt
```

## 📊 Output example

```text
███████╗██╗  ██╗████████╗██╗   ██╗██████╗ 
██╔════╝╚██╗██╔╝╚══██╔══╝██║   ██║██╔══██╗
█████╗   ╚███╔╝    ██║   ██║   ██║██████╔╝
██╔══╝   ██╔██╗    ██║   ██║   ██║██╔═══╝ 
███████╗██╔╝ ██╗   ██║   ╚██████╔╝██║     
╚══════╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝     
           Extension Upload Tester v1.0

[+] Target URL: http://192.168.9.117/internal/index.php
[+] Wordlist: /usr/share/seclists/Fuzzing/extensions-most-common.txt
[+] Base URL: http://192.168.9.117/internal/uploads/
===========================================================
[*] Testing .php ... ❌ BLOCKED
[*] Testing .phtml ... ✅ UPLOAD OK ✅ PHP EXECUTES! (VALID)
[*] Testing .php5 ... ❌ BLOCKED
===========================================================
[+] Test completed!
[+] Total tested: 45
[+] Accepted uploads: 1
[+] Extensions with PHP execution: 1

[+] Working extensions (upload + PHP execution):
.phtml
```

## 📁 Generated files

| File | Description |
|---|---|
| `valid_extensions_YYYYMMDD_HHMMSS.txt` | Extensions that worked: upload + code execution |
| `upload_only_extensions_YYYYMMDD_HHMMSS.txt` | Accepted extensions without PHP execution |
| `test_upload_YYYYMMDD_HHMMSS.log` | Full test log |

## 🛠️ Recommended wordlists

- SecLists: `/usr/share/seclists/Fuzzing/extensions-most-common.txt`
- Common extensions: `php phtml php3 php4 php5 php7 phps phtm asp aspx jsp`
- Custom wordlist: create your own list with target-specific extensions

## ⚠️ Legal disclaimer

**WARNING:** This tool is designed **ONLY** for:

- Authorized penetration testing
- CTF environments
- Personal labs or environments with explicit permission

Unauthorized use against systems you do not own or do not have permission to test is **illegal**. The author is not responsible for misuse.

## 🐛 Common issues

### Wordlist not found

```bash
# Install SecLists
sudo apt install seclists -y

# Or use a manual wordlist
./extup.sh -u URL -w /your/list.txt
```

### File does not appear in directory listing

- The script automatically tries multiple paths.
- Check whether directory listing is enabled.
- Use `-b` to specify the correct path manually.

## 🤝 Contributing

Contributions are welcome. To contribute:

1. Fork the project.
2. Create your branch: `git checkout -b feature/AmazingFeature`.
3. Commit your changes: `git commit -m 'Add some AmazingFeature'`.
4. Push to the branch: `git push origin feature/AmazingFeature`.
5. Open a Pull Request.

## 📝 To Do

- Add multiprocessing support
- Implement Content-Type bypass testing
- Add file renaming detection
- Support other types of webshells: ASP, JSP, Python
- Add an interactive interface
- Add JSON/CSV export

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

## ✉️ Contact

Prodigium Academy

Project link: https://github.com/ProdigiumAcademy/ExtUp

⭐️ If this project helped you, give it a star! ⭐️
