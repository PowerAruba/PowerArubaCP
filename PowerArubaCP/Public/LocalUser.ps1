#
# Copyright 2022 Alexis La Goutte <alexis dot lagoutte at gmail dot com>
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
        Add-ArubaCPLocaluser -user_id MyPowerArubaCP_userid -password ( ConvertTo-SecureString MyPassword -AsPlainText -Force ) -role_name "[Employee]"

        Add a Local User with user_id MyPowerArubaCP_userid (same username) and role_name [Employee]

        .EXAMPLE
        Add-ArubaCPLocaluser -user_id MyPowerArubaCP_userid -username MyPowerArubaCP_username -password ( ConvertTo-SecureString MyPassword -AsPlainText -Force ) -role_name "[Employee]"

        Add a Local User with user_id MyPowerArubaCP_userid, username MyPowerArubaCP_username and role_name [Employee]

        .EXAMPLE
        $mysecurepassword = ConvertTo-SecureString MyPassword -AsPlainText -Force
        PS >$attributes = @{ "Sponsor" = "PowerArubaCP" }
        PS >Add-ArubaCPLocaluser -user_id MyPowerArubaCP_userid -password $mysecurepassword -role_name "[Employee]" -attributes $attributes

        Add a Local User with user_id MyPowerArubaCP_userid (same username), role_name [Employee] with Sponsor Attributes to PowerArubaCP
    #>

    Param(
        [Parameter (Mandatory = $false)]
        [int]$id,
        [Parameter (Mandatory = $true)]
        [string]$user_id,
        [Parameter (Mandatory = $false)]
        [string]$username,
        [Parameter (Mandatory = $true)]
        [securestring]$password,
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
        }
        else {
            #if don't define username use the user_id
            $_lu | add-member -name "username" -membertype NoteProperty -Value $user_id
        }

        $credentials = New-Object System.Net.NetworkCredential("", $password)
        $_lu | add-member -name "password" -membertype NoteProperty -Value $credentials.Password

        $_lu | add-member -name "role_name" -membertype NoteProperty -Value $role_name

        if ( $PsBoundParameters.ContainsKey('enabled') ) {
            if ($enabled) {
                $_lu | add-member -name "enabled" -membertype NoteProperty -Value $true
            }
            else {
                $_lu | add-member -name "enabled" -membertype NoteProperty -Value $false
            }
        }

        if ( $PsBoundParameters.ContainsKey('change_pwd_next_login') ) {
            if ($change_pwd_next_login) {
                $_lu | add-member -name "change_pwd_next_login" -membertype NoteProperty -Value $true
            }
            else {
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
        Get Local User (user_id, username, password, roles)

        .EXAMPLE
        Get-ArubaCPLocalUser

        Get ALL Local User on the Clearpass

        .EXAMPLE
        Get-ArubaCPLocalUser MyPowerArubaCP_userid

        Get info about Local User ID MyPowerArubaCP_userid on the ClearPass

        .EXAMPLE
        Get-ArubaCPLocalUser -id 23

        Get info about Local User id 23 on the ClearPass

        .EXAMPLE
        Get-ArubaCPLocalUser -username MyPowerArubaCP -filter_type contains

        Get info about Local User username where name contains MyPowerArubaCP

       .EXAMPLE
        Get-ArubaCPLocalUser -filter_attribute role -filter_type contains -filter_value Employee

        Get info about Local User where role contains Employee
    #>

    [CmdLetBinding(DefaultParameterSetName = "Default")]

    Param(
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "id")]
        [int]$id,
        [Parameter (Mandatory = $false, Position = 1)]
        [Parameter (ParameterSetName = "user_id")]
        [string]$user_id,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "username")]
        [string]$username,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "filter")]
        [string]$filter_attribute,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "id")]
        [Parameter (ParameterSetName = "user_id")]
        [Parameter (ParameterSetName = "username")]
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
            "user_id" {
                $filter_value = $user_id
                $filter_attribute = "user_id"
            }
            "username" {
                $filter_value = $username
                $filter_attribute = "username"
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
        $lu = Get-ArubaCPLocalUser -username MyPowerArubaCP
        PS C:\>$lu | Set-ArubaCPLocalUser -username MyPowerArubaCP2

        Change username for user(name) MyPowerArubaCP

        .EXAMPLE
        $lu = Get-ArubaCPLocalUser -username MyPowerArubaCP
        PS C:\>$lu | Set-ArubaCPLocalUser -password ( ConvertTo-SecureString MyPassword -AsPlainText -Force )

        Change Password for user(name) MyPowerArubaCP

        .EXAMPLE
        $lu = Get-ArubaCPLocalUser -username MyPowerArubaCP
        PS C:\>$lu | Set-ArubaCPLocalUser -role "[Guest]"

        Change Role (Guest) for user(name) MyPowerArubaCP

        .EXAMPLE
        $lu = Get-ArubaCPLocalUser -username MyPowerArubaCP
        PS >$attributes = @{ "Sponsor" = "PowerArubaCP" }
        PS >$lu | Set-ArubaCPLocalUser -attributes $attributes

        Change attributes (Sponsor) for user(name) MyPowerArubaCP

    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'medium')]
    Param(
        [Parameter (Mandatory = $true, ParameterSetName = "id")]
        [int]$id,
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "ep")]
        [ValidateScript( { Confirm-ArubaCPLocalUser $_ })]
        [psobject]$lu,
        [Parameter (Mandatory = $false)]
        [string]$user_id,
        [Parameter (Mandatory = $false)]
        [string]$username,
        [Parameter (Mandatory = $false)]
        [securestring]$password,
        [Parameter (Mandatory = $false)]
        [string]$role_name,
        [Parameter (Mandatory = $false)]
        [switch]$enabled,
        [Parameter (Mandatory = $false)]
        [switch]$change_pwd_next_login,
        [Parameter (Mandatory = $false)]
        [psobject]$attributes,
        [Parameter (Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        #get lu id from Local User ps object
        if ($lu) {
            $id = $lu.id
        }

        $uri = "api/local-user/${id}"
        $_lu = new-Object -TypeName PSObject

        if ( $PsBoundParameters.ContainsKey('user_id') ) {
            $_lu | add-member -name "user_id" -membertype NoteProperty -Value $user_id
        }

        if ( $PsBoundParameters.ContainsKey('username') ) {
            $_lu | add-member -name "username" -membertype NoteProperty -Value $username
        }

        if ( $PsBoundParameters.ContainsKey('password') ) {
            $credentials = New-Object System.Net.NetworkCredential("", $password)
            $_lu | add-member -name "password" -membertype NoteProperty -Value $credentials.Password
        }

        if ( $PsBoundParameters.ContainsKey('role_name') ) {
            $_lu | add-member -name "role_name" -membertype NoteProperty -Value $role_name
        }

        if ( $PsBoundParameters.ContainsKey('enabled') ) {
            if ( $enabled ) {
                $_lu | add-member -name "enabled" -membertype NoteProperty -Value $True
            }
            else {
                $_lu | add-member -name "enabled" -membertype NoteProperty -Value $false
            }
        }

        if ( $PsBoundParameters.ContainsKey('change_pwd_next_login') ) {
            if ( $change_pwd_next_login ) {
                $_lu | add-member -name "change_pwd_next_login" -membertype NoteProperty -Value $True
            }
            else {
                $_lu | add-member -name "change_pwd_next_login" -membertype NoteProperty -Value $false
            }
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
        $lu = Get-ArubaCPLocalUser -username MyPowerArubaCP_username
        PS C:\>$lu | Remove-ArubaCPLocalUser

        Remove a Local User with user name MyPowerArubaCP_username

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
            $user_id = "(" + $lu.user_id + ")"
        }

        $uri = "api/local-user/${id}"

        if ($PSCmdlet.ShouldProcess("$id $user_id", 'Remove Local User')) {
            Invoke-ArubaCPRestMethod -method "DELETE" -uri $uri -connection $connection
        }

    }

    End {
    }

}