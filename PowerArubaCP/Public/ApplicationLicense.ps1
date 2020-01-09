#
# Copyright 2018-2020, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Get-ArubaCPApplicationLicense {

    <#
        .SYNOPSIS
        Get Application License info on CPPM

        .DESCRIPTION
        Get Application License (Id, Name, Type, user Count...)

        .EXAMPLE
        Get-ArubaCPApplicationLicense

        Get ALL Application License  on the Clearpass

        .EXAMPLE
        Get-ArubaCPApplicationLicense -product_name Access

        Get info about Application License where product_name is Access

    #>

    Param(
    )

    Begin {
    }

    Process {

        $url = "api/application-license"

        $al = Invoke-ArubaCPRestMethod -method "GET" -uri $url @invokeParams

        $al._embedded.items
    }

    End {
    }
}

