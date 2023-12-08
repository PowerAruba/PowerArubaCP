#
# Copyright 2020, Alexis La Goutte <alexis.lagoutte at gmail dot com>
# Copyright 2020, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Get-ArubaCPClusterCertificate {

    <#
        .SYNOPSIS
        Get all the cluster certificates on ClearPass

        .DESCRIPTION
        Get all the cluster certificates on ClearPass (HTTPS, RADIUS, etc ...)

        .EXAMPLE
        Get-ArubaCPClusterCertificate

        Return a list of cluster certificates on ClearPass

        .EXAMPLE
        Get-ArubaCPClusterCertificate -service_id 1

        Return the cluster certificate for service id 1 (RADIUS)

        .EXAMPLE
        Get-ArubaCPClusterCertificate -service_name "HTTPS"

        Return the cluster certificate for service name HTTPS

        .EXAMPLE
        Get-ArubaCPClusterCertificate -certificate_type "RadSec Server Certificate"

        Return the cluster certificate which is a RadSec Server Certificate type
    #>

    [CmdLetBinding(DefaultParameterSetName = "Default")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", "")]
    Param(
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "id")]
        [ValidateSet (1, 2, 7, 21, 106)]
        [int]$service_id,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "name")]
        [ValidateSet ("RADIUS", "HTTPS(RSA)", "HTTPS(ECC)", "RadSec")]
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

function Get-ArubaCPServerCertificate {

    <#
        .SYNOPSIS
        Get a server certificate on ClearPass

        .DESCRIPTION
        Get a server certificate on ClearPass (HTTPS, RADIUS, etc ...)

        .EXAMPLE
        $server_uuid = (Get-ArubaCPServerConfiguration).server_uuid[0]
        Get-ArubaCPServerCertificate -service_name RADIUS -server_uuid server_uuid

        Return the RADIUS certificates of first Server (using uuid)
    #>

    [CmdLetBinding(DefaultParameterSetName = "Default")]

    Param(
        [Parameter (Mandatory = $true)]
        [ValidateSet("RADIUS", "HTTPS(RSA)", "HTTPS(ECC)", "RadSec")]
        [string]$service_name,
        [Parameter (Mandatory = $true)]
        [string]$server_uuid,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {
        $uri = "api/server-cert/name/${server_uuid}/${service_name}"

        $cert = Invoke-ArubaCPRestMethod -method "GET" -uri $uri -connection $connection

        $cert
    }

    End {
    }
}