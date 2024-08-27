param(
    [string] $Name = 'luajit',
    [string] $Version = '2.1',
    [string] $Uri = 'https://github.com/luajit/luajit.git',
    [string] $Hash = 'f725e44cda8f359869bf8f92ce71787ddca45618',
    [array] $Targets = @('x64')
)

function Setup {
    Setup-Dependency -Uri $Uri -Hash $Hash -DestinationPath $Path
}

function Build {
    Log-Information "Build (${Target})"
    Set-Location $Path

    $Params = @{
        BasePath = (Get-Location | Convert-Path)
        BuildPath = "src"
        BuildCommand = "cmd.exe /c 'msvcbuild.bat amalg'"
        Target = $Target
    }

    Invoke-DevShell @Params
}

function Install {
    Log-Information "Install (${Target})"
    Set-Location $Path

    $Params = @{
        Path = "$($ConfigData.OutputPath)/include/luajit"
        ItemType = "Directory"
        Force = $true
    }

    New-Item @Params -ErrorAction SilentlyContinue > $null

    $Items = @(
        @{
            Path = "src/*.h"
            Destination = "$($ConfigData.OutputPath)/include/luajit"
        }
        @{
            Path = "src/lua51.dll"
            Destination = "$($ConfigData.OutputPath)/bin"
        }
        @{
            Path = "src/lua51.lib"
            Destination = "$($ConfigData.OutputPath)/lib"
        }
    )

    $Items | ForEach-Object {
        $Item = $_
        Log-Output ('{0} => {1}' -f ($Item.Path -join ", "), $Item.Destination)
        Copy-Item @Item
    }
}
