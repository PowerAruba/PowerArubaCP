#
# Copyright 2022, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Add-ArubaCPAttributesMember {

    <#
        .SYNOPSIS
        Add an Attribute Member

        .DESCRIPTION
        Add an Attribute Member on Endpoint / Local User / Network Device

        .EXAMPLE
        Get-ArubaCPEndpoint -mac_address 00:01:02:03:04:05 | Add-ArubaCPAttributesMember -name "Disabled by" -value PowerArubaCP

        Add Attribute name "Disabled By" with value PowerArubaCP to Endpoint 00:01:02:03:04:05

        .EXAMPLE
        Get-ArubaCPNetworkDevice -name NAD-PowerArubaCP | Add-ArubaCPAttributesMember -name "Location", "syslocation" -value "PowerArubaCP", "PowerArubaCP"

        Add Attribute name "Location and Syslocation" with value PowerArubaCP to network Device NAD-PowerArubaCP

        .EXAMPLE
        Get-ArubaCPLocalUser -user_id MyPowerArubaCP_userid | Add-ArubaCPAttributesMember -attributes @{"Disabled by"="PowerArubaCP"}

        Add Attribute name "Disabled By" with value PowerArubaCP to Local User MyPowerArubaCP_userid

    #>

    Param(
        [Parameter (Mandatory = $true, ValueFromPipeline = $true)]
        #[ValidateScript( { (Confirm-ArubaCPEndpoint $_) -or (Confirm-ArubaCPNetworkDevice $_) })]
        [psobject]$atts,
        [Parameter (Mandatory = $true, ParameterSetName = "nv")]
        [string[]]$name,
        [Parameter (Mandatory = $true, ParameterSetName = "nv")]
        [string[]]$value,
        [Parameter (Mandatory = $true, ParameterSetName = "att")]
        [psobject]$attributes,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        $id = $atts.id
        if ($atts.mac_address -and $atts.status) {
            $uri = "api/endpoint/${id}"
        }
        elseif ($atts.user_id -and $atts.role_name) {
            $uri = "api/local-user/${id}"
        }
        elseif ($atts.ip_address -and $atts.vendor_name) {
            $uri = "api/network-device/${id}"
        }
        else {
            Throw "Not an Endpoint, a Local User or a Network Device"
        }

        if ($PSCmdlet.ParameterSetName -eq "nv") {
            if (@($name).count -ne @($value).count) {
                Throw "You need to have the same number of name and value parameters"
            }

            $attributes = New-Object -TypeName PSObject
            $i = 0
            foreach ($n in $name) {
                $attributes | Add-Member -name $n -MemberType NoteProperty -Value $value[$i]
                $i++
            }

        }

        $_att = New-Object -TypeName PSObject

        $_att | Add-Member -name "attributes" -MemberType NoteProperty -Value $attributes

        $att = Invoke-ArubaCPRestMethod -method "PATCH" -body $_att -uri $uri -connection $connection
        $att
    }

    End {
    }

}

