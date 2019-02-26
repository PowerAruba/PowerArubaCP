#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Invoke-ArubaCPRestMethod {

    <#
      .SYNOPSIS
      Invoke RestMethod with ArubaCP connection (internal) variable

      .DESCRIPTION
       Invoke RestMethod with ArubaCP connection variable (token, csrf..)

      .EXAMPLE
      Invoke-ArubaCPRestMethod -method "get" -uri "api/cppm-version"

      Invoke-RestMethod with ArubaCP connection for get api/cppm-version

      .EXAMPLE
      Invoke-ArubaCPRestMethod "api/cppm-version"

      Invoke-RestMethod with ArubaCP connection for get api/cppm-version uri with default GET method parameter

      .EXAMPLE
      Invoke-ArubaCPRestMethod -method "post" -uri "api/cppm-version" -body $body

      Invoke-RestMethod with ArubaCP connection for post api/cppm-version uri with $body payload
    #>

    Param(
        [Parameter(Mandatory = $true, position = 1)]
        [String]$uri,
        [Parameter(Mandatory = $false)]
        [ValidateSet("GET", "PUT", "POST", "DELETE", "PATCH")]
        [String]$method = "GET",
        [Parameter(Mandatory = $false)]
        [psobject]$body
    )

    Begin {
    }

    Process {

        $Server = ${DefaultArubaCPConnection}.Server
        $fullurl = "https://${Server}/${uri}"

        #When headers, We need to have Accept and Content-type set to application/json...
        $headers = @{ Authorization = "Bearer " + $DefaultArubaCPConnection.token; Accept = "application/json"; "Content-type" = "application/json" }

        try {
            if ($body) {
                $response = Invoke-RestMethod $fullurl -Method $method -body ($body | ConvertTo-Json) -Headers $headers
            }
            else {
                $response = Invoke-RestMethod $fullurl -Method $method -Headers $headers
            }
        }

        catch {
            If ($_.ErrorDetails) {

                $error = $_.ErrorDetails.Message | ConvertFrom-Json

                Write-Warning "The ClearPass API sends an error message:`n"
                Write-Warning "Error description (code): $($error.title) ($($error.status))"
                Write-Warning "Error details: $($error.detail)"

            }
            throw "Unable to use ClearPass API"
        }
        $response

    }

}
