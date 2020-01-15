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
        Get Endpoint (Id, MAC Address, Status, Attributes)

        .EXAMPLE
        Get-ArubaCPEndpoint

        Get ALL Endpoint on the Clearpass

        .EXAMPLE
        Get-ArubaCPEndpoint 000102030405

        Get info about Endpoint 000102030405 Aruba on the ClearPass

        .EXAMPLE
        Get-ArubaCPEndpoint -id 23

        Get info about Endpoint id 23 on the ClearPass

        .EXAMPLE
        Get-ArubaCPEndpoint 000102030405 -filter_type contains

        Get info about Endpoint where name contains 000102

       .EXAMPLE
        Get-ArubaCPEndpoint -filter_attribute attribute -filter_type contains -filter_value 192.0.2.1

        Get info about Endpoint where attribute contains 192.0.2.1
    #>

    [CmdLetBinding(DefaultParameterSetName = "Default")]

    Param(
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "id")]
        [int]$id,
        [Parameter (Mandatory = $false, Position = 1)]
        [Parameter (ParameterSetName = "mac_address")]
        [string]$mac_address,
        [Parameter (Mandatory = $false, Position = 1)]
        [Parameter (ParameterSetName = "status")]
        [ValidateSet('Known', 'Unknown', 'Disabled')]
        [string]$status,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "filter")]
        [string]$filter_attribute,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "id")]
        [Parameter (ParameterSetName = "mac_address")]
        [Parameter (ParameterSetName = "status")]
        [Parameter (ParameterSetName = "filter")]
        [ValidateSet('equal', 'contains')]
        [string]$filter_type,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "filter")]
        [psobject]$filter_value,
        [Parameter (Mandatory = $false)]
        [int]$limit,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        $invokeParams = @{ }
        if ( $PsBoundParameters.ContainsKey('limit') ) {
            $invokeParams.add( 'limit', $limit )
        }

        switch ( $PSCmdlet.ParameterSetName ) {
            "id" {
                $filter_value = $id
                $filter_attribute = "id"
            }
            "mac_address" {
                $filter_value = $mac_address
                $filter_attribute = "mac_address"
            }
            "status" {
                $filter_value = $status
                $filter_attribute = "status"
            }
            default { }
        }

        if ( $PsBoundParameters.ContainsKey('filter_type') ) {
            switch ( $filter_type ) {
                "equal" {
                    $filter_value = @{ "`$eq" = $filter_value }
                }
                "contains" {
                    $filter_value = @{ "`$contains" = $filter_value }
                }
                default { }
            }
        }

        if ($filter_value -and $filter_attribute) {
            $filter = @{ $filter_attribute = $filter_value }
            $invokeParams.add( 'filter', $filter )
        }

        $uri = "api/endpoint"

        $endpoint = Invoke-ArubaCPRestMethod -method "GET" -uri $uri @invokeParams -connection $connection

        $endpoint._embedded.items
    }

    End {
    }
}