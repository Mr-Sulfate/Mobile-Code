# Keep CLI flags such as --debug out of PowerShell common-parameter binding.
$FlutterArguments = @($args)
if ($FlutterArguments.Count -eq 0) { $FlutterArguments = @('run') }
$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$workspaceRoot = Split-Path $projectRoot -Parent
$sdkRoot = Join-Path $workspaceRoot '.tooling\flutter'
if (-not (Test-Path -LiteralPath (Join-Path $sdkRoot 'bin\flutter.bat'))) {
    $flutterCommand = Get-Command flutter.bat -ErrorAction Stop
    $sdkRoot = Split-Path (Split-Path $flutterCommand.Source -Parent) -Parent
}
# Map sources and shared caches to ASCII paths; leave project files in place.
$freeDrives = @('R','S','T','U','V','W','X','Y','Z','P','Q') | Where-Object {
    -not (Test-Path -LiteralPath "${_}:\")
}
if ($freeDrives.Count -lt 2) { throw 'Two free drive letters are required.' }
$projectDrive = $freeDrives[0] + ':'
$workspaceDrive = $freeDrives[1] + ':'
$savedEnvironment = @{}
foreach ($name in @('PUB_CACHE','GRADLE_USER_HOME','FLUTTER_SUPPRESS_ANALYTICS',
                    'GIT_CONFIG_COUNT','GIT_CONFIG_KEY_0','GIT_CONFIG_VALUE_0')) {
    $savedEnvironment[$name] = [Environment]::GetEnvironmentVariable($name, 'Process')
}
$mappedProject = $false
$mappedWorkspace = $false
$flutterExitCode = 1
try {
    subst.exe $projectDrive $projectRoot
    if ($LASTEXITCODE -ne 0) { throw 'Cannot map project directory.' }
    $mappedProject = $true
    subst.exe $workspaceDrive $workspaceRoot
    if ($LASTEXITCODE -ne 0) { throw 'Cannot map workspace directory.' }
    $mappedWorkspace = $true
    $mappedSdk = if ($sdkRoot.StartsWith($workspaceRoot + '\', [StringComparison]::OrdinalIgnoreCase)) {
        $workspaceDrive + $sdkRoot.Substring($workspaceRoot.Length)
    } else { $sdkRoot }
    $env:PUB_CACHE = "$workspaceDrive\.pub-cache"
    $env:GRADLE_USER_HOME = "$workspaceDrive\.gradle-home"
    $env:FLUTTER_SUPPRESS_ANALYTICS = 'true'
    $env:GIT_CONFIG_COUNT = '1'
    $env:GIT_CONFIG_KEY_0 = 'safe.directory'
    $env:GIT_CONFIG_VALUE_0 = $sdkRoot.Replace('\', '/')
    Push-Location "$projectDrive\"
    try {
        if ($FlutterArguments[0] -eq 'dart') {
            $dartArguments = @($FlutterArguments | Select-Object -Skip 1)
            & "$mappedSdk\bin\dart.bat" @dartArguments
        } else {
            & "$mappedSdk\bin\flutter.bat" @FlutterArguments
        }
        $flutterExitCode = $LASTEXITCODE
    } finally { Pop-Location }
} finally {
    if ($mappedWorkspace) { subst.exe $workspaceDrive /d }
    if ($mappedProject) { subst.exe $projectDrive /d }
    foreach ($name in $savedEnvironment.Keys) {
        [Environment]::SetEnvironmentVariable($name, $savedEnvironment[$name], 'Process')
    }
}
exit $flutterExitCode