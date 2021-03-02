#
# Copyright 2021, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
# Copyright 2021, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Deploy-ArubaCPVm {

    <#
        .SYNOPSIS
        Deploy a ClearPass VM

        .DESCRIPTION
        Deploy a Virtual Machine ClearPass on a vSphere environment with a lot of parameters like the choice of the cluster, the datastore, and the host. You can even preconfigure your VM with the network configuration, the hostname, and the dns.

        .EXAMPLE
        Deploy-ArubaCPVm -ovf_path "D:\ISO\CPPM-VM-x86_64-6.9.0.130064-ESX\CPPM-VM-x86_64-6.9.0.130064-ESX.ovf" -vm_Host "host_PowerarubaCP-01" -datastore "datastore_powerarubacp-01" -cluster "cluster_powerarubacp-01" -name_vm "CPPM" -vmnetwork1 "CPPM - MGMT" -vmnetwork2 "CPPM - DATA"

        This install your .ovf on your vsphere with the host, the datastore, the cluster, the folder to place it and the name of your vm. It also configure your vm with a hostname, a network configuration, the network adapter and the port group of your vSwitch

        .EXAMPLE
        $cppmBuildParams = @{
            ovf_path                    = "D:\ISO\CPPM-VM-x86_64-6.9.0.130064-ESX\CPPM-VM-x86_64-6.9.0.130064-ESX.ovf"
            vm_host                     = "host_PowerarubaCP-01"
            datastore                   = "datastore_powerarubacp-01"
            cluster                     = "cluster_powerarubacp-01"
            inventory                   = "PowerArubaCP"
            name_vm                     = "CPPM"
            capacityGB                  = "80" #Minimum size for LAB
            memoryGB                    = "8" #Default value
            cpu                         = "8" #Default value
            StartVM                     = $true
            vmnetwork1                  = "CPPM - MGMT"
            vmnetwork2                  = "CPPM - DATA"
        }  # end $cppmBuildParams

        PS>Deploy-ArubaCPVm @cppmBuildParams

        Deploy Aruba ClearPass VM by pass array with settings.
    #>

    Param(
        [Parameter (Mandatory = $true, Position = 1)]
        [string]$ovf_path,
        [Parameter (Mandatory = $true, Position = 2)]
        [string]$vm_host,
        [Parameter (Mandatory = $true)]
        [string]$datastore,
        [Parameter (Mandatory = $true)]
        [string]$cluster,
        [Parameter (Mandatory = $false)]
        [string]$inventory,
        [Parameter (Mandatory = $true)]
        [string]$name_vm,
        [Parameter (Mandatory = $false)]
        [ValidateRange(31, 512)]
        [int]$capacityGB = 80,
        [Parameter (Mandatory = $false)]
        [ValidateRange(2, 32)]
        [int]$memoryGB,
        [Parameter (Mandatory = $false)]
        [ValidateRange(2, 32)]
        [int]$cpu,
        [Parameter(Mandatory = $false)]
        [switch]$StartVM = $false,
        [Parameter (Mandatory = $true)]
        [string]$vmnetwork1,
        [Parameter (Mandatory = $false)]
        [string]$vmnetwork2
    )

    Begin {
    }

    Process {


        #Check if VMWare PowerCLI is available (not use #Require because not mandatory module)
        if ($null -eq (Get-InstalledModule -name VMware.VimAutomation.Common -ErrorAction SilentlyContinue)) {
            Throw "You need to install VMware.PowerCLI (Install-Module VMware.PowerCLI)"
        }
        #Write-Warning "You need to have a vSwitch configured on your vSphere environment even if you use a DVS"
        #default vapp_config
        $vapp_config = @{
            "source" = $ovf_path
            "name"   = $name_vm
        }

        if ($DefaultVIServers.Count -eq 0) {
            throw "Need to be connect to vCenter (use Connect-VIServer)"
        }
        if (Get-VM $name_vm -ErrorAction "silentlyContinue") {
            Throw "VM $name_vm already exist, change name or remove VM"
        }

        if (-not (Get-Cluster -Name $cluster -ErrorAction "silentlycontinue")) {
            Throw "Cluster not found : $cluster"
        }
        else {
            $vapp_config.add("Location", $cluster)
        }

        if (-not (Get-VMHost -Name $vm_host -ErrorAction "silentlycontinue")) {
            Throw "Vm_Host not found : $vm_host"
        }
        else {
            $vapp_config.add("vmhost", $vm_host)
        }

        if (-not (Get-Datastore -Name $datastore -ErrorAction "silentlycontinue")) {
            Throw "Datastore not found : $datastore"
        }
        else {
            $vapp_config.add("datastore", $datastore)
        }

        if ( $PsBoundParameters.ContainsKey('inventory') ) {
            if (-not (Get-Inventory -Name $inventory -ErrorAction "silentlycontinue")) {
                Throw "Inventory not found : $inventory"
            }
            else {
                $vapp_config.add("inventory", $inventory)
            }
        }

        $ovfConfig = Get-OvfConfiguration -Ovf $ovf_path

        #Check if vSwitch is available ?
        $ovfConfig.NetworkMapping.VM_Network.Value = $vmnetwork1

        if ( $PsBoundParameters.ContainsKey('vmnetwork2') ) {
            $ovfConfig.NetworkMapping.VM_Network_2.Value = $vmnetwork2
        }

        Import-VApp @vapp_config -OvfConfiguration $ovfConfig | Out-Null

        #Add new disk (mininum 80GB )
        New-HardDisk -VM $name_vm -CapacityGB $capacityGB -Persistence persistent

        #Change memory (8 by default)
        if ( $PsBoundParameters.ContainsKey('MemoryGB') ) {
            Get-VM $name_vm | Set-VM -MemoryGB $MemoryGB -confirm:$false | Out-Null
        }

        #Change CPU (8 by default)
        if ( $PsBoundParameters.ContainsKey('CPU') ) {
            Get-VM $name_vm | Set-VM -NumCPU $cpu -confirm:$false | Out-Null
        }

        #Set NetworkAdapter to enable (for both/All...)
        Get-VM $name_vm | Get-NetworkAdapter | Set-NetworkAdapter -StartConnected $true -Confirm:$false | Out-Null

        if ( $StartVM ) {
            Get-VM $name_vm | Start-VM | Out-Null
            Write-Output "$name_vm is started and ready to use"
        }
        else {
            Write-Output "$name_vm is ready to use (need to Start VM !)"
        }

    }

    End {
    }
}

