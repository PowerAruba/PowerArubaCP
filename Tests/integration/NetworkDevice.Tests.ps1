#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

BeforeAll {
    Connect-ArubaCP @invokeParams
}

Describe "Get Network Device" {

    BeforeAll {
        #Add 2 entries
        Add-ArubaCPNetworkDevice -name pester_SW1 -ip_address 192.0.2.1 -radius_secret MySecurePassword -vendor Aruba -description "Add by PowerArubaCP"
        Add-ArubaCPNetworkDevice -name pester_SW2 -ip_address 192.0.2.2 -radius_secret MySecurePassword -vendor Hewlett-Packard-Enterprise -description "Add by PowerArubaCP"
    }

    It "Get NetworkDevice Does not throw an error" {
        {
            Get-ArubaCPNetworkDevice
        } | Should -Not -Throw
    }

    It "Get ALL Network Device" {
        $nad = Get-ArubaCPNetworkDevice
        $nad.count | Should -Not -Be $NULL
    }

    It "Get Network Device (pester_SW1)" {
        $nad = Get-ArubaCPNetworkDevice | Where-Object { $_.name -eq "pester_SW1" }
        $nad.id | Should -Not -Be BeNullOrEmpty
        $nad.name | Should -Be "pester_SW1"
        $nad.description | Should -Be "Add by PowerArubaCP"
        $nad.ip_address | Should -Be "192.0.2.1"
        $nad.vendor_name | Should -Be "Aruba"
        $nad.coa_capable | Should -Be "False"
        $nad.coa_port | Should -Be "3799"
    }

    It "Get Network Device (pester_SW1) and confirm (via Confirm-ArubaCPNetworkDevice)" {
        $nad = Get-ArubaCPNetworkDevice | Where-Object { $_.name -eq "pester_SW1" }
        Confirm-ArubaCPNetworkDevice $nad | Should -Be $true
    }

    It "Search Network Device by name (pester_SW2)" {
        $nad = Get-ArubaCPNetworkDevice -name pester_SW2
        @($nad).count | Should -Be 1
        $nad.id | Should -Not -Be BeNullOrEmpty
        $nad.name | Should -Be "pester_SW2"
        $nad.description | Should -Be "Add by PowerArubaCP"
    }

    It "Search Network Device by name (contains *pester*)" {
        $nad = Get-ArubaCPNetworkDevice -name pester -filter_type contains
        @($nad).count | Should -Be 2
    }

    It "Search Network Device by attribute (ip_address equal 192.0.2.1)" {
        $nad = Get-ArubaCPNetworkDevice -filter_attribute ip_address -filter_type equal -filter_value 192.0.2.1
        @($nad).count | Should -Be 1
        $nad.ip_address | Should -Be "192.0.2.1"
    }

    AfterAll {
        #Remove 2 entries
        Get-ArubaCPNetworkDevice -name pester_SW1 | Remove-ArubaCPNetworkDevice -confirm:$false
        Get-ArubaCPNetworkDevice -name pester_SW2 | Remove-ArubaCPNetworkDevice -confirm:$false
    }
}

