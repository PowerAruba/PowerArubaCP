#
# Copyright 2019, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#



function Get-ArubaCPEndpoint {

    <#
        .SYNOPSIS
        Get Enpoint info on CPPM

        .DESCRIPTION
        Get Network Device (Id, MAC Address, Status, Attributes)

        .EXAMPLE
        Get-ArubaCPEndpoint

        Get ALL Endpoint on the Clearpass

    #>


    Param(
        [Parameter (Mandatory = $false)]
        [int]$limit
    )

    Begin {
    }

    Process {

        $invokeParams = @{ }
        if ( $PsBoundParameters.ContainsKey('limit') ) {
            $invokeParams.add( 'limit', $limit )
        }

        $url = "api/endpoint"

        $endpoint = Invoke-ArubaCPRestMethod -method "GET" -uri $url @invokeParams

        $endpoint._embedded.items
    }

    End {
    }
}