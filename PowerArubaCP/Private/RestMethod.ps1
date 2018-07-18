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
        #Valid POST, GET...
        [String]$method,
        [Parameter(Mandatory = $false)]
        [psobject]$body
    )

    Begin {
    }

    Process {

        $Server = ${DefaultArubaCPConnection}.Server
        $fullurl = "https://${Server}/${url}"


        $headers = @{ Authorization = "Bearer " + $DefaultArubaCPConnection.token; Accept = "application/json" }

        try {
            if($body){
                $response = Invoke-RestMethod $fullurl -Method $method -body ($body | ConvertTo-Json) -Headers $headers
            } else {
                $response = Invoke-RestMethod $fullurl -Method $method -Headers $headers
            }
        }

        catch {
            If ($_.Exception.Response) {

                $result = $_.Exception.Response.GetResponseStream()
                $reader = New-Object System.IO.StreamReader($result)
                $responseBody = $reader.ReadToEnd()
                $responseJson =  $responseBody | ConvertFrom-Json

                Write-Host "The ClearPass API sends an error message:" -foreground yellow
                Write-Host
                Write-Host "Error description (code): $($_.Exception.Response.StatusDescription) ($($_.Exception.Response.StatusCode.Value__))" -foreground yellow
                Write-Host "Error details: $($responseJson)" -foreground yellow
                Write-Host
            }
            throw "Unable to use ClearPass API"
        }
        $response

    }

}