Describe "Add Network Device" {

    It "Add Network Device with Coa Enable and Change Port" {
        Add-ArubaCPNetworkDevice -name pester_SW1 -ip_address 192.0.2.1 -radius_secret MySecurePassword -vendor Aruba -coa_capable -coa_port 5000
        $nad = Get-ArubaCPNetworkDevice -name pester_SW1
        $nad.id | Should -Not -Be BeNullOrEmpty
        $nad.name | Should -Be "pester_SW1"
        $nad.ip_address | Should -Be "192.0.2.1"
        $nad.vendor_name | Should -Be "Aruba"
        $nad.coa_capable | Should -Be "true"
        $nad.coa_port | Should -Be "5000"
    }

    It "Add Network Device with TACACS secret (and Cisco vendor)" {
        Add-ArubaCPNetworkDevice -name pester_SW1 -ip_address 192.0.2.1 -radius_secret MySecurePassword -vendor Cisco -tacacs_secret MySecurePassword
        $nad = Get-ArubaCPNetworkDevice -name pester_SW1
        $nad.id | Should -Not -Be BeNullOrEmpty
        $nad.name | Should -Be "pester_SW1"
        $nad.ip_address | Should -Be "192.0.2.1"
        $nad.vendor_name | Should -Be "Cisco"
        # radius_secret and tacacs_secret are always empty...
    }

    #Disable... need to check release version and some change with last 6.8 release... need to configure RadSec Settings...
    #It "Add Network Device with RadSec" {
    #    Add-ArubaCPNetworkDevice -name pester_SW1 -ip_address 192.0.2.1 -radius_secret MySecurePassword -vendor Aruba -radsec_enabled
    #    $nad = Get-ArubaCPNetworkDevice -name pester_SW1
    #    $nad.id | Should -Not -Be BeNullOrEmpty
    #    $nad.name | Should -Be "pester_SW1"
    #    $nad.ip_address | Should -Be "192.0.2.1"
    #    $nad.vendor_name | Should -Be "Aruba"
    #    $nad.radsec_enabled | Should -Be true
    #}

    It "Add Network Device with 1 attribute (Location)" {
        Add-ArubaCPNetworkDevice -name pester_SW1 -ip_address 192.0.2.1 -radius_secret MySecurePassword -vendor Aruba -attributes @{ "Location" = "PowerArubaCP" }
        $nad = Get-ArubaCPNetworkDevice -name pester_SW1
        $nad.id | Should -Not -Be BeNullOrEmpty
        $nad.name | Should -Be "pester_SW1"
        $nad.ip_address | Should -Be "192.0.2.1"
        $nad.vendor_name | Should -Be "Aruba"
        ($nad.attributes | Get-Member -MemberType NoteProperty).count | Should -Be "1"
        ($nad.attributes).Location | Should -Be "PowerArubaCP"
    }

    It "Add Network Device with 2 attributes (Location and syslocation)" {
        Add-ArubaCPNetworkDevice -name pester_SW1 -ip_address 192.0.2.1 -radius_secret MySecurePassword -vendor Aruba -attributes @{ "Location" = "PowerArubaCP"; "syslocation" = "PowerArubaCP" }
        $nad = Get-ArubaCPNetworkDevice -name pester_SW1
        $nad.id | Should -Not -Be BeNullOrEmpty
        $nad.name | Should -Be "pester_SW1"
        $nad.ip_address | Should -Be "192.0.2.1"
        $nad.vendor_name | Should -Be "Aruba"
        ($nad.attributes | Get-Member -MemberType NoteProperty).count | Should -Be "2"
        ($nad.attributes).Location | Should -Be "PowerArubaCP"
        ($nad.attributes).syslocation | Should -Be "PowerArubaCP"
    }


    AfterEach {
        Get-ArubaCPNetworkDevice -name pester_SW1 | Remove-ArubaCPNetworkDevice -confirm:$false
    }
}

