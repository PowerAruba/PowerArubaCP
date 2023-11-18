#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Add-ArubaCPNetworkDevice {

    <#
        .SYNOPSIS
        Add a Network Device (NAD) on ClearPass

        .DESCRIPTION
        Add a Network Device (NAD) with radius secret, description, coa_capable, radsec....

        .EXAMPLE
        Add-ArubaCPNetworkDevice -name SW1 -ip_address 192.0.2.1 -radius_secret MySecurePassword -vendor Aruba -description "Add by PowerArubaCP"

        Add Network Device SW1 with ip address 192.0.2.1 from vendor Aruba and a description

        .EXAMPLE
        Add-ArubaCPNetworkDevice -name SW2 -ip_address 192.0.2.2 -radius_secret MySecurePassword -vendor Aruba -coa_capable -coa_port 5000

        Add Network Device SW2 with COA Capability on port 5000

        .EXAMPLE
        Add-ArubaCPNetworkDevice -name SW3 -ip_address 192.0.2.3 -radius_secret MySecurePassword -vendor Cisco -snmp_version V2C -community_string CommString

        Add Network Device SW3 with a snmp-read community string from vendor Cisco

        .EXAMPLE
        Add-ArubaCPNetworkDevice -name SW3 -ip_address 192.0.2.3 -radius_secret MySecurePassword -vendor Cisco -tacacs_secret MySecurePassword

        Add Network Device SW3 with a tacacs secret from vendor Cisco

        .EXAMPLE
        Add-ArubaCPNetworkDevice -name SW4 -ip_address 192.0.2.4 -radius_secret MySecurePassword -vendor Hewlett-Packard-Enterprise -radsec_enabled

        Add Network Device SW4 with RadSec from vendor HPE

        .EXAMPLE
        $attributes = @{ "Location" = "PowerArubaCP" }
        PS > Add-ArubaCPNetworkDevice -name SW5 -ip_address 192.0.2.5 -radius_secret MySecurePassword -vendor Aruba -attributes $attributes

        Add Network Device SW5 with hashtable attribute (Location) from vendor Aruba

    #>

    Param(
        [Parameter (Mandatory = $false)]
        [int]$id,
        [Parameter (Mandatory = $false)]
        [string]$description,
        [Parameter (Mandatory = $true)]
        [string]$name,
        [Parameter (Mandatory = $true)]
        [ipaddress]$ip_address,
        [Parameter (Mandatory = $true)]
        [string]$radius_secret,
        [Parameter (Mandatory = $false)]
        [ValidateSet('v1', 'v2c')]
        [string]$snmp_version,
        [Parameter (Mandatory = $false)]
        [string]$community_string,
        [Parameter (Mandatory = $false)]
        [string]$tacacs_secret,
        [Parameter (Mandatory = $true)]
        [string]$vendor_name,
        [Parameter (Mandatory = $false)]
        [switch]$coa_capable,
        [Parameter (Mandatory = $false)]
        [int]$coa_port,
        [Parameter (Mandatory = $false)]
        [switch]$radsec_enabled,
        [Parameter (Mandatory = $false)]
        [hashtable]$attributes,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        $uri = "api/network-device"

        $_nad = new-Object -TypeName PSObject

        if ( $PsBoundParameters.ContainsKey('id') ) {
            $_nad | add-member -name "id" -membertype NoteProperty -Value $id
        }

        if ( $PsBoundParameters.ContainsKey('description') ) {
            $_nad | add-member -name "description" -membertype NoteProperty -Value $description
        }

        $_nad | add-member -name "name" -membertype NoteProperty -Value $name

        $_nad | add-member -name "ip_address" -membertype NoteProperty -Value $ip_address.ToString()

        $_nad | add-member -name "radius_secret" -membertype NoteProperty -Value $radius_secret

        if ( $PsBoundParameters.ContainsKey('tacacs_secret') ) {
            $_nad | add-member -name "tacacs_secret" -membertype NoteProperty -Value $tacacs_secret
        }

        $_nad | add-member -name "vendor_name" -membertype NoteProperty -Value $vendor_name

        if ( $PsBoundParameters.ContainsKey('coa_capable') ) {
            if ( $coa_capable ) {
                $_nad | add-member -name "coa_capable" -membertype NoteProperty -Value $True
            }
            else {
                $_nad | add-member -name "coa_capable" -membertype NoteProperty -Value $false
            }
        }

        if ( $PsBoundParameters.ContainsKey('coa_port') ) {
            $_nad | add-member -name "coa_port" -membertype NoteProperty -Value $coa_port
        }

        if ( $PsBoundParameters.ContainsKey('radsec_enabled') ) {
            if ( $radsec_enabled ) {
                $_nad | add-member -name "radsec_enabled" -membertype NoteProperty -Value $True
            }
            else {
                $_nad | add-member -name "radsec_enabled" -membertype NoteProperty -Value $false
            }
        }

        if ( $PsBoundParameters.ContainsKey('attributes') ) {
            $_nad | add-member -name "attributes" -membertype NoteProperty -Value $attributes
        }

        if ($PsBoundParameters.ContainsKey('snmp_version')) {
            # Check if snmp_version is provided, and if so, make community_string mandatory
            if (-not $PsBoundParameters.ContainsKey('community_string')) {
                throw "If snmp_version is specified, community_string is mandatory."
            }
            $snmp_read = @{
                snmp_version = $snmp_version.ToUpper()
                community_string = $community_string
                zone_name = "default"
            }
            $_nad | add-member -name "snmp_read" -membertype NoteProperty -Value $snmp_read
        }

        $nad = invoke-ArubaCPRestMethod -method "POST" -body $_nad -uri $uri -connection $connection
        $nad
    }

    End {
    }
}

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
        Get-ArubaCPNetworkDevice NAD-PowerArubaCP

        Get info about NetworkDevice NAD-PowerArubaCP Aruba on the ClearPass

        .EXAMPLE
        Get-ArubaCPNetworkDevice -id 23

        Get info about NetworkDevice id 23 on the ClearPass

        .EXAMPLE
        Get-ArubaCPNetworkDevice NAD-PowerArubaCP -filter_type contains

        Get info about NetworkDevice where name contains NAD-PowerArubaCP

       .EXAMPLE
        Get-ArubaCPNetworkDevice -filter_attribute ip_address -filter_type equal -filter_value 192.168.1.1

        Get info about NetworkDevice where ip_address equal 192.168.1.1

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

        $uri = "api/network-device"

        $nad = Invoke-ArubaCPRestMethod -method "GET" -uri $uri @invokeParams -connection $connection

        $nad._embedded.items
    }

    End {
    }
}

