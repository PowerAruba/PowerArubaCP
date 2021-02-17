#
# Copyright 2018-2020, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Get-ArubaCPCPPMVersion {

    <#
        .SYNOPSIS
        Get CPPM Version info on CPPM

        .DESCRIPTION
        Get CPPM Version (major, minor, hardware, eval... )

        .EXAMPLE
        Get-ArubaCPCPPMVersion

        Get CPPM Version

    #>


    Param(
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        $uri = "api/cppm-version"

        $cv = Invoke-ArubaCPRestMethod -method "GET" -uri $uri -connection $connection

        $cv
    }

    End {
    }
}

function Get-ArubaCPServerConfiguration {

    <#
        .SYNOPSIS
        Get Server Configuration info on CPPM

        .DESCRIPTION
        Get Server Configuration (name, uuid, server / management ip... )

        .EXAMPLE
        Get-ArubaCPServerConfiguration

        Get Server Configuration

    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter")] #False positive see https://github.com/PowerShell/PSScriptAnalyzer/issues/1472
    [CmdLetBinding(DefaultParameterSetName = "Default")]

    Param(
        [Parameter (Mandatory = $false, ParameterSetName = "uuid")]
        [string]$uuid,
        [Parameter (Mandatory = $false, ParameterSetName = "name")]
        [string]$name,
        [Parameter (Mandatory = $false, ParameterSetName = "ip_address")]
        [ipaddress]$ip_address,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        $uri = "api/cluster/server"

        $sc = Invoke-ArubaCPRestMethod -method "GET" -uri $uri -connection $connection

        switch ( $PSCmdlet.ParameterSetName ) {
            "uuid" { $sc._embedded.items | Where-Object { $_.server_uuid -eq $uuid } }
            "name" { $sc._embedded.items | Where-Object { $_.name -eq $name } }
            "ip_address" { $sc._embedded.items | Where-Object { $_.management_ip -eq $ip_address } }
            default { $sc._embedded.items }
        }
    }

    End {
    }
}
function Get-ArubaCPServerVersion {

    <#
        .SYNOPSIS
        Get Server Version info on CPPM

        .DESCRIPTION
        Get Server Version (CPPM version, Guest, Installed Patches )

        .EXAMPLE
        Get-ArubaCPServerVersion

        Get Server Version

    #>


    Param(
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        $uri = "api/server/version"

        $sv = Invoke-ArubaCPRestMethod -method "GET" -uri $uri -connection $connection

        $sv
    }

    End {
    }
}