Describe "Configure Network Device" {
    BeforeEach {
        #Add 1 entry
        Add-ArubaCPNetworkDevice -name pester_SW1 -ip_address 192.0.2.1 -radius_secret MySecurePassword -vendor Aruba -description "Add by PowerArubaCP"
    }

    It "Rename Network Device (pester_SW1 => pester_SW2) and description" {
        Get-ArubaCPNetworkDevice -name pester_SW1 | Set-ArubaCPNetworkDevice -name pester_SW2 -description "Modified by PowerArubaCP"
        $nad = Get-ArubaCPNetworkDevice -name pester_SW2
        $nad.id | Should -Not -Be BeNullOrEmpty
        $nad.name | Should -Be "pester_SW2"
        $nad.description | Should -Be "Modified by PowerArubaCP"
        $nad.ip_address | Should -Be "192.0.2.1"
        $nad.vendor_name | Should -Be "Aruba"
        $nad.coa_capable | Should -Be "false"
        $nad.coa_port | Should -Be "3799"
    }

    It "Reconfigure Network Device (Change ip_address => 192.0.2.2 and Vendor => HPE)" {
        Get-ArubaCPNetworkDevice -name pester_SW1 | Set-ArubaCPNetworkDevice -ip_address 192.0.2.2 -vendor "Hewlett-Packard-Enterprise"
        $nad = Get-ArubaCPNetworkDevice -name pester_SW1
        $nad.id | Should -Not -Be BeNullOrEmpty
        $nad.ip_address | Should -Be "192.0.2.2"
        $nad.vendor_name | Should -Be "Hewlett-Packard-Enterprise"
    }

    It "Reconfigure Network Device (Enable COA and Change COA Port to 6000)" {
        Get-ArubaCPNetworkDevice -name pester_SW1 | Set-ArubaCPNetworkDevice -coa_capable -coa_port 6000
        $nad = Get-ArubaCPNetworkDevice -name pester_SW1
        $nad.id | Should -Not -Be BeNullOrEmpty
        $nad.coa_capable | Should -Be "true"
        $nad.coa_port | Should -Be "6000"
    }

    It "Reconfigure Network Device (Change RADIUS and TACACS secret)" {
        Get-ArubaCPNetworkDevice -name pester_SW1 | Set-ArubaCPNetworkDevice -radius_secret MySecurePassword -tacacs_secret MySecurePassword
        $nad = Get-ArubaCPNetworkDevice -name pester_SW1
        $nad.id | Should -Not -Be BeNullOrEmpty
        # radius_secret and tacacs_secret are always empty...
    }

    #Disable... need to check release version and some change with last 6.8 release... need to configure RadSec Settings...
    #It "Reconfigre Network Device (Enable RadSec)" {
    #    Get-ArubaCPNetworkDevice -name pester_SW1 | Set-ArubaCPNetworkDevice -radsec_enabled
    #    $nad = Get-ArubaCPNetworkDevice -name pester_SW1
    #    $nad.id | Should -Not -Be BeNullOrEmpty
    #    $nad.radsec_enabled | Should -Be true
    #}

    It "Change Attribute Network Device (Set 1 Attribute)" {
        Get-ArubaCPNetworkDevice -name pester_SW1 | Set-ArubaCPNetworkDevice -attributes @{ "Location" = "PowerArubaCP" }
        $nad = Get-ArubaCPNetworkDevice -name pester_SW1
        $nad.id | Should -Not -Be BeNullOrEmpty
        ($nad.attributes | Get-Member -MemberType NoteProperty).count | Should -Be "1"
        $nad.attributes.location | Should -Be "PowerArubaCP"
    }

    It "Change Attribute Network Device (Set 2 Attributes)" {
        Get-ArubaCPNetworkDevice -name pester_SW1 | Set-ArubaCPNetworkDevice -attributes @{ "Location" = "PowerArubaCP" ; "syslocation" = "Pester" }
        $nad = Get-ArubaCPNetworkDevice -name pester_SW1
        $nad.id | Should -Not -Be BeNullOrEmpty
        ($nad.attributes | Get-Member -MemberType NoteProperty).count | Should -Be "2"
        $nad.attributes.location | Should -Be "PowerArubaCP"
        $nad.attributes.syslocation | Should -Be "Pester"
    }

    It "Change Attribute Network Device (Set 1 Attribute with 1 Attribute before)" {
        Get-ArubaCPNetworkDevice -name pester_SW1 | Set-ArubaCPNetworkDevice -attributes @{ "Location" = "PowerArubaCP" }
        Get-ArubaCPNetworkDevice -name pester_SW1 | Set-ArubaCPNetworkDevice -attributes @{ "syslocation" = "Pester" }
        $nad = Get-ArubaCPNetworkDevice -name pester_SW1
        $nad.id | Should -Not -Be BeNullOrEmpty
        #Should Be Replace ? and not add ??
        ($nad.attributes | Get-Member -MemberType NoteProperty).count | Should -Be "2"
        $nad.attributes.location | Should -Be "PowerArubaCP"
        $nad.attributes.syslocation | Should -Be "Pester"
    }

    AfterEach {
        Get-ArubaCPNetworkDevice -name pester_SW1 | Remove-ArubaCPNetworkDevice -confirm:$false
        Get-ArubaCPNetworkDevice -name pester_SW2 | Remove-ArubaCPNetworkDevice -confirm:$false
    }
}

