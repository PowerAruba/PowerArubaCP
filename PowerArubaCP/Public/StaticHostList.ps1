#
# Copyright 2020, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Add-ArubaCPStaticHostList {

    <#
        .SYNOPSIS
        Add a Static Host List on ClearPass

        .DESCRIPTION
        Add a Static Host List with Id, Name, description, host format/type ....

        .EXAMPLE
        Add-ArubaCPStaticHostList -name SHL-list-IPAddress -host_format list -host_type IPAddress -host_entries_address 192.2.0.1 -host_entries_description "Add via PowerArubaCP"

        Add Static Host List with format list and type IP Address (192.2.0.1....)

        .EXAMPLE
        Add-ArubaCPStaticHostList -name SHL-list-MACAddress -host_format list -host_type MACAddress -host_entries_address 00:01:02:03:04:05 -host_entries_description "Add via PowerArubaCP"

        Add Static Host List with format list and type MAC Address (00:01:02:03:04:05....)
    #>

    Param(
        [Parameter (Mandatory = $false)]
        [int]$id,
        [Parameter (Mandatory = $true)]
        [string]$name,
        [Parameter (Mandatory = $false)]
        [string]$description,
        [Parameter (Mandatory = $true)]
        #[ValidateSet("subnet", "regex", "list")]
        [ValidateSet("list", IgnoreCase = $false)]
        [string]$host_format,
        [Parameter (Mandatory = $false)]
        [ValidateSet("IPAddress", "MACAddress", IgnoreCase = $false)]
        [string]$host_type,
        #[Parameter (Mandatory = $false)]
        #[string]$value,
        #[Parameter (Mandatory = $false)]
        #[psobject]$host_entries,
        [Parameter (Mandatory = $false)]
        [string]$host_entries_address,
        [Parameter (Mandatory = $false)]
        [string]$host_entries_description
    )

    Begin {
    }

    Process {

        $url = "api/static-host-list"

        $_shl = New-Object -TypeName PSObject

        if ( $PsBoundParameters.ContainsKey('id') ) {
            $_shl | Add-Member -name "id" -MemberType NoteProperty -Value $id
        }
        $_shl | Add-Member -name "name" -MemberType NoteProperty -Value $name

        if ( $PsBoundParameters.ContainsKey('description') ) {
            $_shl | Add-Member -name "description" -MemberType NoteProperty -Value $description
        }

        $_shl | Add-Member -name "host_format" -MemberType NoteProperty -Value $host_format

        if ( $PsBoundParameters.ContainsKey('host_type') ) {
            $_shl | Add-Member -name "host_type" -MemberType NoteProperty -Value $host_type
        }

        if ( $PsBoundParameters.ContainsKey('host_entries_address') -and $PsBoundParameters.ContainsKey('host_entries_description')) {
            $host_entries = New-Object -TypeName PSObject
            $host_entries | Add-Member -name "host_address" -MemberType NoteProperty -Value $host_entries_address
            $host_entries | Add-Member -name "host_address_desc" -MemberType NoteProperty -Value $host_entries_description
            $_shl | Add-Member -name "host_entries" -MemberType NoteProperty -Value @($host_entries)
        }

        $shl = Invoke-ArubaCPRestMethod -method "POST" -body $_shl -uri $url
        $shl
    }

    End {
    }
}
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