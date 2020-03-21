# Automated time tracking with toggl on Linux / MacOS X / Windows

This simple tool you can use to automated time tracking of your work, it's free for use.
It will makes entry for each window which you spend on more than 300 sec (default optional) and makes report on
You will need toggl account.

# Install on Linux
```
yum install jq curl xdotool
git clone https://github.com/sjurajpuchky/automated-time-tracking-with-toggl-on-linux.git
cd automated-time-tracking-with-toggl-on-linux
./measureit.sh <toggl user name> <toggl password> [minimal interval] [step]
```

# Install on MacOS X
```
brew install jq curl xdotool
git clone https://github.com/sjurajpuchky/automated-time-tracking-with-toggl-on-linux.git
cd automated-time-tracking-with-toggl-on-linux
./measureit.sh <toggl user name> <toggl password> [minimal interval] [step]
```

# Install on Windows
```
Install WMF 4+
Install PowerShell 7+
Install CURL for Windows
Extend enviroment PATH with path to CURL/bin folder
./measureit.ps1 <toggl user name> <toggl password> [minimal interval] [step]
```

# Usage
Usage: < toggl user name > < toggl password > [minimal interval] [step]