Describe "Attribute Network Device" {

    Context "Add Network Device Attribute" {
        BeforeEach {
            #Add 1 entry
            Add-ArubaCPNetworkDevice -name pester_SW1 -ip_address 192.0.2.1 -radius_secret MySecurePassword -vendor Aruba -description "Add by PowerArubaCP"
        }

        It "Add Attribute Network Device (Add 1 attribute with hashtable)" {
            Get-ArubaCPNetworkDevice -name pester_SW1 | Add-ArubaCPAttributesMember -attributes @{ "Location" = "PowerArubaCP" }
            $nad = Get-ArubaCPNetworkDevice -name pester_SW1
            $nad.id | Should -Not -Be BeNullOrEmpty
            $nad.name | Should -Be "pester_SW1"
            $nad.ip_address | Should -Be "192.0.2.1"
            $nad.vendor_name | Should -Be "Aruba"
            ($nad.attributes | Get-Member -MemberType NoteProperty).count | Should -Be "1"
            ($nad.attributes).Location | Should -Be "PowerArubaCP"
        }

        It "Add Attribute Network Device (Add 2 attributes with hashtable)" {
            Get-ArubaCPNetworkDevice -name pester_SW1 | Add-ArubaCPAttributesMember -attributes @{ "Location" = "PowerArubaCP"; "syslocation" = "Pester" }
            $nad = Get-ArubaCPNetworkDevice -name pester_SW1
            $nad.id | Should -Not -Be BeNullOrEmpty
            $nad.name | Should -Be "pester_SW1"
            $nad.ip_address | Should -Be "192.0.2.1"
            $nad.vendor_name | Should -Be "Aruba"
            ($nad.attributes | Get-Member -MemberType NoteProperty).count | Should -Be "2"
            ($nad.attributes).Location | Should -Be "PowerArubaCP"
            ($nad.attributes).syslocation | Should -Be "Pester"
        }

        It "Add Attribute Network Device (Add 1 Attribute with 1 Attribute before with hashtable)" {
            Get-ArubaCPNetworkDevice -name pester_SW1 | Add-ArubaCPAttributesMember -attributes @{ "Location" = "PowerArubaCP"; }
            Get-ArubaCPNetworkDevice -name pester_SW1 | Add-ArubaCPAttributesMember -attributes @{ "syslocation" = "Pester" }
            $nad = Get-ArubaCPNetworkDevice -name pester_SW1
            $nad.id | Should -Not -Be BeNullOrEmpty
            $nad.name | Should -Be "pester_SW1"
            $nad.ip_address | Should -Be "192.0.2.1"
            $nad.vendor_name | Should -Be "Aruba"
            ($nad.attributes | Get-Member -MemberType NoteProperty).count | Should -Be "2"
            ($nad.attributes).Location | Should -Be "PowerArubaCP"
            ($nad.attributes).syslocation | Should -Be "Pester"
        }

        It "Add Attribute Network Device (Add 1 attribute with name/value)" {
            Get-ArubaCPNetworkDevice -name pester_SW1 | Add-ArubaCPAttributesMember -name "Location" -value "PowerArubaCP"
            $nad = Get-ArubaCPNetworkDevice -name pester_SW1
            $nad.id | Should -Not -Be BeNullOrEmpty
            $nad.name | Should -Be "pester_SW1"
            $nad.ip_address | Should -Be "192.0.2.1"
            $nad.vendor_name | Should -Be "Aruba"
            ($nad.attributes | Get-Member -MemberType NoteProperty).count | Should -Be "1"
            ($nad.attributes).Location | Should -Be "PowerArubaCP"
        }

        It "Add Attribute Network Device (Add 2 attributes with hashtable)" {
            Get-ArubaCPNetworkDevice -name pester_SW1 | Add-ArubaCPAttributesMember -name "Location", syslocation -value "PowerArubaCP", Pester
            $nad = Get-ArubaCPNetworkDevice -name pester_SW1
            $nad.id | Should -Not -Be BeNullOrEmpty
            $nad.name | Should -Be "pester_SW1"
            $nad.ip_address | Should -Be "192.0.2.1"
            $nad.vendor_name | Should -Be "Aruba"
            ($nad.attributes | Get-Member -MemberType NoteProperty).count | Should -Be "2"
            ($nad.attributes).Location | Should -Be "PowerArubaCP"
            ($nad.attributes).syslocation | Should -Be "Pester"
        }

        It "Add Attribute Network Device (Add 1 Attribute with 1 Attribute before with hashtable)" {
            Get-ArubaCPNetworkDevice -name pester_SW1 | Add-ArubaCPAttributesMember -name "Location" -value "PowerArubaCP"
            Get-ArubaCPNetworkDevice -name pester_SW1 | Add-ArubaCPAttributesMember -name syslocation -value Pester
            $nad = Get-ArubaCPNetworkDevice -name pester_SW1
            $nad.id | Should -Not -Be BeNullOrEmpty
            $nad.name | Should -Be "pester_SW1"
            $nad.ip_address | Should -Be "192.0.2.1"
            $nad.vendor_name | Should -Be "Aruba"
            ($nad.attributes | Get-Member -MemberType NoteProperty).count | Should -Be "2"
            ($nad.attributes).Location | Should -Be "PowerArubaCP"
            ($nad.attributes).syslocation | Should -Be "Pester"
        }

        AfterEach {
            Get-ArubaCPNetworkDevice -name pester_SW1 | Remove-ArubaCPNetworkDevice -confirm:$false
        }

    }

    Context "Set Network Device Attribute" {
        BeforeEach {
            #Add 1 entry
            Add-ArubaCPNetworkDevice -name pester_SW1 -ip_address 192.0.2.1 -radius_secret MySecurePassword -vendor Aruba -description "Add by PowerArubaCP"
        }

        It "Set Attribute Network Device (Set 1 Attribute with hashtable)" {
            Get-ArubaCPNetworkDevice -name pester_SW1 | Set-ArubaCPAttributesMember -attributes @{ "Location" = "PowerArubaCP" }
            $nad = Get-ArubaCPNetworkDevice -name pester_SW1
            $nad.id | Should -Not -Be BeNullOrEmpty
            ($nad.attributes | Get-Member -MemberType NoteProperty).count | Should -Be "1"
            $nad.attributes.location | Should -Be "PowerArubaCP"
        }

        It "Set Attribute Network Device (Set 2 Attributes with hashtable)" {
            Get-ArubaCPNetworkDevice -name pester_SW1 | Set-ArubaCPAttributesMember -attributes @{ "Location" = "PowerArubaCP" ; "syslocation" = "Pester" }
            $nad = Get-ArubaCPNetworkDevice -name pester_SW1
            $nad.id | Should -Not -Be BeNullOrEmpty
            ($nad.attributes | Get-Member -MemberType NoteProperty).count | Should -Be "2"
            $nad.attributes.location | Should -Be "PowerArubaCP"
            $nad.attributes.syslocation | Should -Be "Pester"
        }

        It "Set Attribute Network Device (Set 1 Attribute with 1 Attribute before with hashtable)" {
            Get-ArubaCPNetworkDevice -name pester_SW1 | Set-ArubaCPAttributesMember -attributes @{ "Location" = "PowerArubaCP" }
            Get-ArubaCPNetworkDevice -name pester_SW1 | Set-ArubaCPAttributesMember -attributes @{ "syslocation" = "Pester" }
            $nad = Get-ArubaCPNetworkDevice -name pester_SW1
            $nad.id | Should -Not -Be BeNullOrEmpty
            ($nad.attributes | Get-Member -MemberType NoteProperty).count | Should -Be "1"
            $nad.attributes.syslocation | Should -Be "Pester"
        }

        It "Set Attribute Network Device (Set 1 Attribute with name/value)" {
            Get-ArubaCPNetworkDevice -name pester_SW1 | Set-ArubaCPAttributesMember -name "Location" -value "PowerArubaCP"
            $nad = Get-ArubaCPNetworkDevice -name pester_SW1
            $nad.id | Should -Not -Be BeNullOrEmpty
            ($nad.attributes | Get-Member -MemberType NoteProperty).count | Should -Be "1"
            $nad.attributes.location | Should -Be "PowerArubaCP"
        }

        It "Set Attribute Network Device (Set 2 Attributes with name/value)" {
            Get-ArubaCPNetworkDevice -name pester_SW1 | Set-ArubaCPAttributesMember -name "Location", syslocation -value "PowerArubaCP", Pester
            $nad = Get-ArubaCPNetworkDevice -name pester_SW1
            $nad.id | Should -Not -Be BeNullOrEmpty
            ($nad.attributes | Get-Member -MemberType NoteProperty).count | Should -Be "2"
            $nad.attributes.location | Should -Be "PowerArubaCP"
            $nad.attributes.syslocation | Should -Be "Pester"
        }

        It "Set Attribute Network Device (Set 1 Attribute with 1 Attribute before with name/value)" {
            Get-ArubaCPNetworkDevice -name pester_SW1 | Set-ArubaCPAttributesMember -name "Location" -value "PowerArubaCP"
            Get-ArubaCPNetworkDevice -name pester_SW1 | Set-ArubaCPAttributesMember -name syslocation -value Pester
            $nad = Get-ArubaCPNetworkDevice -name pester_SW1
            $nad.id | Should -Not -Be BeNullOrEmpty
            ($nad.attributes | Get-Member -MemberType NoteProperty).count | Should -Be "1"
            $nad.attributes.syslocation | Should -Be "Pester"
        }

        AfterEach {
            Get-ArubaCPNetworkDevice -name pester_SW1 | Remove-ArubaCPNetworkDevice -confirm:$false
        }

    }

    Context "Remove Network Device Attributes" {

        BeforeEach {
            #Add 1 entry
            Add-ArubaCPNetworkDevice -name pester_SW1 -ip_address 192.0.2.1 -radius_secret MySecurePassword -vendor Aruba -description "Add by PowerArubaCP" -attributes @{ "Location" = "PowerArubaCP" ; "syslocation" = "Pester" }
        }

        It "Remove Attribute Local User (Remove 1 Attribute with 2 before)" {
            Get-ArubaCPNetworkDevice -name pester_SW1 | Remove-ArubaCPAttributesMember -name "Location"
            $nad = Get-ArubaCPNetworkDevice -name pester_SW1
            $nad.id | Should -Not -Be BeNullOrEmpty
            ($nad.attributes | Get-Member -MemberType NoteProperty).count | Should -Be "1"
            $nad.attributes.syslocation | Should -Be "Pester"
        }

        <#Bug ?! get 'No Tag definition specified for this tag value' when remove ALL attributes
        It "Remove Attribute Local User (Remove 2 Attributes with 2 before)" {
            Get-ArubaCPNetworkDevice -name pester_SW1 | Remove-ArubaCPAttributesMember -name Location, syslocation
            $nad = Get-ArubaCPNetworkDevice -name pester_SW1
            $nad.id | Should -Not -Be BeNullOrEmpty
            ($nad.attributes | Get-Member -MemberType NoteProperty).count | Should -Be "0"
        }
        #>

        AfterEach {
            Get-ArubaCPNetworkDevice -name pester_SW1 | Remove-ArubaCPNetworkDevice -confirm:$false
        }

    }

}

