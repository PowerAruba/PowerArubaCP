#
# Copyright 2021, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Add-ArubaCPNetworkDeviceGroup {

    <#
        .SYNOPSIS
        Add a Network Device Group on ClearPass

        .DESCRIPTION
        Add a Network Device Group with Id, Name, description, subnet, regex, list...

        .EXAMPLE
        Add-ArubaCPNetworkDeviceGroup -name NDG-subnet -subnet 192.0.2.0/24 -description "Add via PowerArubaCP"

        Add Network Device Group with format subnet and subnet 192.0.2.0/24 and a description

        .EXAMPLE
        Add-ArubaCPNetworkDeviceGroup -name NDG-list_ip -list_ip 192.0.2.1, 192.0.2.2

        Add Network Device Group with format list and IP 192.0.2.1 and 192.0.2.2

        .EXAMPLE
        Add-ArubaCPNetworkDeviceGroup -name NDG-regex -regex "^192(.[0-9]*){3}$"

        Add Network Device Group with format regex and regex "^192(.[0-9]*){3}$"
    #>

    Param(
        [Parameter (Mandatory = $false)]
        [int]$id,
        [Parameter (Mandatory = $true)]
        [string]$name,
        [Parameter (Mandatory = $false)]
        [string]$description,
        [Parameter (Mandatory = $true, ParameterSetName = "subnet")]
        [string]$subnet,
        [Parameter (Mandatory = $true, ParameterSetName = "regex")]
        [string]$regex,
        [Parameter (Mandatory = $true, ParameterSetName = "list_ip")]
        [string[]]$list_ip,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        $uri = "api/network-device-group"

        $_ndg = New-Object -TypeName PSObject

        if ( $PsBoundParameters.ContainsKey('id') ) {
            $_ndg | Add-Member -name "id" -MemberType NoteProperty -Value $id
        }

        $_ndg | Add-Member -name "name" -MemberType NoteProperty -Value $name

        if ( $PsBoundParameters.ContainsKey('description') ) {
            $_ndg | Add-Member -name "description" -MemberType NoteProperty -Value $description
        }

        switch ( $PSCmdlet.ParameterSetName ) {
            "subnet" {
                $_ndg | Add-Member -name "group_format" -MemberType NoteProperty -Value "subnet"
                $_ndg | add-member -name "value" -membertype NoteProperty -Value $subnet
            }
            "regex" {
                $_ndg | Add-Member -name "group_format" -MemberType NoteProperty -Value "regex"
                $_ndg | add-member -name "value" -membertype NoteProperty -Value $regex
            }
            "list_ip" {
                $_ndg | Add-Member -name "group_format" -MemberType NoteProperty -Value "list"
                $_ndg | add-member -name "value" -membertype NoteProperty -Value ($list_ip -join ",")
            }
            default { }
        }

        $ndg = Invoke-ArubaCPRestMethod -method "POST" -body $_ndg -uri $uri -connection $connection
        $ndg
    }

    End {
    }
}

function Add-ArubaCPNetworkDeviceGroupMember {

    <#
        .SYNOPSIS
        Add a Network Device Group Member on ClearPass

        .DESCRIPTION
        Add a Network Device Group Member IP list

        .EXAMPLE
        Get-ArubaCPNetworkDeviceGroup -name NDG-list_ip | Add-ArubaCPNetworkDeviceGroupMember -list_ip 192.0.2.2

        Add Network Device Group with format list and type IP Address (192.0.2.2.)
    #>

    Param(
        [Parameter (Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateScript( { Confirm-ArubaCPNetworkDeviceGroup $_ })]
        [psobject]$ndg,
        [Parameter (Mandatory = $true)]
        [string[]]$list_ip,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        $id = $ndg.id
        $uri = "api/network-device-group/${id}"

        $_ndg = New-Object -TypeName PSObject

        #append to actual list
        $value = $ndg.value + ", " + ($list_ip -join ", ")
        $_ndg | Add-Member -name "value" -MemberType NoteProperty -Value $value

        $ndg = Invoke-ArubaCPRestMethod -method "PATCH" -body $_ndg -uri $uri -connection $connection
        $ndg
    }

    End {
    }
}

function Get-ArubaCPNetworkDeviceGroup {

    <#
        .SYNOPSIS
        Get Network Device Group info on CPPM

        .DESCRIPTION
        Get Network Device Group (Id, Name, description, group_format, value ....)

        .EXAMPLE
        Get-ArubaCPNetworkDeviceGroup

        Get ALL Network Device Group on the Clearpass

        .EXAMPLE
        Get-ArubaCPNetworkDeviceGroup NDG-PowerArubaCP

        Get info about Network Device Group named NDG-PowerArubaCP on the ClearPass

        .EXAMPLE
        Get-ArubaCPNetworkDeviceGroup -id 23

        Get info about Network Device Group id 23 on the ClearPass

        .EXAMPLE
        Get-ArubaCPNetworkDeviceGroup NDG-PowerArubaCP -filter_type contains

        Get info about Network Device Group where name contains NDG-PowerArubaCP

       .EXAMPLE
        Get-ArubaCPNetworkDeviceGroup -filter_attribute group_format -filter_type equal -filter_value list

        Get info about Network Device Group where group_format equal list

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

        $uri = "api/network-device-group"

        $ndg = Invoke-ArubaCPRestMethod -method "GET" -uri $uri -connection $connection @invokeParams
        $ndg._embedded.items
    }

    End {
    }
}