function Set-ArubaCPAttributesMember {

    <#
        .SYNOPSIS
        Set an Attribute Member

        .DESCRIPTION
        Configure an Attribute Member on Endpoint / Local User / Network Device
        Remove existing attributes

        .EXAMPLE
        Get-ArubaCPEndpoint -mac_address 00:01:02:03:04:05 | Set-ArubaCPAttributesMember -name "Disabled by" -value PowerArubaCP

        Set Attribute name "Disabled By" with value PowerArubaCP to Endpoint 00:01:02:03:04:05

        .EXAMPLE
        Get-ArubaCPNetworkDevice -name NAD-PowerArubaCP | Set-ArubaCPAttributesMember -name "Location", "syslocation" -value "PowerArubaCP", "PowerArubaCP"

        Set Attribute name "Location and Syslocation" with value PowerArubaCP to network Device NAD-PowerArubaCP

        .EXAMPLE
        Get-ArubaCPLocalUser -user_id MyPowerArubaCP_userid | Set-ArubaCPAttributesMember -attributes @{"Disabled by"="PowerArubaCP"}

        Set Attribute name "Disabled By" with value PowerArubaCP to Local User MyPowerArubaCP_userid
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'medium')]
    Param(
        [Parameter (Mandatory = $true, ValueFromPipeline = $true)]
        #[ValidateScript( { ( Confirm-ArubaCPEndpoint $_ -or Confirm-ArubaCPNetworkDevice $_) })]
        [psobject]$atts,
        [Parameter (Mandatory = $true, ParameterSetName = "nv")]
        [string[]]$name,
        [Parameter (Mandatory = $true, ParameterSetName = "nv")]
        [string[]]$value,
        [Parameter (Mandatory = $true, ParameterSetName = "att")]
        [psobject]$attributes,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        #get atts id from Endpoint/Local User/Network Device PS object
        if ($atts) {
            $id = $atts.id
            $old_name = "(" + $atts.name + ")"
        }

        if ($atts.mac_address -and $atts.status) {
            $uri = "api/endpoint/${id}"
            $delete_value = "--For-Delete--"
        }
        elseif ($atts.user_id -and $atts.role_name) {
            $uri = "api/local-user/${id}"
            $delete_value = ""
        }
        elseif ($atts.ip_address -and $atts.vendor_name) {
            $uri = "api/network-device/${id}"
            $delete_value = ""
        }
        else {
            Throw "Not an Endpoint, a Local User or a Network Device"
        }

        $_att = New-Object -TypeName PSObject

        #Add new name/value (or attributes)
        if ($PSCmdlet.ParameterSetName -eq "nv") {
            if (@($name).count -ne @($value).count) {
                Throw "You need to have the same number of name and value parameters"
            }

            $attributes = New-Object -TypeName PSObject
            $i = 0
            foreach ($n in $name) {
                $attributes | Add-Member -name $n -MemberType NoteProperty -Value $value[$i]
                $i++
            }
        }

        #Remove existing attributes (set value to null)
        foreach ($n in ($atts.attributes | Get-Member -MemberType NoteProperty).name ) {
            if ($attributes.$n) {
                #Skip if there is already an attribute with this name...
                continue
            }
            $attributes | Add-Member -name $n -MemberType NoteProperty -Value $delete_value
        }

        $_att | Add-Member -name "attributes" -MemberType NoteProperty -Value $attributes

        if ($PSCmdlet.ShouldProcess("$id $old_name", 'Configure Attribute Member')) {
            $att = Invoke-ArubaCPRestMethod -method "PATCH" -body $_att -uri $uri -connection $connection
            $att
        }

    }

    End {
    }

}

function Remove-ArubaCPAttributesMember {

    <#
        .SYNOPSIS
        Remove an Attribute member

        .DESCRIPTION
        Remove an Attribute Member on Endpoint / Local User / Network Device

        .EXAMPLE
        Get-ArubaCPEndpoint -mac_address 00:01:02:03:04:05 | Remove-ArubaCPAttributesMember -name "Disabled by"

        Remove Attribute name "Disabled By" with value PowerArubaCP to Endpoint 00:01:02:03:04:05

        .EXAMPLE
        Get-ArubaCPNetworkDevice -name NAD-PowerArubaCP | Remove-ArubaCPAttributesMember -name "Location", "syslocation"

        Remove Attribute name "Location and Syslocation" to network Device NAD-PowerArubaCP

    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'medium')]
    Param(
        [Parameter (Mandatory = $true, ValueFromPipeline = $true)]
        #[ValidateScript( { ( Confirm-ArubaCPEndpoint $_ -or Confirm-ArubaCPNetworkDevice $_) })]
        [psobject]$atts,
        [Parameter (Mandatory = $true)]
        [string[]]$name,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        $id = $atts.id
        $rname = "(" + $atts.name + ")"
        if ($atts.mac_address -and $atts.status) {
            $uri = "api/endpoint/${id}"
            $delete_value = "--For-Delete--"
        }
        elseif ($atts.user_id -and $atts.role_name) {
            $uri = "api/local-user/${id}"
            $delete_value = ""
        }
        elseif ($atts.ip_address -and $atts.vendor_name) {
            $uri = "api/network-device/${id}"
            $delete_value = ""
        }
        else {
            Throw "Not an Endpoint, a Local User or a Network Device"
        }

        $_att = New-Object -TypeName PSObject

        $attributes = New-Object -TypeName PSObject

        foreach ($n in $name) {
            $attributes | Add-Member -name $n -MemberType NoteProperty -Value $delete_value
        }

        $_att | Add-Member -name "attributes" -MemberType NoteProperty -Value $attributes

        if ($PSCmdlet.ShouldProcess("$id $rname", 'Remove Attribute Member')) {
            $att = Invoke-ArubaCPRestMethod -method "PATCH" -body $_att -uri $uri -connection $connection
            $att
        }

    }

    End {
    }

}
