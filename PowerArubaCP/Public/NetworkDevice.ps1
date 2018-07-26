#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Get-ArubaCPNetworkDevice {

    <#
        .SYNOPSIS
        Get Network Device info on CPPM

        .DESCRIPTION
        Get Network Device (Id, Name, IP, ....)

        .EXAMPLE
        Get-ArubaCPNetworkDevice

        Get ALL NetworkDevice on the Clearpass

        .EXAMPLE
        Get-ArubaSWVlans Aruba

        Get info about vlan named Aruba on the switch

        .EXAMPLE
        Get-ArubaSWVlans -id 23

        Get info about vlan id 23 on the switch

    #>

    [CmdLetBinding(DefaultParameterSetName="Default")]

    Param(
        [Parameter (Mandatory=$false, ParameterSetName="id")]
        [int]$id,
        [Parameter (Mandatory=$false, ParameterSetName="name", Position=1)]
        [string]$Name
    )

    Begin {
    }

    Process {

        $url = "api/network-device"

        $nad = Invoke-ArubaCPRestMethod -method "GET" -uri $url


        switch ( $PSCmdlet.ParameterSetName ) {
            "name" { $nad._embedded.items  | where-object { $_.name -match $name}}
            "id" { $nad._embedded.items | where-object { $_.id -eq $id}}
            default { $nad._embedded.items }
        }
    }

    End {
    }
}