function Set-ArubaCPNetworkDeviceGroup {

    <#
        .SYNOPSIS
        Configure a Network Device Group on ClearPass

        .DESCRIPTION
        Configure a Network Device Group with Id, Name, Description, subnet, regex, list...

        .EXAMPLE
        Get-ArubaCPNetworkDeviceGroup -name My-NDG-list | Set-ArubaCPNetworkDeviceGroup -name NDG-list-IP -description "Update via PowerArubaCP"

        Change Network Device Group name and description

        .EXAMPLE
        Get-ArubaCPNetworkDeviceGroup -name My-NDG-list | Set-ArubaCPNetworkDeviceGroup -list 192.0.2.3

        Change Network Device Group (IP) list
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'medium', DefaultParameterSetName = "Default")]
    Param(
        [int]$id,
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1)]
        [ValidateScript( { Confirm-ArubaCPNetworkDeviceGroup $_ })]
        [psobject]$ndg,
        [Parameter (Mandatory = $false)]
        [string]$name,
        [Parameter (Mandatory = $false)]
        [string]$description,
        [Parameter (Mandatory = $true, ParameterSetName = "subnet")]
        [string]$subnet,
        [Parameter (Mandatory = $true, ParameterSetName = "regex")]
        [string]$regex,
        [Parameter (Mandatory = $true, ParameterSetName = "list_ip")]
        [string[]]$list_ip,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        #get ndg id from ndg ps object
        if ($ndg) {
            $id = $ndg.id
            $old_name = "(" + $ndg.name + ")"
        }

        $uri = "api/network-device-group/${id}"

        $_ndg = New-Object -TypeName PSObject

        if ( $PsBoundParameters.ContainsKey('name') ) {
            $_ndg | Add-Member -name "name" -MemberType NoteProperty -Value $name
        }

        if ( $PsBoundParameters.ContainsKey('description') ) {
            $_ndg | Add-Member -name "description" -MemberType NoteProperty -Value $description
        }

        switch ( $PSCmdlet.ParameterSetName ) {
            "subnet" {
                $_ndg | Add-Member -name "group_format" -MemberType NoteProperty -Value "subnet"
                $_ndg | Add-member -name "value" -membertype NoteProperty -Value $subnet
            }
            "regex" {
                $_ndg | Add-Member -name "group_format" -MemberType NoteProperty -Value "regex"
                $_ndg | Add-member -name "value" -membertype NoteProperty -Value $regex
            }
            "list_ip" {
                $_ndg | Add-Member -name "group_format" -MemberType NoteProperty -Value "list"
                $_ndg | Add-member -name "value" -membertype NoteProperty -Value ($list_ip -join ",")
            }
            default { }
        }

        if ($PSCmdlet.ShouldProcess("$id $old_name", 'Configure Network Device Group')) {
            $ndg = Invoke-ArubaCPRestMethod -method "PATCH" -body $_ndg -uri $uri -connection $connection
            $ndg
        }
    }

    End {
    }
}

function Remove-ArubaCPNetworkDeviceGroup {

    <#
        .SYNOPSIS
        Remove a Network Device Group on ClearPass

        .DESCRIPTION
        Remove a Network Device Group on ClearPass

        .EXAMPLE
        $ndg = Get-ArubaCPNetworkDeviceGroup -name NDG-PowerArubaCP
        PS C:\>$ndg | Remove-ArubaCPNetworkDeviceGroup

        Remove Network Device Group named NDG-PowerArubaCP

        .EXAMPLE
        Remove-ArubaCPNetworkDeviceGroup -id 3001 -confirm:$false

        Remove Network Device Group id 3001 with no confirmation
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'high')]
    Param(
        [Parameter (Mandatory = $true, ParameterSetName = "id")]
        [int]$id,
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "ndg")]
        [ValidateScript( { Confirm-ArubaCPNetworkDeviceGroup $_ })]
        [psobject]$ndg,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        #get ndg id from ndg ps object
        if ($ndg) {
            $id = $ndg.id
            $name = "(" + $ndg.name + ")"
        }

        $uri = "api/network-device-group/${id}"

        if ($PSCmdlet.ShouldProcess("$id $name", 'Remove Network Device Group')) {
            Invoke-ArubaCPRestMethod -method "DELETE" -uri $uri -connection $connection
        }
    }

    End {
    }
}

function Remove-ArubaCPNetworkDeviceGroupMember {

    <#
        .SYNOPSIS
        Remove a Network Device Group Member on ClearPass

        .DESCRIPTION
        Remove a Network Device Group Member list IP

        .EXAMPLE
        Get-ArubaCPNetworkDeviceGroup -name NDG-list_ip | Remove-ArubaCPNetworkDeviceGroupMember -list_ip 192.0.2.2

        Remove Network Device Group Member with IP 192.0.2.2
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'medium')]
    Param(
        [Parameter (Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateScript( { Confirm-ArubaCPNetworkDeviceGroup $_ })]
        [psobject]$ndg,
        [Parameter (Mandatory = $true)]
        [string[]]$list_ip,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        $id = $ndg.id
        $name = "(" + $ndg.name + ")"
        $uri = "api/network-device-group/${id}"

        $_ndg = New-Object -TypeName PSObject
        $value = $ndg.value -split ", "
        foreach ($ip in $list_ip) {
            $value = $value | Where-Object { $_ -ne $ip }
        }

        if ( $value.count -eq 0 ) {
            Throw "You can't remove all entries. Use Remove-ArubaCPNetworkDeviceGroup to remove Network Device Group"
        }

        $_ndg | Add-Member -name "value" -MemberType NoteProperty -Value ($value -join ", ")

        if ($PSCmdlet.ShouldProcess("$id $name", 'Remove Network Device Group Member')) {
            $ndg = Invoke-ArubaCPRestMethod -method "PATCH" -body $_ndg -uri $uri -connection $connection
            $ndg
        }
    }

    End {
    }
}