function Set-ArubaCPVmFirstBoot {

    <#
        .SYNOPSIS
        Configure the first boot of Clearpass VM

        .DESCRIPTION
        Configure the first boot (Appliance Type and encrypt disk) of ClearPass VM

        .EXAMPLE
        $cppmFirstBootParams = @{
            name_vm                 = "PowerArubaCP-CPPM"
            appliance_type          = "CLABV"
        }

        PS>Set-ArubaCPVmFirstBoot @cppmFirstBootParams

        Configuration of first CPPM Boot (VM Name and Appliance Type CLABV )

        .EXAMPLE
        Set-ArubaCPVmFirstBoot -name_vm PowerArubaCP-CPPM -appliance_type C3000V -encrypt_disk:$false

        Configuration of first CPPM Boot (VM Name, Appliance Type C3000V and encrypt disk disable )
    #>

    Param(
        [Parameter (Mandatory = $true)]
        [ValidateSet("CLABV", 'C1000V', 'C2000V', 'C3000V')]
        [string]$appliance_type,
        [Parameter (Mandatory = $true)]
        [string]$name_vm,
        [Parameter (Mandatory = $false)]
        [switch]$encrypt_disk
    )

    Begin {
    }

    Process {

        #TODO Check the VM is available and if Set-VMKeyStrokes function is load too

        switch ( $appliance_type ) {
            "CLABV" {
                $StringInput = "1"
            }
            "C1000V" {
                $StringInput = "2"
            }
            "C2000V" {
                $StringInput = "3"

            }
            "C3000V" {
                $StringInput = "4"
            }
        }

        Set-VMKeystrokes -VMName $name_vm -StringInput $StringInput -ReturnCarriage $true

        #Use secondary disk
        Set-VMKeystrokes -VMName $name_vm -StringInput y

        #Encrypt all local data
        if ( $PsBoundParameters.ContainsKey('encrypt_disk') ) {
            if ( $encrypt_disk ) {
                $StringInput = "y"
            }
            else {
                $StringInput = "n"
            }
        } else {
            #By Default Encrypt Local data
            $StringInput = "y"
        }

        Set-VMKeystrokes -VMName $name_vm -StringInput $StringInput

        #Copy now data and reboot, need to wait 10/15 minutes...
    }

    End {
    }
}


