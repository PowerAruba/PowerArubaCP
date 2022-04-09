#
# Copyright 2022, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Add-ArubaCPRole {

    <#
        .SYNOPSIS
        Add a Role on ClearPass

        .DESCRIPTION
        Add a Role with id, name, description

        .EXAMPLE
        Add-ArubaCPRole -name MyPowerArubaCP_role

        Add a Role with name MyPowerArubaCP_role

        .EXAMPLE
        Add-ArubaCPRole -name MyPowerArubaCP_role -description "Add via PowerArubaCP"

        Add a Role with name MyPowerArubaCP_role with a description

    #>

    Param(
        [Parameter (Mandatory = $false)]
        [int]$id,
        [Parameter (Mandatory = $true)]
        [string]$name,
        [Parameter (Mandatory = $false)]
        [string]$description,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        $uri = "api/role"

        $_r = new-Object -TypeName PSObject

        if ( $PsBoundParameters.ContainsKey('id') ) {
            $_r | add-member -name "id" -membertype NoteProperty -Value $id
        }

        $_r | add-member -name "name" -membertype NoteProperty -Value $name

        if ( $PsBoundParameters.ContainsKey('description') ) {
            $_r | add-member -name "description" -membertype NoteProperty -Value $description
        }

        $r = invoke-ArubaCPRestMethod -method "POST" -body $_r -uri $uri -connection $connection
        $r
    }

    End {
    }

}

function Get-ArubaCPRole {

    <#
        .SYNOPSIS
        Get Role info on CPPM

        .DESCRIPTION
        Get Role (name, description)

        .EXAMPLE
        Get-ArubaCPRole

        Get ALL Role on the Clearpass

        .EXAMPLE
        Get-ArubaCPRole MyPowerArubaCP_role

        Get info about Role name MyPowerArubaCP_role on the ClearPass

        .EXAMPLE
        Get-ArubaCPRole -id 23

        Get info about Role id 23 on the ClearPass

        .EXAMPLE
        Get-ArubaCPRole -name MyPowerArubaCP -filter_type contains

        Get info about Role username where name contains MyPowerArubaCP

       .EXAMPLE
        Get-ArubaCPRole -filter_attribute description -filter_type contains -filter_value PowerArubaCP

        Get info about Role where description contains PowerArubaCP
    #>

    [CmdLetBinding(DefaultParameterSetName = "Default")]

    Param(
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "id")]
        [int]$id,
        [Parameter (Mandatory = $false, Position = 1)]
        [Parameter (ParameterSetName = "name")]
        [string]$name,
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

        $uri = "api/role"

        $r = Invoke-ArubaCPRestMethod -method "GET" -uri $uri @invokeParams -connection $connection

        $r._embedded.items
    }

    End {
    }

}

function Set-ArubaCPRole {

    <#
        .SYNOPSIS
        Configure a Role on ClearPass

        .DESCRIPTION
        Configure a Role on ClearPass

        .EXAMPLE
        $r = Get-ArubaCPRole -name MyPowerArubaCP_role
        PS C:\>$r | Set-ArubaCPRole -username MyPowerArubaCP_role2

        Change role name (MyPowerArubaCP_role2) for role MyPowerArubaCP

        .EXAMPLE
        $r = Get-ArubaCPRole -name MyPowerArubaCP_role
        PS C:\>$r | Set-ArubaCPRole -description "Modified by PowerArubaCP"

        Change description for role MyPowerArubaCP_role

    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'medium')]
    Param(
        [Parameter (Mandatory = $true, ParameterSetName = "id")]
        [int]$id,
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "ep")]
        [ValidateScript( { Confirm-ArubaCPRole $_ })]
        [psobject]$r,
        [Parameter (Mandatory = $false)]
        [string]$name,
        [Parameter (Mandatory = $false)]
        [string]$description,
        [Parameter (Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        #get role id from role ps object
        if ($r) {
            $id = $r.id
            $rname = "(" + $r.name + ")"
        }

        $uri = "api/role/${id}"
        $_r = new-Object -TypeName PSObject

        if ( $PsBoundParameters.ContainsKey('name') ) {
            $_r | add-member -name "name" -membertype NoteProperty -Value $name
        }

        if ( $PsBoundParameters.ContainsKey('description') ) {
            $_r | add-member -name "description" -membertype NoteProperty -Value $description
        }

        if ($PSCmdlet.ShouldProcess("$id $rname", 'Configure Role')) {
            $r = Invoke-ArubaCPRestMethod -method "PATCH" -body $_r -uri $uri -connection $connection
            $r
        }

    }

    End {
    }

}

function Remove-ArubaCPRole {

    <#
        .SYNOPSIS
        Remove a Role on ClearPass

        .DESCRIPTION
        Remove a Role on ClearPass

        .EXAMPLE
        $r = Get-ArubaCPRole -role MyPowerArubaCP_role
        PS C:\>$r | Remove-ArubaCPRole

        Remove a Role with user name MyPowerArubaCP_role

        .EXAMPLE
        Remove-ArubaCPRole -id 3001 -confirm:$false

        Remove a Role with id 3001 and no confirmation
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'high')]
    Param(
        [Parameter (Mandatory = $true, ParameterSetName = "id")]
        [int]$id,
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "ep")]
        [ValidateScript( { Confirm-ArubaCPRole $_ })]
        [psobject]$r,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        #get Role id from lp ps object
        if ($r) {
            $id = $r.id
            $name = "(" + $r.name + ")"
        }

        $uri = "api/role/${id}"

        if ($PSCmdlet.ShouldProcess("$id $name", 'Remove Role')) {
            Invoke-ArubaCPRestMethod -method "DELETE" -uri $uri -connection $connection
        }

    }

    End {
    }

}