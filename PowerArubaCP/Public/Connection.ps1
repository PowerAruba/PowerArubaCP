#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Connect-ArubaCP {

    <#
      .SYNOPSIS
      Connect to an Aruba ClearPass

      .DESCRIPTION
      Connect to an Aruba ClearPass

      .EXAMPLE
      Connect-ArubaCP -Server 192.0.2.1 -client_id PowerArubaCP -client_secret MySecret

      Connect to an Aruba ClearPass with IP 192.0.2.1 using client_id PowerArubaCP and client_secret MySecret

      .EXAMPLE
      Connect-ArubaCP -Server 192.0.2.1 -token aaaaaaaaaaaaa

      Connect to an Aruba ClearPass with IP 192.0.2.1 using token aaaaaaa

      .EXAMPLE
      Connect-ArubaCP -Server 192.0.2.1 -token aaaaaaaaaaaaa -SkipCertificateCheck

      Connect to an Aruba ClearPass using HTTPS (without check certificate validation) with IP 192.0.2.1 using token aaaaaaa

      .EXAMPLE
      Connect-ArubaCP -Server 192.0.2.1 -token aaaaaaaaaaaaa -port 4443

      Connect to an Aruba ClearPass with IP 192.0.2.1 using token aaaaaaa on port 4443

      .EXAMPLE
      $cppm1 = Connect-ArubaCP -Server 192.0.2.1 -token aaaaaaaaaaaaa

      Connect to an ArubaOS ClaerPass with IP 192.0.2.1 and store connection info to $cppm1 variable

      .EXAMPLE
      $cppm2 = Connect-ArubaSW -Server 192.0.2.1 -token aaaaaaaaaaaaa -DefaultConnection:$false

      Connect to an ArubaOS Switch with IP 192.0.2.1 and store connection info to $cppm2 variable
      and don't store connection on global ($DefaultArubaCPConnection) variable
  #>

    Param(
        [Parameter(Mandatory = $true, position = 1)]
        [String]$Server,
        [Parameter(Mandatory = $false, ParameterSetName = "token")]
        [String]$token,
        [Parameter(Mandatory = $false, ParameterSetName = "client_credentials")]
        [String]$client_id,
        [Parameter(Mandatory = $false, ParameterSetName = "client_credentials")]
        [String]$client_secret,
        [Parameter(Mandatory = $false)]
        [switch]$SkipCertificateCheck = $false,
        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 65535)]
        [int]$port = 443,
        [Parameter(Mandatory = $false)]
        [boolean]$DefaultConnection = $true
    )

    Begin {
    }

    Process {

        $connection = @{server = ""; token = ""; invokeParams = "" ; version = "" ; port = $port }
        $invokeParams = @{DisableKeepAlive = $false; UseBasicParsing = $true; SkipCertificateCheck = $SkipCertificateCheck }

        if ("Desktop" -eq $PSVersionTable.PsEdition) {
            #Remove -SkipCertificateCheck from Invoke Parameter (not supported <= PS 5)
            $invokeParams.remove("SkipCertificateCheck")
        }
        else {
            #Core Edition
            #Remove -UseBasicParsing (Enable by default with PowerShell 6/Core)
            $invokeParams.remove("UseBasicParsing")
        }

        #for PowerShell (<=) 5 (Desktop), Enable TLS 1.1, 1.2 and Disable SSL chain trust (needed/recommanded by ClearPass)
        if ("Desktop" -eq $PSVersionTable.PsEdition) {
            #Enable TLS 1.1 and 1.2
            Set-ArubaCPCipherSSL
            if ($SkipCertificateCheck) {
                #Disable SSL chain trust...
                Set-ArubaCPuntrustedSSL
            }
        }

        #Try to oauth...
        if ($PSCmdlet.ParameterSetName -eq "client_credentials") {

            $oauth = @{
                grant_type    = 'client_credentials';
                client_id     = $client_id;
                client_secret = $client_secret;
            }

            $headers = @{ Accept = "application/json"; "Content-type" = "application/json" }
            $fullurl = "https://${Server}:${port}/api/oauth"
            $response = Invoke-RestMethod -uri $fullurl -Method "POST" -body ($oauth | ConvertTo-Json) -Headers $headers @invokeParams

            $token = $response.access_token
        }

        $connection.server = $server
        $connection.token = $token
        $connection.invokeParams = $invokeParams

        if ( $DefaultConnection ) {
            set-variable -name DefaultArubaCPConnection -value $connection -scope Global
        }

        $cv = Get-ArubaCPCPPMVersion -connection $connection
        $connection.version = [version]"$($cv.app_major_version).$($cv.app_minor_version).$($cv.app_service_release)"

        $connection
    }

    End {
    }
}

function Disconnect-ArubaCP {

    <#
        .SYNOPSIS
        Disconnect to a ArubaCP Switches

        .DESCRIPTION
        Disconnect the connection on Aruba ClearPass

        .EXAMPLE
        Disconnect-ArubaCP

        Disconnect the connection

        .EXAMPLE
        Disconnect-ArubaCP -confirm:$false

        Disconnect the connection with no confirmation

    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    Param(
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaCPConnection
    )

    Begin {
    }

    Process {

        if ($PSCmdlet.ShouldProcess($connection.server, 'Remove ClearPass connection ?')) {
            #Not really connection on CPPM with token
            if ( ($connection -eq $DefaultArubaCPCOnnection) -and (Test-Path variable:global:DefaultArubaCPConnection) ) {
                Remove-Variable -name DefaultArubaCPConnection -scope global
            }
        }

    }

    End {
    }
}
