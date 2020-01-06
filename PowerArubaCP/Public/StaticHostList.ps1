#
# Copyright 2020, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#


function Get-ArubaCPStaticHostList {

    <#
        .SYNOPSIS
        Get Static Host List info on CPPM

        .DESCRIPTION
        Get Static Host List (Id, Name, description, host format/type ....)

        .EXAMPLE
        Get-ArubaCPStaticHostList

        Get ALL Static Host List on the Clearpass

        .EXAMPLE
        Get-ArubaCPStaticHostList SHL-PowerArubaCP

        Get info about Statc Host Listn named SHL-PowerArubaCP on the ClearPass

        .EXAMPLE
        Get-ArubaCPStaticHostList -id 23

        Get info about Static Host List id 23 on the ClearPass

        .EXAMPLE
        Get-ArubaCPStaticHostList SHL-PowerArubaCP -filter_type contains

        Get info about Statc Host List where name contains SHL-PowerArubaCP

       .EXAMPLE
        Get-ArubaCPStaticHostList -filter_attribute host_format -filter_type equal -filter_value list

        Get info about Static Host List where host_format equal list

    #>

    [CmdLetBinding(DefaultParameterSetName = "Default")]

    Param(
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "id")]
        [int]$id,
        [Parameter (Mandatory = $false, Position = 1)]
        [Parameter (ParameterSetName = "name")]
        [string]$Name,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "filter")]
        [string]$filter_attribute,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "id")]
        [Parameter (ParameterSetName = "name")]
        [Parameter (ParameterSetName = "filter")]
        [ValidateSet('equal', 'contains')]
        [string]$filter_type,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "filter")]
        [psobject]$filter_value,
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

        switch ( $PSCmdlet.ParameterSetName ) {
            "id" {
                $filter_value = $id
                $filter_attribute = "id"
            }
            "name" {
                $filter_value = $name
                $filter_attribute = "name"
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

        $url = "api/static-host-list"

        $nad = Invoke-ArubaCPRestMethod -method "GET" -uri $url @invokeParams

        $nad._embedded.items
    }

    End {
    }
}