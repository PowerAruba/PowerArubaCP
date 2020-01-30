#
# Copyright 2020, Alexis La Goutte <alexis.lagoutte at gmail dot com>
# Copyright 2020, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Get-ArubaCPClusterCertificates {

    <#
        .SYNOPSIS
        Get all the cluster certificates on ClearPass

        .DESCRIPTION
        Get all the cluster certificates on ClearPass (HTTPS, RADIUS, etc ...)

        .EXAMPLE
        Get-ArubaCPClusterCertificates

        Return a list of cluster certificates on ClearPass

                .EXAMPLE
        Get-ArubaCPClusterCertificates -service_id 1

        Return the cluster certificate for service id 1 (RADIUS)

                .EXAMPLE
        Get-ArubaCPClusterCertificates -service_name "HTTPS"

        Return the cluster certificate for service name HTTPS

                .EXAMPLE
        Get-ArubaCPClusterCertificates -certificate_type "RadSec Server Certificate"

        Return the cluster certificate which is a RadSec Server Certificate type
    #>

    [CmdLetBinding(DefaultParameterSetName = "Default")]

    Param(
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "id")]
        [ValidateSet(1,2,21)]
        [int]$service_id,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "name")]
        [ValidateSet("RADIUS","HTTPS","RadSec")]
        [string]$service_name,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "type")]
        [string]$certificate_type,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        $uri = "api/server-cert"

        $cert = Invoke-ArubaCPRestMethod -method "GET" -uri $uri -connection $connection

        switch ( $PSCmdlet.ParameterSetName ) {
            "id" { $cert._embedded.items | Where-Object { $_.service_id -eq $service_id } }
            "name" { $cert._embedded.items | Where-Object { $_.service_name -like $service_name } }
            "type" { $cert._embedded.items | Where-Object { $_.certificate_type -eq $certificate_type } }
            default { $cert._embedded.items }
        }
    }

    End {
    }
}

function Get-ArubaCPClusterCertificate {

    <#
        .SYNOPSIS
        Get a cluster certificate on ClearPass

        .DESCRIPTION
        Get a cluster certificate on ClearPass (HTTPS, RADIUS, etc ...)

        .EXAMPLE
        Get-ArubaCPClusterCertificate -service_id 1

        Return the RADIUS certificates
    #>

    [CmdLetBinding(DefaultParameterSetName = "Default")]

    Param(
        [Parameter (Mandatory = $true)]
        [ValidateSet(1,2,21)]
        [int]$service_id,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        $uri = "api/server-cert/${service_id}"

        $cert = Invoke-ArubaCPRestMethod -method "GET" -uri $uri -connection $connection

        $cert

    }


    End {
    }
}

function Get-ArubaCPServerCertificate {

    <#
        .SYNOPSIS
        Get a server certificate on ClearPass

        .DESCRIPTION
        Get a server certificate on ClearPass (HTTPS, RADIUS, etc ...)

        .EXAMPLE
        Get-ArubaCPServerCertificate -service_name RADIUS

        Return the RADIUS certificates
    #>

    [CmdLetBinding(DefaultParameterSetName = "Default")]

    Param(
        [Parameter (Mandatory = $true)]
        [ValidateSet("RADIUS","HTTPS","RadSec")]
        [string]$service_name,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {
        $server = Get-ArubaCPServerConfiguration
        $server_uuid = $server.server_uuid

        $uri = "api/server-cert/name/       ${server_uuid}/${service_name}"

        $cert = Invoke-ArubaCPRestMethod -method "GET" -uri $uri -connection $connection

        $cert

    }


    End {
    }
}

function Add-ArubaCPServerCertificate {

    <#
        .SYNOPSIS
        Add a certificate on Clearpass

        .DESCRIPTION
        Add a certificate on Clearpass for a service (HTTPS, RADIUS, RadSec)

        .EXAMPLE
        Add-ArubaCPServerCertificate -service_name HTTPS -cert_file <your_certificate>

        Add a certificate on Clearpass for HTTPS Service
    #>

    Param(
        [Parameter (Mandatory = $true, Position = 1)]
        [string]$service_name,
        [Parameter (Mandatory = $true, Position = 2)]
        [string]$cert_url,
        [Parameter (Mandatory = $true, Position = 3)]
        [string]$cert_pass,
        [Parameter (Mandatory = $false, Position = 4)]
        [string]$cert_file,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        $server = Get-ArubaCPServerConfiguration
        $server_uuid = $server.server_uuid

        $certificat = New-Object -TypeName PSObject

        $certificat | add-member -name "service_name" -membertype NoteProperty -Value $service_name
        $certificat | add-member -name "pkcs12_file_url" -membertype NoteProperty -Value $cert_url
        $certificat | add-member -name "pkcs12_passphrase" -membertype NoteProperty -Value $cert_pass
        $certificat | add-member -name "cert_file" -membertype NoteProperty -Value $cert_file

        $uri = "api/server-cert/name/${server_uuid}/${service_name}"

        $cert = Invoke-ArubaCPRestMethod -method "PUT" -body $certificat -uri $uri -connection $connection
        $cert
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
        PS C:\>$nad | Set-ArubaCPNetworkDevice -name NAS-PowerArubaCP2

        Rename Network Device to NAD-PowerArubaCP2

        .EXAMPLE
        $nad = Get-ArubaCPNetworkDevice -name NAD-PowerArubaCP
        PS C:\>$nad | Set-ArubaCPNetworkDevice -ip_address 192.0.2.2 -radius_secret MySecret2

        Change IP Address and radius_secret of NAD-PowerArubaCP

        .EXAMPLE
        $nad = Get-ArubaCPNetworkDevice -name NAD-PowerArubaCP
        PS C:\>$nad | Set-ArubaCPNetworkDevice -vendor_name Cisco -tacacs_secret MySecret2

        Set Vendor Name to Cisco and (re)configure TACACS Secret of NAD-PowerArubaCP

        .EXAMPLE
        $nad = Get-ArubaCPNetworkDevice -name NAD-PowerArubaCP
        PS C:\>$nad | Set-ArubaCPNetworkDevice -coa_capable -coa_port 5000

        Enable COA and set COA Port to 5000 of NAD-PowerArubaCP

    #>

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

        $nad = Invoke-ArubaCPRestMethod -method "PATCH" -body $_nad -uri $uri -connection $connection
        $nad

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
        PS C:\>$nad | Remove-ArubaCPNetworkDevice

        Remove Network Device named NAD-PowerArubaCP

        .EXAMPLE
        Remove-ArubaCPNetworkDevice -id 3001 -noconfirm

        Remove Network Device id 3001 with no confirmation
    #>

    Param(
        [Parameter (Mandatory = $true, ParameterSetName = "id")]
        [int]$id,
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "nad")]
        [ValidateScript( { Confirm-ArubaCPNetworkDevice $_ })]
        [psobject]$nad,
        [Parameter(Mandatory = $false)]
        [switch]$noconfirm,
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
        }

        $uri = "api/network-device/${id}"

        if ( -not ( $Noconfirm )) {
            $message = "Remove Network Device on ClearPass"
            $question = "Proceed with removal of Network Device ${id} ?"
            $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
            $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
            $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))

            $decision = $Host.UI.PromptForChoice($message, $question, $choices, 1)
        }
        else { $decision = 0 }
        if ($decision -eq 0) {
            Write-Progress -activity "Remove Network Device"
            Invoke-ArubaCPRestMethod -method "DELETE" -uri $uri -connection $connection
            Write-Progress -activity "Remove Network Device" -completed
        }
    }

    End {
    }
}