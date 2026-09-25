param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]] $FlutterArguments = @('run')
)

$ErrorActionPreference = 'Stop'

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$workspaceRoot = Split-Path $projectRoot -Parent
$localSdk = Join-Path $workspaceRoot '.tooling\flutter'
$flutterSdk = if (Test-Path -LiteralPath $localSdk) {
    (Resolve-Path -LiteralPath $localSdk).Path
} else {
    'C:\Flutter\flutter'
}

if (-not (Test-Path -LiteralPath (Join-Path $flutterSdk 'bin\flutter.bat'))) {
    throw "Flutter SDK not found at $flutterSdk"
}
if (Get-PSDrive -Name R -ErrorAction SilentlyContinue) {
    throw 'Drive R: is already in use.'
}
if (Get-PSDrive -Name S -ErrorAction SilentlyContinue) {
    throw 'Drive S: is already in use.'
}

subst.exe R: $projectRoot
subst.exe S: $flutterSdk

try {
    $env:PUB_CACHE = 'R:\.tool-cache\pub'
    $env:GRADLE_USER_HOME = 'R:\.tool-cache\gradle'
    $env:FLUTTER_SUPPRESS_ANALYTICS = 'true'
    $env:GIT_CONFIG_COUNT = '1'
    $env:GIT_CONFIG_KEY_0 = 'safe.directory'
    $env:GIT_CONFIG_VALUE_0 = $flutterSdk.Replace('\', '/')

    Push-Location 'R:\'
    try {
        & 'S:\bin\flutter.bat' @FlutterArguments
        $flutterExitCode = $LASTEXITCODE
    } finally {
        Pop-Location
    }
} finally {
    subst.exe R: /d
    subst.exe S: /d
}

exit $flutterExitCode
