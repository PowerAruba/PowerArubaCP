#
# Copyright 2021, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Add-ArubaCPLocaluser {

    <#
        .SYNOPSIS
        Add a Local User on ClearPass

        .DESCRIPTION
        Add a Local User with user_id, username, password, role...

        .EXAMPLE
        Add-ArubaCPLocaluser -user_id MyPowerArubaCP_userid -password MyPassword -role_name "[Employee]"

        Add a Local User with user_id MyPowerArubaCP_userid (same username) and role_name [Employee]

        .EXAMPLE
        Add-ArubaCPLocaluser -user_id MyPowerArubaCP_userid -username MyPowerArubaCP_username -password MyPassword -role_name "[Employee]"

        Add a Local User with user_id MyPowerArubaCP_userid, username MyPowerArubaCP_username and role_name [Employee]

        .EXAMPLE
        $attributes = @{"Disabled by"="PowerArubaCP"}
        PS >Add-ArubaCPLocaluser -user_id MyPowerArubaCP_userid -password MyPassword -role_name "[Employee]" -attributes $attributes

        dd a Local User with user_id MyPowerArubaCP_userid (same username), role_name [Employee] attributes to Disabled by PowerArubaCP
    #>

    Param(
        [Parameter (Mandatory = $false)]
        [int]$id,
        [Parameter (Mandatory = $true)]
        [string]$user_id,
        [Parameter (Mandatory = $false)]
        [string]$username,
        [Parameter (Mandatory = $true)]
        [string]$password,
        [Parameter (Mandatory = $true)]
        [string]$role_name,
        [Parameter (Mandatory = $false)]
        [switch]$enabled,
        [Parameter (Mandatory = $false)]
        [switch]$change_pwd_next_login,
        [Parameter (Mandatory = $false)]
        [psobject]$attributes,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        $uri = "api/local-user"

        $_lu = new-Object -TypeName PSObject

        if ( $PsBoundParameters.ContainsKey('id') ) {
            $_lu | add-member -name "id" -membertype NoteProperty -Value $id
        }

        $_lu | add-member -name "user_id" -membertype NoteProperty -Value $user_id

        if ( $PsBoundParameters.ContainsKey('username') ) {
            $_lu | add-member -name "username" -membertype NoteProperty -Value $username
        } else {
            #if don't define username use the user_id
            $_lu | add-member -name "username" -membertype NoteProperty -Value $user_id
        }

        $_lu | add-member -name "password" -membertype NoteProperty -Value $password

        $_lu | add-member -name "role_name" -membertype NoteProperty -Value $role_name

        if ( $PsBoundParameters.ContainsKey('enabled') ) {
            if($enabled) {
                $_lu | add-member -name "enabled" -membertype NoteProperty -Value $true
            } else {
                $_lu | add-member -name "enabled" -membertype NoteProperty -Value $false
            }
        }

        if ( $PsBoundParameters.ContainsKey('change_pwd_next_login') ) {
            if($change_pwd_next_login) {
                $_lu | add-member -name "change_pwd_next_login" -membertype NoteProperty -Value $true
            } else {
                $_lu | add-member -name "change_pwd_next_login" -membertype NoteProperty -Value $false
            }
        }

        if ( $PsBoundParameters.ContainsKey('attributes') ) {
            $_lu | add-member -name "attributes" -membertype NoteProperty -Value $attributes
        }

        $lu = invoke-ArubaCPRestMethod -method "POST" -body $_lu -uri $uri -connection $connection
        $lu
    }

    End {
    }
}

function Get-ArubaCPLocaluser {

    <#
        .SYNOPSIS
        Get Local user info on CPPM

        .DESCRIPTION
        Get Local User (Id, MAC Address, Status, Attributes)

        .EXAMPLE
        Get-ArubaCPLocalUser

        Get ALL Local User on the Clearpass

        .EXAMPLE
        Get-ArubaCPLocalUser 000102030405

        Get info about Local User 000102030405 Aruba on the ClearPass

        .EXAMPLE
        Get-ArubaCPLocalUser -id 23

        Get info about Local User id 23 on the ClearPass

        .EXAMPLE
        Get-ArubaCPLocalUser 000102030405 -filter_type contains

        Get info about Local User where name contains 000102

       .EXAMPLE
        Get-ArubaCPLocalUser -filter_attribute attribute -filter_type contains -filter_value 192.0.2.1

        Get info about Local User where attribute contains 192.0.2.1
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
                $filter_value = Format-ArubaCPMACAddress $mac_address
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

        $uri = "api/local-user"

        $lu = Invoke-ArubaCPRestMethod -method "GET" -uri $uri @invokeParams -connection $connection

        $lu._embedded.items
    }

    End {
    }
}


