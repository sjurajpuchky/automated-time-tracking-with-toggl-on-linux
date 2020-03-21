$user32dll = @'
    [DllImport("user32.dll")]
     public static extern IntPtr GetForegroundWindow();
'@

Add-Type $user32dll -Name Utils -Namespace Win32

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function not-exist { -not (Test-Path $args) }
Set-Alias !exist not-exist -Option "Constant, AllScope"
Set-Alias exist Test-Path -Option "Constant, AllScope"

$ignored="$HOME\.measureit.ignore"
$projects="$HOME\.measureit.projects"
$notbillable="$HOME\.measureit.notbillable"

function get_token() {

$pair = "$($args[0]):$($args[1])"

$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))

$basicAuthValue = "Basic $encodedCreds"

$Headers = @{
    Authorization = $basicAuthValue
}

Invoke-WebRequest -Headers $Headers -Method GET -URI https://www.toggl.com/api/v8/me 2>$null| ConvertFrom-Json|Select-Object -Property data -ExpandProperty data|Select-Object -Property api_token -ExpandProperty api_token
}

function make_entry() {

    if ($args[3]) {
      project_id=$args[5]
      ep="assigned to project $project_id"
    } else {
      project_id=""
      ep="not assigned"
    }
  
    if ($args[4]) {
      billable="0"
      eb="Not billable entry:"
    } else {
      billable="1"
      eb="Billable entry:"
    }
  
    json="{\"time_entry\":{\"description\":\"$args[0]\",\"created_with\":\"measureit.ps1\",\"start\":\"$args[1]\",\"duration\":$args[2]}}"
  
    curl -v -u $args[3]:api_token -H "Content-Type: application/json" -d "$json" -X POST https://www.toggl.com/api/v8/time_entries 2>$null > $null
    echo "$eb $args[0] $args[1] $args[3] $ep"
  }

if (not-exist "$ignored") {
  echo -n > $ignored
}
if (not-exist "$projects") {
  echo -n > $projects
}
if (not-exist "$notbillable") {
  echo -n > $notbillable
}

$wold = ""
$n = 0

$TUSER=$args[0];
$TPASS=$args[1];
$INTERVAL=$args[2];
$STEP=$args[3];

if ( !$TPASS ) { 
  echo "Usage: <toggl user name> <toggl password> [minimal interval] [step]"
  exit
}

if ( !$INTERVAL ) { 
    $INTERVAL = 1;
}

if ( !$STEP ) {
    $STEP = 1; 
}
    

while(1){
    $hwnd = [Win32.Utils]::GetForegroundWindow()
    
    $w = $(Get-Process |
        Where-Object { $_.mainWindowHandle -eq $hwnd } | 
        Select-Object MainWindowTitle -ExpandProperty MainWindowTitle);

    #$t = $(Get-Date -Format "yyyy-MM-ddTHH:mm:ss+01:00")
    #if ($w -ne $wold) {
        #if (($n -gt $INTERVAL)) {
           $api_token=$( get_token $TUSER $TPASS);
           echo $api_token;
        #}
    $n = 0;
    $wold = $w
    #}
    sleep -Milliseconds 1000
    $n = $n + 1
}


