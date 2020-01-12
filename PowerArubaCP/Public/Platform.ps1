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
    )

    Begin {
    }

    Process {

        $url = "api/cppm-version"

        $cv = Invoke-ArubaCPRestMethod -method "GET" -uri $url

        $cv
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
    )

    Begin {
    }

    Process {

        $url = "api/server/version"

        $sv = Invoke-ArubaCPRestMethod -method "GET" -uri $url

        $sv
    }

    End {
    }
}