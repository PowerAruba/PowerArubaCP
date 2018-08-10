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
        Add-ArubaCPNetworkDevice -name SW3 -ip_address 192.0.2.3 -radius_secret MySecurePassword -vendor Cisco -tacacs_secret MySecurePassword

        Add Network Device SW3 with a tacacs secret from vendor Cisco

        .EXAMPLE
        Add-ArubaCPNetworkDevice -name SW4 -ip_address 192.0.2.4 -radius_secret MySecurePassword -vendor Hewlett-Packard-Enterprise -radsec_enabled

        Add Network Device SW4 with RadSec from vendor HPE
    #>

    Param(
        [Parameter (Mandatory=$false)]
        [int]$id,
        [Parameter (Mandatory=$false)]
        [string]$description,
        [Parameter (Mandatory=$true)]
        [string]$name,
        [Parameter (Mandatory=$true)]
        [ipaddress]$ip_address,
        [Parameter (Mandatory=$true)]
        [string]$radius_secret,
        [Parameter (Mandatory=$false)]
        [string]$tacacs_secret,
        [Parameter (Mandatory=$true)]
        [string]$vendor_name,
        [Parameter (Mandatory=$false)]
        [switch]$coa_capable,
        [Parameter (Mandatory=$false)]
        [int]$coa_port,
        [Parameter (Mandatory=$false)]
        [switch]$radsec_enabled
    )

    Begin {
    }

    Process {

        $url = "api/network-device"

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
            } else {
                $_nad | add-member -name "coa_capable" -membertype NoteProperty -Value $false
            }
        }

        if ( $PsBoundParameters.ContainsKey('coa_port') ) {
            $_nad | add-member -name "coa_port" -membertype NoteProperty -Value $coa_port
        }

        if ( $PsBoundParameters.ContainsKey('radsec_enabled') ) {
            if ( $radsec_enabled ) {
                $_nad | add-member -name "radsec_enabled" -membertype NoteProperty -Value $True
            } else {
                $_nad | add-member -name "radsec_enabled" -membertype NoteProperty -Value $false
            }
        }

        $nad = invoke-ArubaCPRestMethod -method "POST" -body $_nad -uri $url
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