function Set-ArubaCPNetworkDevice {

    <#
        .SYNOPSIS
        Configure a Network Device (NAD) on ClearPass

        .DESCRIPTION
        Configure a Network Device (NAS) on ClearPass

        .EXAMPLE
        $nad = Get-ArubaCPNetworkDevice -name NAD-PowerArubaCP
        PS > $nad | Set-ArubaCPNetworkDevice -name NAS-PowerArubaCP2

        Rename Network Device to NAD-PowerArubaCP2

        .EXAMPLE
        $nad = Get-ArubaCPNetworkDevice -name NAD-PowerArubaCP
        PS > $nad | Set-ArubaCPNetworkDevice -ip_address 192.0.2.2 -radius_secret MySecret2

        Change IP Address and radius_secret of NAD-PowerArubaCP

        .EXAMPLE
        $nad = Get-ArubaCPNetworkDevice -name NAD-PowerArubaCP
        PS > $nad | Set-ArubaCPNetworkDevice -vendor_name Cisco -tacacs_secret MySecret2

        Set Vendor Name to Cisco and (re)configure TACACS Secret of NAD-PowerArubaCP

        .EXAMPLE
        $nad = Get-ArubaCPNetworkDevice -name NAD-PowerArubaCP
        PS > $nad | Set-ArubaCPNetworkDevice -snmp_version V2C -community_string MyComm

        Set SNMP version and community string of NAD-PowerArubaCP

        .EXAMPLE
        $nad = Get-ArubaCPNetworkDevice -name NAD-PowerArubaCP
        PS > $nad | Set-ArubaCPNetworkDevice -coa_capable -coa_port 5000

        Enable COA and set COA Port to 5000 of NAD-PowerArubaCP

    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'medium')]
    Param(
        [Parameter (Mandatory = $true, ParameterSetName = "id")]
        [int]$id,
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "nad")]
        [ValidateScript( { Confirm-ArubaCPNetworkDevice $_ })]
        [psobject]$nad,
        [Parameter (Mandatory = $false)]
        [string]$description,
        [Parameter (Mandatory = $false)]
        [string]$name,
        [Parameter (Mandatory = $false)]
        [ipaddress]$ip_address,
        [Parameter (Mandatory = $false)]
        [string]$radius_secret,
        [Parameter (Mandatory = $false)]
        [ValidateSet('v1', 'v2c')]
        [string]$snmp_version,
        [Parameter (Mandatory = $false)]
        [string]$community_string,
        [Parameter (Mandatory = $false)]
        [string]$tacacs_secret,
        [Parameter (Mandatory = $false)]
        [string]$vendor_name,
        [Parameter (Mandatory = $false)]
        [switch]$coa_capable,
        [Parameter (Mandatory = $false)]
        [int]$coa_port,
        [Parameter (Mandatory = $false)]
        [switch]$radsec_enabled,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        #get nad id from nad ps object
        if ($nad) {
            $id = $nad.id
            $old_name = "(" + $nad.name + ")"
        }

        $uri = "api/network-device/${id}"
        $_nad = new-Object -TypeName PSObject

        if ( $PsBoundParameters.ContainsKey('id') ) {
            $_nad | add-member -name "id" -membertype NoteProperty -Value $id
        }

        if ( $PsBoundParameters.ContainsKey('description') ) {
            $_nad | add-member -name "description" -membertype NoteProperty -Value $description
        }

        if ( $PsBoundParameters.ContainsKey('name') ) {
            $_nad | add-member -name "name" -membertype NoteProperty -Value $name
        }

        if ( $PsBoundParameters.ContainsKey('ip_address') ) {
            $_nad | add-member -name "ip_address" -membertype NoteProperty -Value $ip_address.ToString()
        }

        if ( $PsBoundParameters.ContainsKey('radius_secret') ) {
            $_nad | add-member -name "radius_secret" -membertype NoteProperty -Value $radius_secret
        }

        if ($PsBoundParameters.ContainsKey('snmp_version')) {
            # Check if snmp_version is provided, and if so, make community_string mandatory
            if (-not $PsBoundParameters.ContainsKey('community_string')) {
                throw "If snmp_version is specified, community_string is mandatory."
            }
            $snmp_read = @{
                snmp_version = $snmp_version.ToUpper()
                community_string = $community_string
                zone_name = "default"
            }
            $_nad | add-member -name "snmp_read" -membertype NoteProperty -Value $snmp_read
        }


        if ( $PsBoundParameters.ContainsKey('tacacs_secret') ) {
            $_nad | add-member -name "tacacs_secret" -membertype NoteProperty -Value $tacacs_secret
        }

        if ( $PsBoundParameters.ContainsKey('vendor_name') ) {
            $_nad | add-member -name "vendor_name" -membertype NoteProperty -Value $vendor_name
        }

        if ( $PsBoundParameters.ContainsKey('coa_capable') ) {
            if ( $coa_capable ) {
                $_nad | add-member -name "coa_capable" -membertype NoteProperty -Value $True
            }
            else {
                $_nad | add-member -name "coa_capable" -membertype NoteProperty -Value $false
            }
        }

        if ( $PsBoundParameters.ContainsKey('coa_port') ) {
            $_nad | add-member -name "coa_port" -membertype NoteProperty -Value $coa_port
        }

        if ( $PsBoundParameters.ContainsKey('radsec_enabled') ) {
            if ( $radsec_enabled ) {
                $_nad | add-member -name "radsec_enabled" -membertype NoteProperty -Value $True
            }
            else {
                $_nad | add-member -name "radsec_enabled" -membertype NoteProperty -Value $false
            }
        }

        if ($PSCmdlet.ShouldProcess("$id $old_name", 'Configure Network device')) {
            $nad = Invoke-ArubaCPRestMethod -method "PATCH" -body $_nad -uri $uri -connection $connection
            $nad
        }

    }

    End {
    }
}

function Remove-ArubaCPNetworkDevice {

    <#
        .SYNOPSIS
        Remove a Network Device (NAD) on ClearPass

        .DESCRIPTION
        Remove a Network Device (NAS) on ClearPass

        .EXAMPLE
        $nad = Get-ArubaCPNetworkDevice -name NAD-PowerArubaCP
        PS > $nad | Remove-ArubaCPNetworkDevice

        Remove Network Device named NAD-PowerArubaCP

        .EXAMPLE
        Remove-ArubaCPNetworkDevice -id 3001 -confirm:$false

        Remove Network Device id 3001 with no confirmation
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'high')]
    Param(
        [Parameter (Mandatory = $true, ParameterSetName = "id")]
        [int]$id,
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "nad")]
        [ValidateScript( { Confirm-ArubaCPNetworkDevice $_ })]
        [psobject]$nad,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        #get nad id from nad ps object
        if ($nad) {
            $id = $nad.id
            $name = "(" + $nad.name + ")"
        }

        $uri = "api/network-device/${id}"

        if ($PSCmdlet.ShouldProcess("$id $name", 'Remove Network device')) {
            Invoke-ArubaCPRestMethod -method "DELETE" -uri $uri -connection $connection
        }

    }

    End {
    }
}