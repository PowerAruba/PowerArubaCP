#
# Copyright 2018-2020, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

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

