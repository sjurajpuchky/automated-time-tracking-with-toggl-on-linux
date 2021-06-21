# Automated time tracking with toggl on Linux / MacOS X / Windows

This simple tool you can use to automated time tracking of your work, it's free for use.
It will makes entry for each window which you spend on more than 300 sec (default optional) and makes report on
You will need toggl account.

# Install on Linux

Redhat/Centos/Fedora
--------------------

```
yum install jq curl xdotool
git clone https://github.com/sjurajpuchky/automated-time-tracking-with-toggl-on-linux.git
cd automated-time-tracking-with-toggl-on-linux
./measureit.sh <toggl user name> <toggl password> [minimal interval] [step]
```

Debian/Ubuntu/Mint
------------------

Install package:

```
sudo gdebi automated-toggl_0.1_all.deb
```
or use repo

```
sudo apt install lsb-release wget
echo "deb http://repo.vitexsoftware.cz $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/vitexsoftware.list
sudo wget -O /etc/apt/trusted.gpg.d/vitexsoftware.gpg http://repo.vitexsoftware.cz/keyring.gpg
sudo apt update
sudo apt install automated-toggl
```



# Install on MacOS X
```
brew install jq curl xdotool
git clone https://github.com/sjurajpuchky/automated-time-tracking-with-toggl-on-linux.git
cd automated-time-tracking-with-toggl-on-linux
./measureit.sh <toggl user name> <toggl password> [minimal interval] [step]
```

# Install on Windows
Internet Explorer (Edge) is required
```
Install https://download.microsoft.com/download/3/1/1/311C06C1-F162-405C-B538-D9DC3A4007D1/WindowsUCRT.zip
Install .NET Framework 4.5.2
Install WMF 5.1+
Install PowerShell 7+
powershell ./measureit.ps1 <toggl user name> <toggl password> [minimal interval] [step]
```

# Usage
Usage: < toggl user name > < toggl password > [minimal interval] [step]

For ignoring keywords use ~/.measureit.ignore file, each word is each line.
For not billable keywords use ~/.measureit.notbillable file each word is each line.
For automatic assign to project use ~/.measureit.projetcs file each line is each entry in CSV where ";" is separator.
Follow this format "PROJECT_ID;Keyword"
