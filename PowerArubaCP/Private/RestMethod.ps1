#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Invoke-ArubaCPRestMethod(){

    Param(
        [Parameter(Mandatory = $true)]
        [String]$url,
        [Parameter(Mandatory = $true)]
        [ValidateSet("GET", "PUT", "POST", "DELETE")]
        [String]$method,
        [Parameter(Mandatory = $false)]
        [psobject]$body
    )

    Begin {
    }

    Process {

        $Server = ${DefaultArubaCPConnection}.Server
        $fullurl = "https://${Server}/${url}"

        #When headers, We need to have Accept and Content-type set to application/json...
        $headers = @{ Authorization = "Bearer " + $DefaultArubaCPConnection.token; Accept = "application/json"; "Content-type" = "application/json" }

        try {
            if($body){
                $response = Invoke-RestMethod $fullurl -Method $method -body ($body | ConvertTo-Json) -Headers $headers
            } else {
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