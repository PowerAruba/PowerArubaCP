#
# Copyright 2018-2020, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Add-ArubaCPApplicationLicense {

    <#
        .SYNOPSIS
        Add Application License info on CPPM

        .DESCRIPTION
        Add Application License (Id, Name, Type, user Count...)

        .EXAMPLE
        Add-ArubaCPApplicationLicense -product_name Access -license_key XXXXXXX

        Add a Application licence type Access with licence key XXXXXXX

    #>

    Param(
        [Parameter (Mandatory = $false)]
        [ValidateSet('Access', 'Access Upgrade', 'Entry', 'Onboard', 'OnGuard', IgnoreCase = $false)]
        [string]$product_name,
        [Parameter (Mandatory = $false)]
        [string]$license_key
    )

    Begin {
    }

    Process {

        $url = "api/application-license"

        $_al = New-Object psobject

        $_al | Add-Member -name "product_name" -MemberType NoteProperty -Value $product_name

        $_al | Add-Member -name "license_key" -MemberType NoteProperty -Value $license_key

        $al = Invoke-ArubaCPRestMethod -method "POST" -body $_al -uri $url

        $al
    }

    End {
    }
}

function Get-ArubaCPApplicationLicense {

    <#
        .SYNOPSIS
        Get Application License info on CPPM

        .DESCRIPTION
        Get Application License (Id, Name, Type, user Count...)

        .EXAMPLE
        Get-ArubaCPApplicationLicense

        Get ALL Application License  on the Clearpass

        .EXAMPLE
        Get-ArubaCPApplicationLicense -id 3001

        Get info about Application License where id equal 3001

        .EXAMPLE
        Get-ArubaCPApplicationLicense -product_name Access

        Get info about Application License where product_name is Access

        .EXAMPLE
        Get-ArubaCPApplicationLicense -license_type Evaluation

        Get info about Application License where license type is Evaluation

    #>

    [CmdLetBinding(DefaultParameterSetName = "Default")]

    Param(
        [Parameter (Mandatory = $false, ParameterSetName = "id")]
        [int]$id,
        [Parameter (Mandatory = $false, ParameterSetName = "product_name")]
        [ValidateSet('Access', 'Access Upgrade', 'Entry', 'Onboard', 'OnGuard', IgnoreCase = $false)]
        [string]$product_name,
        [Parameter (Mandatory = $false, ParameterSetName = "license_type")]
        [ValidateSet('Evaluation', 'Permanent', IgnoreCase = $false)]
        [string]$license_type
    )

    Begin {
    }

    Process {

        $url = "api/application-license"

        $al = Invoke-ArubaCPRestMethod -method "GET" -uri $url

        switch ( $PSCmdlet.ParameterSetName ) {
            "id" { $al._embedded.items | Where-Object { $_.id -eq $id } }
            "product_name" { $al._embedded.items | Where-Object { $_.product_name -eq $product_name } }
            "license_type" { $al._embedded.items | Where-Object { $_.license_type -eq $license_type } }
            default { $al._embedded.items }
        }
    }

    End {
    }
}

function Remove-ArubaCPApplicationLicense {

    <#
        .SYNOPSIS
        Remove an Application License on ClearPass

        .DESCRIPTION
        Remove an Application License) on ClearPass

        .EXAMPLE
        $al = Get-ArubaCPApplicationLicense -product_name Access
        PS C:\>$al | Remove-ArubaCPApplicationLicense

        Remove Application License type Access

        .EXAMPLE
        Remove-ArubaCPApplicationLicense -id 3001 -noconfirm

        Remove Application License id 3001 with no confirmation
    #>

    Param(
        [Parameter (Mandatory = $true, ParameterSetName = "id")]
        [int]$id,
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "al")]
        [ValidateScript( { Confirm-ArubaCPApplicationLicense $_ })]
        [psobject]$al,
        [Parameter(Mandatory = $false)]
        [switch]$noconfirm
    )

    Begin {
    }

    Process {

        #get nad id from nad ps object
        if ($al) {
            $id = $al.id
        }

        $url = "api/application-license/${id}"

        if ( -not ( $Noconfirm )) {
            $message = "Remove Application License on ClearPass"
            $question = "Proceed with removal of Application License ${id} ?"
            $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
            $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
            $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))

            $decision = $Host.UI.PromptForChoice($message, $question, $choices, 1)
        }
        else { $decision = 0 }
        if ($decision -eq 0) {
            Write-Progress -activity "Remove Application License"
            Invoke-ArubaCPRestMethod -method "DELETE" -uri $url
            Write-Progress -activity "Remove Application License" -completed
        }
    }

    End {
    }
}