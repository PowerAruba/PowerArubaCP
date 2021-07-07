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
        [ValidateSet (1,2,21)]
        [int]$service_id,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "name")]
        [ValidateSet ("RADIUS","HTTPS","RadSec")]
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

        $uri = "api/server-cert/name/${server_uuid}/${service_name}"

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

        Add a pfx certificate on Clearpass for HTTPS Service
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