Describe "Remove Network Device" {

    It "Remove Network Device by id" {
        Add-ArubaCPNetworkDevice -name pester_SW1 -ip_address 192.0.2.1 -radius_secret MySecurePassword -vendor Aruba
        $nad = Get-ArubaCPNetworkDevice -name pester_SW1
        $nad.name | Should -Be "pester_SW1"
        @($nad).count | Should -Be 1
        Remove-ArubaCPNetworkDevice -id $nad.id -confirm:$false
        $nad = Get-ArubaCPNetworkDevice -name pester_SW1
        $nad | Should -BeNullOrEmpty
        @($nad).count | Should -Be 0
    }

    It "Remove Network Device by name (and pipeline)" {
        Add-ArubaCPNetworkDevice -name pester_SW1 -ip_address 192.0.2.1 -radius_secret MySecurePassword -vendor Aruba
        $nad = Get-ArubaCPNetworkDevice -name pester_SW1
        $nad.name | Should -Be "pester_SW1"
        @($nad).count | Should -Be 1
        Get-ArubaCPNetworkDevice -name pester_SW1 | Remove-ArubaCPNetworkDevice -confirm:$false
        $nad = Get-ArubaCPNetworkDevice -name pester_SW1
        $nad | Should -BeNullOrEmpty
        @($nad).count | Should -Be 0
    }

    AfterEach {
        Get-ArubaCPNetworkDevice -name pester_SW1 | Remove-ArubaCPNetworkDevice -confirm:$false
    }
}

AfterAll {
    Disconnect-ArubaCP -confirm:$false
}