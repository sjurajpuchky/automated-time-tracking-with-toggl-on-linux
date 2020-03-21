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

Invoke-WebRequest -Headers $Headers -Method GET -URI "https://www.toggl.com/api/v8/me" 2>$null| ConvertFrom-Json|Select-Object -Property data -ExpandProperty data|Select-Object -Property api_token -ExpandProperty api_token
}

function make_entry() {

    if ($args[4]) {
      $project_id=$args[4]
      $ep="assigned to project $project_id"
    } else {
      $project_id=""
      $ep="not assigned"
    }
  
    if ($args[5]) {
      $billable=$FALSE
      $eb="Not billable entry:"
    } else {
      $billable=$TRUE
      $eb="Billable entry:"
    }

    $pair = "$($args[3]):api_token"

    $encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
    
    $basicAuthValue = "Basic $encodedCreds"
    
    $Headers = @{
        Authorization = $basicAuthValue
    }

    if ($project_id) { 
    $Record = @{
      time_entry = @{
        description = $args[0]
        created_with = "measureit"
        start = $args[1]
        duration = $args[2]
        billable = $billable
        pid = $project_id
      }
    }  
  } else { 
    $Record = @{
      time_entry = @{
        description = $args[0]
        created_with = "measureit"
        start = $args[1]
        duration = $args[2]
        billable = $billable
      }
    }  
  } 
  
    $json=$($Record|ConvertTo-Json);
    Invoke-WebRequest -Headers $Headers -ContentType "application/json" -Method POST -URI "https://www.toggl.com/api/v8/time_entries" -Body "$json" 2>$null >$null
    echo "$eb $($args[0]) $($args[1]) $($args[2]) sec $ep"
  }

if (not-exist "$ignored") {
  echo > $ignored
}
if (not-exist "$projects") {
  echo > $projects
}
if (not-exist "$notbillable") {
  echo > $notbillable
}

$wold = ""
$n = 0
$told = $(Get-Date -Format "yyyy-MM-ddTHH:mm:ss+01:00")

$TUSER=$args[0];
$TPASS=$args[1];
$INTERVAL=$args[2];
$STEP=$args[3];

if ( !$TPASS ) { 
  echo "Usage: <toggl user name> <toggl password> [minimal interval] [step]"
  exit
}

if ( !$INTERVAL ) { 
    $INTERVAL = 300;
}

if ( !$STEP ) {
    $STEP = 1; 
}
    

while(1){
    $hwnd = [Win32.Utils]::GetForegroundWindow()
    
    $w = $(Get-Process |
        Where-Object { $_.mainWindowHandle -eq $hwnd } | 
        Select-Object MainWindowTitle -ExpandProperty MainWindowTitle);

    $t = $(Get-Date -Format "yyyy-MM-ddTHH:mm:ss+01:00")
    if ($w -ne $wold) {
        $ig=$(Get-Content $ignored | ForEach-Object {
          if ( $wold -match $_ ) {
            echo "yes";
          }
        });
        $project_id=$(Get-Content $projects | ForEach-Object {
          $p = $($_|ConvertFrom-Csv -Delimiter ";" -Header Id,Kw|Select-Object -Property Id -ExpandProperty Id)
          $q = $($_|ConvertFrom-Csv -Delimiter ";" -Header Id,Kw|Select-Object -Property Kw -ExpandProperty Kw)
          if ( $wold -match $q ) {
            echo $p;
          }
        });
        $notbill=$(Get-Content $notbillable | ForEach-Object {
          if ( $wold -match $_ ) {
            echo "yes";
          }
        });
        
        if ((-not $ig) -and ($n -ge $INTERVAL)) {
           $api_token=$(get_token $TUSER $TPASS);
           make_entry "$wold" "$told" "$n" "$api_token" "$project_id" "$notbill"
        }
    $n = 0;
    $wold = $w;
    $told = $t;
    }
    sleep -Milliseconds $($STEP * 1000)
    $n = $n + 1
}