function Set-ArubaCPLocalUser {

    <#
        .SYNOPSIS
        Configure a Local User on ClearPass

        .DESCRIPTION
        Configure a Local User on ClearPass

        .EXAMPLE
        $lu = Get-ArubaCPLocalUser -mac_address 00:01:02:03:04:05
        PS C:\>$lu | Set-ArubaCPLocalUser -status Disabled

        Set Status Disabled for MAC Address 00:01:02:03:04:05

        .EXAMPLE
        $lu = Get-ArubaCPLocalUser -mac_address 00:01:02:03:04:05
        PS C:\>$lu | Set-ArubaCPLocalUser -description "Change by PowerAruba"

        Change Description for MAC Address 00:01:02:03:04:05

        .EXAMPLE
        $lu = Get-ArubaCPLocalUser -mac_address 00:01:02:03:04:05
        PS C:\>$attributes = @{"Disabled by"= "PowerArubaCP"}
        PS C:\>$lu | Set-ArubaCPLocalUser -attributes $attributes

        Change attributes for MAC Address 00:01:02:03:04:05

        .EXAMPLE
        $lu = Get-ArubaCPLocalUser -mac_address 00:01:02:03:04:05
        PS C:\>$lu | Set-ArubaCPLocalUser -mac_address 00:01:02:03:04:06

        Change MAC Address 00:01:02:03:04:05 => 00:01:02:03:04:06

    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'medium')]
    Param(
        [Parameter (Mandatory = $true, ParameterSetName = "id")]
        [int]$id,
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "ep")]
        [ValidateScript( { Confirm-ArubaCPLocalUser $_ })]
        [psobject]$lu,
        [Parameter (Mandatory = $false)]
        [string]$mac_address,
        [Parameter (Mandatory = $false)]
        [string]$description,
        [Parameter (Mandatory = $false)]
        [ValidateSet('Known', 'Unknown', 'Disabled', IgnoreCase = $false)]
        [string]$status,
        [Parameter (Mandatory = $false)]
        [psobject]$attributes,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        #get nad id from nad ps object
        if ($lu) {
            $id = $lu.id
        }

        $uri = "api/local-user/${id}"
        $_lu = new-Object -TypeName PSObject

        if ( $PsBoundParameters.ContainsKey('id') ) {
            $_lu | add-member -name "id" -membertype NoteProperty -Value $id
        }

        if ( $PsBoundParameters.ContainsKey('mac_address') ) {
            $_lu | add-member -name "mac_address" -membertype NoteProperty -Value $mac_address
        }

        if ( $PsBoundParameters.ContainsKey('description') ) {
            $_lu | add-member -name "description" -membertype NoteProperty -Value $description
        }

        if ( $PsBoundParameters.ContainsKey('status') ) {
            $_lu | add-member -name "status" -membertype NoteProperty -Value $status
        }

        if ( $PsBoundParameters.ContainsKey('attributes') ) {
            $_lu | add-member -name "attributes" -membertype NoteProperty -Value $attributes
        }

        if ($PSCmdlet.ShouldProcess($id, 'Configure Local User')) {
            $lu = Invoke-ArubaCPRestMethod -method "PATCH" -body $_lu -uri $uri -connection $connection
            $lu
        }

    }

    End {
    }
}
function Remove-ArubaCPLocalUser {

    <#
        .SYNOPSIS
        Remove a Local User on ClearPass

        .DESCRIPTION
        Remove a Local User on ClearPass

        .EXAMPLE
        $lu = Get-ArubaCPLocalUser -mac_address 00:01:02:03:04:05
        PS C:\>$lu | Remove-ArubaCPLocalUser

        Remove a Local User with MAC Address 00:01:02:03:04:05

        .EXAMPLE
        Remove-ArubaCPLocalUser -id 3001 -confirm:$false

        Remove a Local User with id 3001 and no confirmation
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'high')]
    Param(
        [Parameter (Mandatory = $true, ParameterSetName = "id")]
        [int]$id,
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "ep")]
        [ValidateScript( { Confirm-ArubaCPLocalUser $_ })]
        [psobject]$lu,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        #get Local User id from lp ps object
        if ($lu) {
            $id = $lu.id
            $mac = "(" + $lu.mac_address + ")"
        }

        $uri = "api/local-user/${id}"

        if ($PSCmdlet.ShouldProcess("$id $mac", 'Remove Local User')) {
            Invoke-ArubaCPRestMethod -method "DELETE" -uri $uri -connection $connection
        }

    }

    End {
    }

}