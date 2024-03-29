
#
# Copyright 2018, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
function Show-ArubaCPException() {
    Param(
        [parameter(Mandatory = $true)]
        $Exception
    )

    #Check if certificate is valid
    if ($Exception.Exception.InnerException) {
        $exceptiontype = $Exception.Exception.InnerException.GetType()
        if ("AuthenticationException" -eq $exceptiontype.name) {
            Write-Warning "Invalid certificat (Untrusted, wrong date, invalid name...)"
            Write-Warning "Try to use Connect-ArubaCP -SkipCertificateCheck for connection"
            throw "Unable to connect (certificate)"
        }
    }

    If ($Exception.Exception.Response) {
        if ("Desktop" -eq $PSVersionTable.PSEdition) {
            $result = $Exception.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($result)
            $responseBody = $reader.ReadToEnd()
            $responseJson = $responseBody | ConvertFrom-Json
            $code = $Exception.Exception.Response.StatusDescription
        }
        else {
            $code = $Exception.Exception.Response.ReasonPhrase
        }

        Write-Warning "The ClearPass API sends an error message:"
        Write-Warning "Error description (code): $($code) ($($Exception.Exception.Response.StatusCode.Value__))"
        if ($responseBody) {
            if ($responseJson.message) {
                Write-Warning "Error details: $($responseJson.message)"
            }
            else {
                Write-Warning "Error details: $($responseBody)"
            }
        }
        elseif ($Exception.ErrorDetails.Message) {
            $ErrorDetails = $Exception.ErrorDetails.Message | ConvertFrom-Json
            if ($ErrorDetails.detail) {
                Write-Warning "Error details: $($ErrorDetails.detail)"
            }
            else {
                Write-Warning "Error details: $($Exception.ErrorDetails.Message)"
            }

        }
    }
}