function Set-ArubaCPVmSetup {

    <#
        .SYNOPSIS
        Setup a VM ClearPass

        .DESCRIPTION
        Setup a VM ClearPass (hostname, management/data ip address, dns, password...).

        .EXAMPLE
        $cppmsetupParams = @{
            name_vm                 = "CPPM"
            hostname                = "CPPM"
            mgmt_ip                 = "10.200.11.225"
            mgmt_netmask            = "24"
            mgmt_gateway            = "10.200.11.254"
            data_ip                 = "10.200.12.225"
            data_netmask            = "24"
            data_gateway            = "10.200.12.254"
            dns_primary             = "10.200.11.1"
            dns_secondary           = "10.200.11.200"
            new_password            = "MyPassword"
        }

        PS>Set-ArubaCPVmSetup @cppmsetupParams

        Configuration d'un initial d'un ClearPass (Nom, Adresse IP, mot de passe...)
    #>

    Param(
        [string]$name_vm,
        [Parameter (Mandatory = $true)]
        [string]$hostname,
        [Parameter (Mandatory = $true)]
        [ipaddress]$mgmt_ip,
        [Parameter (Mandatory = $true)]
        [ValidateRange(0,32)]
        [int]$mgmt_netmask,
        [Parameter (Mandatory = $true)]
        [ipaddress]$mgmt_gateway,
        [Parameter (Mandatory = $false)]
        [ipaddress]$data_ip,
        [ValidateRange(0,32)]
        [int]$data_netmask,
        [Parameter (Mandatory = $true)]
        [ipaddress]$data_gateway,
        [Parameter (Mandatory = $true)]
        [ipaddress]$dns_primary,
        [Parameter (Mandatory = $false)]
        [ipaddress]$dns_secondary,
        [Parameter (Mandatory = $true)]
        [string]$new_password,
        [Parameter (Mandatory = $false)]
        [ValidateRange(1,10)]
        [int]$timezone_continent,
        [Parameter (Mandatory = $false)]
        [ValidateRange(1,55)]
        [int]$timezone_country,
        [Parameter (Mandatory = $false)]
        [ipaddress]$ntp_primary,
        [Parameter (Mandatory = $false)]
        [ipaddress]$ntp_secondary
    )

    Begin {
    }

    Process {
        if ($timezone_continent -xor $timezone_country){
            Throw "You need to specific Timezone Continent and Country on the sametime"
        }

        #Connection
        Set-VMKeystrokes -VMName $name_vm -StringInput appadmin -ReturnCarriage $true
        Start-Sleep 1
        Set-VMKeystrokes -VMName $name_vm -StringInput eTIPS123 -ReturnCarriage $true

        Start-Sleep 15

        #Initial Setup
        #Hostname
        Set-VMKeystrokes -VMName $name_vm -StringInput $hostname -ReturnCarriage $true
        Start-Sleep 1

        #Management IPv4
        $mgmt = $mgmt_ip.ToString() + "/" + $mgmt_netmask
        Set-VMKeystrokes -VMName $name_vm -StringInput $mgmt -ReturnCarriage $true
        Start-Sleep 1
        Set-VMKeystrokes -VMName $name_vm -StringInput $mgmt_gateway.ToString() -ReturnCarriage $true
        Start-Sleep 1

        #Management IPv6 (Skip...)
        Set-VMKeystrokes -VMName $name_vm -SpecialKeyInput "KeyEnter"
        Start-Sleep 1

        #Data Port
        if ($data_ip -and $data_netmask -and $data_gateway) {
            $data = $data_ip.ToString() + "/" + $data_netmask
            Set-VMKeystrokes -VMName $name_vm -StringInput $data -ReturnCarriage $true
            Start-Sleep 1
            Set-VMKeystrokes -VMName $name_vm -StringInput $data_gateway.ToString() -ReturnCarriage $true
            Start-Sleep 1

            #IPv6
            Set-VMKeystrokes -VMName $name_vm -SpecialKeyInput "KeyEnter"
            Start-Sleep 1
        }
        else {
            Set-VMKeystrokes -VMName $name_vm -SpecialKeyInput "KeyEnter"
            Start-Sleep 1

            #IPv6
            Set-VMKeystrokes -VMName $name_vm -SpecialKeyInput "KeyEnter"
            Start-Sleep 1
        }

        #DNS
        Set-VMKeystrokes -VMName $name_vm -StringInput $dns_primary -ReturnCarriage $true
        Start-Sleep 1
        Set-VMKeystrokes -VMName $name_vm -StringInput $dns_secondary -ReturnCarriage $true
        Start-Sleep 1

        #Password
        Set-VMKeystrokes -VMName $name_vm -StringInput $new_password -ReturnCarriage $true
        Start-Sleep 1
        Set-VMKeystrokes -VMName $name_vm -StringInput $new_password -ReturnCarriage $true
        Start-Sleep 1

        #NTP
        if($timezone_continent -or $ntp_primary){
            Set-VMKeystrokes -VMName $name_vm -StringInput y -ReturnCarriage $true
            Start-Sleep 1

            if($ntp_primary) {
                #Configure NTP Server
                Set-VMKeystrokes -VMName $name_vm -StringInput 2 -ReturnCarriage $true
                Start-Sleep 1
                Set-VMKeystrokes -VMName $name_vm -StringInput $ntp_primary -ReturnCarriage $true
                Start-Sleep 1
                Set-VMKeystrokes -VMName $name_vm -StringInput $ntp_secondy -ReturnCarriage $true
                Start-Sleep 1
            } else {
                #Skip Configure Data and time

                Set-VMKeystrokes -VMName $name_vm -StringInput 1 -ReturnCarriage $true
                Start-Sleep 1

                Set-VMKeystrokes -VMName $name_vm -SpecialKeyInput "KeyEnter"
                Start-Sleep 1

                Set-VMKeystrokes -VMName $name_vm -SpecialKeyInput "KeyEnter"
                Start-Sleep 1
            }

            if($timezone_continent){
                #Configure timezone (Continent and Country)
                Set-VMKeystrokes -VMName $name_vm -StringInput y -ReturnCarriage $true
                Start-Sleep 1
                Set-VMKeystrokes -VMName $name_vm -StringInput $timezone_continent -ReturnCarriage $true
                Start-Sleep 1
                Set-VMKeystrokes -VMName $name_vm -StringInput $timezone_country -ReturnCarriage $true
                Start-Sleep 1
                Set-VMKeystrokes -VMName $name_vm -StringInput 1 -ReturnCarriage $true
                Start-Sleep 1
            } else {
                #Skip timezone (Continent and Country)
                Set-VMKeystrokes -VMName $name_vm -StringInput n -ReturnCarriage $true
                Start-Sleep 1
                Set-VMKeystrokes -VMName $name_vm -StringInput 1 -ReturnCarriage $true
                Start-Sleep 1
            }
        } else {
            #No NTP or Timezone settings, skip
            Set-VMKeystrokes -VMName $name_vm -StringInput n -ReturnCarriage $true
            Start-Sleep 1
        }

        #FIPS
        Set-VMKeystrokes -VMName $name_vm -StringInput n -ReturnCarriage $true
        Start-Sleep 1

        #Configuration OK ?
        Set-VMKeystrokes -VMName $name_vm -StringInput y -ReturnCarriage $true
    }

    End {
    }
}