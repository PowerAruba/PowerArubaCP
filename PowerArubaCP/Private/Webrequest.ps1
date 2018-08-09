#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Invoke-ArubaCPWebRequest(){

    Param(
        [Parameter(Mandatory = $true)]
        [String]$url,
        [Parameter(Mandatory = $true)]
        #Valid POST, GET...
        [String]$method,
        [Parameter(Mandatory = $false)]
        [psobject]$body,
        [Parameter(Mandatory = $false)]
        [Microsoft.PowerShell.Commands.WebRequestSession]$sessionvariable
    )

    Begin {
    }

    Process {

        $Server = ${DefaultArubaCPConnection}.Server
        $fullurl = "https://${Server}/${url}"


        if( -Not $PsBoundParameters.ContainsKey('sessionvariable') ){
            $sessionvariable = $DefaultArubaCPConnection.session
        }

        #When headers, We need to have Accept and Content-type set to application/json...
        $headers = @{ Authorization = "Bearer " + $DefaultArubaCPConnection.token; Accept = "application/json"; "Content-type" = "application/json" }

        try {
            if($body){
                $response = Invoke-WebRequest $fullurl -Method $method -body ($body | ConvertTo-Json) -Headers $headers
            } else {
                $response = Invoke-WebRequest $fullurl -Method $method -Headers $headers
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
                Write-Host "Error details: $($responseBody)" -foreground yellow
                Write-Host
            }
            throw "Unable to use ClearPass API"
        }
        $response

    }

}