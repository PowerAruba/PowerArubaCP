#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Get-ArubaCPGuest {

  <#
      .SYNOPSIS
      Get Guest account on Aruba ClearPass
      .DESCRIPTION
      Get Guest account on Aruba ClearPass
      .EXAMPLE
      Get-ArubaCPGuest
      Get all the guest accounts on Clearpass.
  #>

    Begin {
    }

    Process {

        $run = Invoke-ArubaCPRestMethod -method "get" -uri "api/guest"

        $guest = $run._embedded

        $guest.items 

    }

    End {
    }
}

function Add-ArubaCPGuest {

    <#
        .SYNOPSIS
        Add Guest account on Aruba ClearPass
        .DESCRIPTION
        Add Guest account on Aruba ClearPass
        .EXAMPLE
        Add-ArubaCPGuest -username -company -mail -role [-enable] [-expire]
        Add the guest account with parameters.
        .EXAMPLE
        Add-ArubaCPGuest -username matthew -company "Interstellar & Co" -mail matt.hew@matthew.com -role 2 -enable True
        Add the guest account matthew with company Interstellar & Co, e-mail matt.hew@matthew.com and role 2 (Guest) and enable it on Clearpass.
    #>

    Param(
        [Parameter(Mandatory = $true)]
        [String]$username,
        [Parameter(Mandatory = $true)]
        [String]$company,
        [Parameter(Mandatory = $true)]
        [String]$mail,
        [Parameter(Mandatory = $true)]
        [int]$role,
        [Parameter(Mandatory = $false)]
        [ValidateSet ("True", "False")]
        [string]$enable
    )

    Begin {
    }
  
    Process {

        $guest = new-Object -TypeName PSObject

        $guest | add-member -name "username" -membertype NoteProperty -Value $username

        $guest | add-member -name "visitor_company" -membertype NoteProperty -Value $company

        $guest | add-member -name "email" -membertype NoteProperty -Value $mail

        $guest | add-member -name "role_id" -membertype NoteProperty -Value $role
        
        if ( $PsBoundParameters.ContainsKey('enable'))
        {
            switch( $enable ) {
                True {
                    $enable = $true
                }
                False {
                    $enable = $false
                }
            }
            $guest | add-member -name "enabled" -membertype NoteProperty -Value $enable
        }

        $run = Invoke-ArubaCPRestMethod -method "post" -body $guest -uri "api/guest"

        $run
  
    }
  
    End {
    }
}

function Set-ArubaCPGuest {

    <#
        .SYNOPSIS
        Set information about a guest account.
        .DESCRIPTION
        Set information about a guest account based on his username on Aruba ClearPass.
        .EXAMPLE
        Set-ArubaCPGuest -username test [-company] [-mail] [-role (1/2/3)] [-enable (true/false)] [-expire (hour/day/week/month/year)]/
        Set the information of the guest user.
        .EXAMPLE
        Set-ArubaCPGuest -username matthew -enable true -expire hour
        Set the guest account matthew enable with an expire time of an hour.
    #>

    Param(
        [Parameter(Mandatory = $true)]
        [String]$username,
        [Parameter(Mandatory = $false)]
        [String]$company,
        [Parameter(Mandatory = $false)]
        [String]$mail,
        [Parameter(Mandatory = $false)]
        [ValidateRange (1,3)]
        [int]$role,
        [Parameter(Mandatory = $false)]
        [ValidateSet ("true", "false")]
        [string]$enable,
        [Parameter(Mandatory = $false)]
        [String]$expire
    )

    Begin {
    }

    Process {

        $guest = new-Object -TypeName PSObject

        $guest | add-member -name "username" -membertype NoteProperty -Value $username
        
        if ( $PsBoundParameters.ContainsKey('company'))
        {
            $guest | add-member -name "visitor_company" -membertype NoteProperty -Value $company
        }

        if ( $PsBoundParameters.ContainsKey('mail'))
        {
        $guest | add-member -name "email" -membertype NoteProperty -Value $mail
        }

        if ( $PsBoundParameters.ContainsKey('role'))
        {
        $guest | add-member -name "role_id" -membertype NoteProperty -Value $role
        }

        if ( $PsBoundParameters.ContainsKey('enable'))
        {
            switch( $enable ) {
                true {
                    $enable = $true
                }
                false {
                    $enable = $false
                }
            }
            $guest | add-member -name "enabled" -membertype NoteProperty -Value $enable
        }

        if ( $PsBoundParameters.ContainsKey('expire'))
        {   
            $time = Get-ArubaCPGuest | Where-Object username -eq $username

            if ($expire = "hour")
            {
                $expire = $time.start_time + 3600
            }

            if ($expire = "day")
            {
                $expire = $time.start_time + 86400
            }

            if ($expire = "week")
            {
                $expire = $time.start_time + 604800
            }

            if ($expire = "month")
            {
                $expire = $time.start_time + 2419200
            }

            if ($expire = "year")
            {
                $expire = $time.start_time + 29030400
            }

            $guest | add-member -name "expire_time" -membertype NoteProperty -Value $expire
        }

        $run = Invoke-ArubaCPRestMethod -method "patch" -body $guest -uri "api/username/${username}"

        $run
  
    }
  
    End {
    }
}