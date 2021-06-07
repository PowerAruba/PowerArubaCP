
# PowerArubaCP

This is a Powershell module for configure an Aruba ClearPass (CPPM).

<p align="center">
<img src="https://raw.githubusercontent.com/PowerAruba/PowerArubaCP/master/Medias/PowerArubaCP.png" width="250" height="250" />
</p>

With this module (version 0.5.0) you can manage:

- [API Client](#api-client) (Add / Get / Remove)
- [Application License](#application-license) (Add / Get / Remove)
- [Authentication Method and Source](#Authentication-Method-and-Source) (Get Auth Source and Method)
- [CPPM](#clearpass-version) (Get Version)
- [Device Fingerrint](#device-fingerprint) (Add /Get)
- [Endpoint](#endpoint) (Add / Get / Set / Remove)
- [Network Device](#Network-device) (Add / Get / Set / Remove a Network Device)
- [Network Device Group](#network-device-group) (Add / Get / Set / Remove a Network Device Group and Add/remove Member)
- [Server](#server) (Get Configuration, Version)
- [Service](#service) (Get / Enable / Disable)
- [Static Host List](#static-host-list) (Add / Get / Set / Remove a Static Host List and Add/Remove Member)
- [VM](#vm) (Deploy and Configure ClearPass VM (for initial setup)

There is some extra feature
- [Invoke API](#Invoke-API)
- [Multi Connection](#MultiConnection)
- [Filtering](#Filtering)

More functionality will be added later.

Tested with Aruba ClearPass (using release 6.8.x, 6.9.x and 6.10.0)
Application Licence, Service and Static Host List are not supported on Clearpass < 6.8.0
Device Fingerprint are not supported on Clearpass < 6.9.0

# Usage

All resource management functions are available with the Powershell verbs GET, ADD, SET, REMOVE.  
For example, you can manage NAS (NetworkDevice) with the following commands:
- `Get-ArubaCPNetworkDevice`
- `Add-ArubaCPNetworkDevice`
- `Set-ArubaCPNetworkDevice`
- `Remove-ArubaCPNetworkDevice`

# Requirements

- Powershell 5 or 6.x/7.x (Core) (If possible get the latest version)
- A ClearPass (with release >= 6.8.x) and API Client enable

# Instructions
### Install the module
```powershell
# Automated installation (Powershell 5 and later):
    Install-Module PowerArubaCP

# Import the module
    Import-Module PowerArubaCP

# Get commands in the module
    Get-Command -Module PowerArubaCP

# Get help
    Get-Help Add-ArubaCPNetworkDevice -Full
```

# Examples

### Connecting to the ClearPass using API

The first thing to do is to get API Client
there is two methods to connect, using [client_id/client_secret](#Use-API-client_idclient_secret) or [token](#Use-API-Token) 

#### Use API client_id/client_secret


Go on WebGUI of your ClearPass, on Guest Modules
![](./Medias/CPPM_Guest_API.PNG)  
Go on `Administration` => `API Services` => `API Clients`

![](./Medias/CPPM_Create_API_Client.PNG)  
Create a `New API Client`
- Client ID : a client name (for example PowerArubaCP)
- Operator Profile : Super Administrator
- Grant type : Client credentials
- Access Token Lifetime : You can increment ! (24 hours !)

Click on `Create API Client`

```powershell
# Connect to the Aruba Clearpass using client_id/client_secret
    Connect-ArubaCP 192.0.2.1 -client_id PowerArubaCP -client_secret QRFttyxOmWX3NopMIYzKysj30wvIMxAwB6kUy7uJc67B

    Name                           Value
    ----                           -----
    token                          7aa3de0be5ea230ea92b6de0bafa14d7a76e2305
    invokeParams                   {DisableKeepAlive, SkipCertificateCheck}
    server                         192.0.2.1
    port                           443
    version                        6.8.4

```

#### Use API Token

Like for client_id/client_secret, generate a API Client but you don't need to store the Client Secret

On `API Clients List`, select the your client
![](./Medias/CPPM_Generate_Access_Token.PNG)  

Click on `Generate Access Token`

![](./Medias/CPPM_Get_Token.PNG)  
And kept the token (for example : 70680f1d19f86110800d5d5cb4414fbde7be12ae)


After connect to an Aruba ClearPass with the command `Connect-ArubaCP` :

```powershell
# Connect to the Aruba Clearpass using Token
    Connect-ArubaCP 192.0.2.1 -token 70680f1d19f86110800d5d5cb4414fbde7be12ae

    Name                           Value
    ----                           -----
    token                          70680f1d19f86110800d5d5cb4414fbde7be12ae
    invokeParams                   {DisableKeepAlive, SkipCertificateCheck}
    server                         192.0.2.1
    port                           443
    version                        6.8.4
```

### Invoke API
for example to get ClearPass version

```powershell
# get ClearPass version using API
    Invoke-ArubaCPRestMethod -method "get" -uri "api/cppm-version"

    app_major_version   : 6
    app_minor_version   : 7
    app_service_release : 2
    app_build_number    : 105008
    hardware_version    : CLABV
    fips_enabled        : False
    eval_license        : False
    cloud_mode          : False
```

if you get a warning about `Unable to connect` Look [Issue](#Issue)

to get API uri, go to ClearPass Swagger (https://CPPM-IP/api-docs)
![](./Medias/CPPM_API_Docs.PNG)  

And chooce a service (for example Platform)
![](./Medias/CPPM_API_Docs_platform.PNG)  

### API Client

You can create a new API Client `Add-ArubaCPApiClient`, retrieve its informations `Get-ArubaCPApiClient` or delete it `Remove-ArubaCPApiClient`.

```powershell
# Create an API Client
    Add-ArubaCPApiClient -client_id MyAPIClient -grant_types client_credentials -profile_id 1

    client_id                    : MyAPIClient
    client_secret                : $2y$10$OXRszKzBSH7hP5QwgZ3cCuNZwbGaddb767l0Kx52Ww.RPEhBfbj6u
    client_description           :
    grant_types                  : client_credentials
    redirect_uri                 :
    operating_scope              :
    profile_id                   : 1
    auto_confirm                 : False
    enabled                      : True
    scope                        :
    user_id                      :
    access_lifetime              : 8 hours
    refresh_lifetime             : 14 days
    operating_scope_label        : ClearPass REST API
    profile_name                 : Super Administrator
    client_public                : False
    client_refresh               : False
    access_token_lifetime        : 8
    access_token_lifetime_units  : hours
    refresh_token_lifetime       : 14
    refresh_token_lifetime_units : days
    id                           : MyAPIClient
    _links                       : @{self=}


# Get information about API Client
    Get-ArubaCPApiClient -client_id MyAPIClient | Format-Table

    client_id   client_secret      client_description grant_types        redirect_uri operating_scope profile_id auto_confirm enabled scope
    ---------   -------------      ------------------ -----------        ------------ --------------- ---------- ------------ ------- -----
    MyAPIClient $2y$10$OXRszKzB...                    client_credentials                              1                 False    True

# Remove an API Client
    $ac = Get-ArubaCPApiClient -client_id MyAPIClient
    $ac | Remove-ArubaCPApiClient

    Confirm
    Are you sure you want to perform this action?
    Performing the operation "Remove API Client" on target "MyAPIClient".
    [Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"):
```

### Application License

You can create add Application License `Add-ArubaCPApplicationLicense`, retrieve its information `Get-ArubaCPApplicationLicense` or delete it `Remove-ArubaCPApplicationLicense`.

```powershell
# Add Application License (Onboard)
    Add-ArubaCPApplicationLicense -product_name Onboard -license_key "-----BEGIN CLEARPASS ONBOARD LICENSE KEY----- .... "

    id                : 3002
    product_id        : 8
    product_name      : Onboard
    license_key       : -----BEGIN CLEARPASS ONBOARD LICENSE KEY-----
                        .......
                        -----END CLEARPASS ONBOARD LICENSE KEY-----
    license_type      : Evaluation
    user_count        : 100
    duration          : 90
    duration_units    : days
    license_added_on  : 18/04/2021 13:45:27
    activation_status : False
    _links            : @{self=}


# Get information about Application License
    Get-ArubaCPApplicationLicense -product_name Onboard | Format-Table

    id product_id product_name license_key
    -- ---------- ------------ -----------
    3002          8 Onboard      -----BEGIN CLEARPASS ONBOARD LICENSE KEY-----...

# Remove Application License Onboard
    $al = Get-ArubaCPApplicationLicense -product_name Onboard
    $al | Remove-ArubaCPApplicationLicense

    Confirm
    Are you sure you want to perform this action?
    Performing the operation "Remove Application License" on target "3002 (Onboard)".
    [Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"):
```

### Authentication Method and Source

You can retrieve its Authentication information of Method (EAP, PAP...) `Get-ArubaCPAuthMethod` or Source (LDAP, HTTP...) `Get-ArubaCPAuthSource`

```powershell
# Get Auth Method information
    Get-ArubaCPAuthMethod

    id            : 1
    name          : [PAP]
    description   : Default settings for PAP
    method_type   : PAP
    details       : @{encryption_scheme=auto}
    inner_methods : {}
    _links        : @{self=}

    id            : 2
    name          : [MSCHAP]
    description   : Default settings for MSCHAP
    method_type   : MSCHAP
    details       :
    inner_methods : {}
    _links        : @{self=}

    id            : 3
    name          : [EAP TLS]
    description   : Default settings for EAP-TLS
    method_type   : EAP-TLS
    details       : @{override_cert_url=false; ocsp_enable=none; session_cache_enable=true; autz_required=true; certificate_comparison=none; 
                    session_timeout=6}
    inner_methods : {}
    _links        : @{self=}
    ...

# Get Auth Source information
    Get-ArubaCPAuthSource | Format-List

    id name                         description                                                                        type  use_for_authorization
    -- ----                         -----------                                                                        ----  ---------------------
    1 [Local User Repository]      Authenticate users against Policy Manager local user database                      Local                  True
    2 [Guest User Repository]      Authenticate guest users against Policy Manager local database                     Local                  True
    3 [Guest Device Repository]    Authenticate guest devices against Policy Manager local database                   Local                  True
    4 [Endpoints Repository]       Authenticate endpoints against Policy Manager local database                       Local                  True
    5 [Onboard Devices Repository] Authenticate Onboard devices against Policy Manager local database                 Local                  True
    6 [Admin User Repository]      Authenticate users against Policy Manager admin user database                      Local                  True
    7 [Denylist User Repository]   Denylist database with users who have exceeded bandwidth or session related limits Local                  True
    9 [Time Source]                Authorization source for implementing various time functions                       Local                  True
   10 [Social Login Repository]    Authenticate users against Policy Manager social login database                    Local                  True
  100 [Zone Cache Repository]      Access attributes cached by Context Server Actions in previous sessions            HTTP                   True
    8 [Insight Repository]         Insight database with session information for users and devices                    Local                  True
```

### ClearPass Version

You can retrieve its informations `Get-ArubaCPCPPMVersion`.

```powershell
# Get ClearPass Version information 
    Get-ArubaCPCPPMVersion

    app_major_version   : 6
    app_minor_version   : 9
    app_service_release : 5
    app_build_number    : 131053
    hardware_version    : CLABV
    fips_enabled        : False
    cc_enabled          : False
    eval_license        : True
    cloud_mode          : False
```

### Device Fingerprint

You can add Device Fingerprint `Add-DeviceFingerprint`, retrieve its informations `Get-DeviceFingerprint`.

```powershell
# Add Device Fingerprint (Device category, Family and name)
    Add-ArubaCPDeviceFingerprint -mac_address 000102030405 -device_category Server -device_family ClearPass -device_name ClearPass VM

    SUCCESS                                            _links
    -------                                            ------
    Successfully posted device fingerprint to profiler @{self=}

# Add Device Fingerprint (IP Address)
    Add-ArubaCPDeviceFingerprint -mac_address 000102030405 -ip 192.2.0.1

    SUCCESS                                            _links
    -------                                            ------
    Successfully posted device fingerprint to profiler @{self=}

# Add Device Fingerprint (hostname)
    Add-ArubaCPDeviceFingerprint -mac_address 000102030405 -hostname 192.2.0.1

    SUCCESS                                            _links
    -------                                            ------
    Successfully posted device fingerprint to profiler @{self=}

# Get information about Device Fingerprint
    Get-ArubaCPEndpoint -mac 000102030405 | Get-ArubaCPDeviceFingerprint

    ip              : 192.0.2.1
    hostname        : CPPM
    updated_at      : 1622904104
    device_category : Server
    device_name     : ClearPass
    device_family   : ClearPass
    mac             : 000102030405
    added_at        : 1622903816
    _links          : @{self=}

```

### Endpoint

You can add Endpoint `Add-ArubaCPEndpoint`, retrieve its informations `Get-ArubaCPEndpoint`, modify its properties `Set-ArubaCPEndpoint` or delete it `Remove-ArubaCPEndpoint`.

```powershell
# Add Endpoint (Known)
    Add-ArubaCPEndpoint -mac_address 00:01:02:03:04:05 -status Known

    id          : 3179
    mac_address : 000102030405
    status      : Known
    attributes  :
    _links      : @{self=}

# Get information about Endpoint
    Get-ArubaCPEndpoint | Format-table

    id mac_address  status  attributes _links
    -- -----------  ------  ---------- ------
    3004 00505690da3e Unknown            @{self=}
    3173 00155d27ec00 Unknown            @{self=}
    3003 0050569041da Unknown            @{self=}
    3002 005056afddbb Unknown            @{self=}
    3005 005056af007b Unknown            @{self=}
    3030 00505680fb94 Unknown            @{self=}

# Modified information (status and description) about Endpoint
    Get-ArubaCPEndpoint -mac_address 00:01:02:03:04:05 | Set-ArubaCPEndpoint -status "Unknown" -description "Change by PowerArubaCP"

    id          : 3179
    mac_address : 000102030405
    description : Change by PowerArubaCP
    status      : Unknown
    attributes  :
    _links      : @{self=}

# Remove Endpoint
    $ep = Get-ArubaCPEndpoint -mac_address 00:01:02:03:04:05
    $ep | Remove-ArubaCPEndpoint

    Confirm
    Are you sure you want to perform this action?
    Performing the operation "Remove Endpoint" on target "3174 (000102030405)".
    [Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"):Y
```

### Network Device

You can create a new Network Device (NAS) `Add-ArubaCPNetworkDevice`, retrieve its informations `Get-ArubaCPNetworkDevice`, modify its properties `Set-ArubaCPNetworkDevice`, or delete it `Remove-ArubaCPNetworkDevice`.

```powershell
# Create a Network Device (NAS)
    Add-ArubaCPNetworkDevice -name SW1 -ip_address 192.0.2.1 -radius_secret MySecurePassword -vendor Aruba -description "Add by PowerArubaCP"

    id            : 3004
    name          : SW1
    description   : Add by PowerArubaCP
    ip_address    : 192.0.2.1
    radius_secret :
    tacacs_secret :
    vendor_name   : Aruba
    coa_capable   : False
    coa_port      : 3799
    attributes    :
    _links        : @{self=}


# Get information about Network Device (NAS)
    Get-ArubaCPNetworkDevice -name SW1 | Format-Table

    id   name description         ip_address radius_secret tacacs_secret vendor_name coa_capable coa_port attributes
    --   ---- -----------         ---------- ------------- ------------- ----------- ----------- -------- ----------
    3004 SW1  Add by PowerArubaCP 192.0.2.1                              Aruba       False       3799

# (Re)Configure Network Device (NAS)
    Get-ArubaCPNetworkDevice -name SW1 | Set-ArubaCPNetworkDevice  -ip_address 192.0.2.2 -vendor_name Hewlett-Packard-Enterprise

    id            : 3004
    name          : SW1
    description   :
    ip_address    : 192.0.2.2
    radius_secret :
    tacacs_secret :
    vendor_name   : Hewlett-Packard-Enterprise
    coa_capable   : True
    coa_port      : 3799
    attributes    :
    _links        : @{self=}

# Remove a Network Device (NAS)
    $nad = Get-ArubaCPNetworkDevice -name SW1
    $nad | Remove-ArubaCPNetworkDevice

    Confirm
    Are you sure you want to perform this action?
    Performing the operation "Remove Network device" on target "3344 (SW1)".
    [Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"):
```

### Network Device Group

You can create a new Network Device Group `Add-ArubaCPNetworkDeviceGroup`, retrieve its informations `Get-ArubaCPNetworkDeviceGroup`, modify its properties `Set-ArubaCPNetworkDeviceGroup`, or delete it `Remove-ArubaCPNetworkDeviceGroup` you can also add `Add-ArubaCPNetworkDeviceGroupMember` and remove `Remove-ArubaCPNetworkDeviceGroupMeMber` Member.

```powershell
# Create a Network Device Group (list IP)
    Add-ArubaCPNetworkDeviceGroup -name NDG-list_ip -list_ip 192.0.2.1, 192.0.2.2

    id           : 3037
    name         : NDG-list_ip
    group_format : list
    value        : 192.0.2.1, 192.0.2.2
    _links       : @{self=}

# Create a Network Device Group (subnet)
    Add-ArubaCPNetworkDeviceGroup -name NDG-subnet -subnet 192.0.2.0/24 -description "Add via PowerArubaCP"

    id           : 3043
    name         : NDG-subnet
    description  : Add via PowerArubaCP
    group_format : subnet
    value        : 192.0.2.0/24
    _links       : @{self=}

# Get information about Network Device Group
    Get-ArubaCPNetworkDeviceGroup | Format-Table

    id name        group_format value                _links
    -- ----        ------------ -----                ------
    3037 NDG-list_ip list         192.0.2.1, 192.0.2.2 @{self=}
    3043 NDG-subnet  subnet       192.0.2.0/24         @{self=}


# (Re)Configure Network Device Group
    Get-ArubaCPNetworkDeviceGroup -name NDG-subnet | Set-ArubaCPNetworkDeviceGroup -description "Modified via PowerArubaCP"

    id           : 3043
    name         : NDG-subnet
    description  : Modified via PowerArubaCP
    group_format : subnet
    value        : 192.0.2.0/24
    _links       : @{self=}

#Add Member on the Network Device Group
    Get-ArubaCPNetworkDeviceGroup -name NDG-list_ip | Add-ArubaCPNetworkDeviceGroupMember -list_ip 192.0.2.3

    id           : 3037
    name         : NDG-list_ip
    group_format : list
    value        : 192.0.2.1, 192.0.2.2, 192.0.2.3
    _links       : @{self=}

#Remove Member on the Network Device Group
    Get-ArubaCPNetworkDeviceGroup -name NDG-list_ip | Remove-ArubaCPNetworkDeviceGroupMember -list_ip 192.0.2.1

    id           : 3037
    name         : NDG-list_ip
    group_format : list
    value        : 192.0.2.2, 192.0.2.3
    _links       : @{self=}

# Remove a Network Device Group
    Get-ArubaCPNetworkDeviceGroup -name NDG-subnet | Remove-ArubaCPNetworkDeviceGroup

    Confirm
    Are you sure you want to perform this action?
    Performing the operation "Remove Network Device Group" on target "3043 (NDG-subnet)".
    [Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): Y
```

### Server

You can get Server Configuration `Get-ArubaCPServerConfiguration`, or version `Get-ArubaCPServerVersion`.


```powershell
# Get Server Configuration
    Get-ArubaCPServerConfiguration

    name                       : CPPM
    local_server               : True
    server_uuid                : 443c73db-aab3-49e4-a701-c21ef6945776
    server_dns_name            : CPPM
    fqdn                       :
    server_ip                  :
    management_ip              : 10.200.11.159
    ipv6_server_ip             :
    ipv6_management_ip         :
    is_publisher               : True
    extras                     :
    is_insight_enabled         : True
    is_insight_primary         : True
    is_perfmon_enabled         : t
    replication_status         : ENABLED
    last_replication_timestamp :
    is_profiler_enabled        : True
    _links                     : @{self=}

# Get Server Version
    Get-ArubaCPServerVersion

    cppm_version  guest_version installed_patches
    ------------  ------------- -----------------
    6.10.0.180076 6.10.0.180076 {}
```

### Service

You can retrieve information about Service `Get-ArubaCPService`, enable it `Enable-ArubaCPService`, or disable it `Disable-Enable`.

```powershell

#Get List of Service
    Get-ArubaCPService | Format-Table

    id name                                         type        template                         enabled order_no _links
    -- ----                                         ----        --------                         ------- -------- ------
    10 [Aruba Device Access Service]                TACACS      TACACS+ Enforcement                 True        3 @{self=}
    1  [Policy Manager Admin Network Login Service] TACACS      TACACS+ Enforcement                 True        1 @{self=}
    2  [AirGroup Authorization Service]             RADIUS      RADIUS Enforcement ( Generic )      True        2 @{self=}
    11 [Guest Operator Logins]                      Application Aruba Application Authentication    True        4 @{self=}
    13 [Device Registration Disconnect]             WEBAUTH     Web-based Authentication            True        6 @{self=}
    12 [Insight Operator Logins]                    Application Aruba Application Authentication    True        5 @{self=}

#Enable service on Guest Operator Logins
    Get-ArubaCPService -Name "[Guest Operator Logins]" | Enable-ArubaCPService

    id       : 11
    name     : [Guest Operator Logins]
    type     : Application
    template : Aruba Application Authentication
    enabled  : True
    order_no : 4
    _links   : @{self=}

#Disable service on Guest Operator Logins (id)
    Get-ArubaCPService -id 11 | Disable-ArubaCPService

    id       : 11
    name     : [Guest Operator Logins]
    type     : Application
    template : Aruba Application Authentication
    enabled  : False
    order_no : 4
    _links   : @{self=}

```

### Static Host List

You can add Static Host List `Add-ArubaCPStaticHostList`, retrieve its informations `Get-ArubaCPStaticHostList`, modify its properties `Set-ArubaCPStaticHostList` or delete it `Remove-ArubaCPStaticHostList`, you can also add `Add-ArubaCPStaticHostListMember` and Remove `Remove-ArubaCPStaticHostListMember` Member (MAC or IPAddress).

```powershell

#Add Static Host List (with IPAddress)
    Add-ArubaCPStaticHostList -name SHL-list-IPAddress -host_format list -host_type IPAddress -host_entries_address 192.0.2.1 -host_entries_description "Add via PowerArubaCP"

    id           : 3040
    name         : SHL-list-IPAddress
    host_format  : list
    host_type    : IPAddress
    host_entries : {@{host_address=192.0.2.1; host_address_desc=Add via PowerArubaCP}}
    _links       : @{self=}

#Add Static Host List (with MACAddress)
    Add-ArubaCPStaticHostList -name SHL-list-MACAddress -host_format list -host_type MACAddress -host_entries_address 00:01:02:03:04:05 -host_entries_description "Add via PowerArubaCP"

    id           : 3041
    name         : SHL-list-MACAddress
    host_format  : list
    host_type    : MACAddress
    host_entries : {@{host_address=00-01-02-03-04-05; host_address_desc=Add via PowerArubaCP}}
    _links       : @{self=}

#Get list of Static Host List
    Get-ArubaCPStaticHostList | Format-Table

    id name                host_format host_type  host_entries                                                                _links
    -- ----                ----------- ---------  ------------                                                                ------
    3040 SHL-list-IPAddress  list        IPAddress  {@{host_address=192.0.2.1; host_address_desc=Add via PowerArubaCP}}         @{self=}
    3041 SHL-list-MACAddress list        MACAddress {@{host_address=00-01-02-03-04-05; host_address_desc=Add via PowerArubaCP}} @{self=}

#(Re)Configure a Static Host List
    Get-ArubaCPStaticHostList -name SHL-list-IPAddress | Set-ArubaCPStaticHostList -description "My SHL IP Address"

    id           : 3040
    name         : SHL-list-IPAddress
    description  : My SHL IP Address
    host_format  : list
    host_type    : IPAddress
    host_entries : {@{host_address=192.0.2.1; host_address_desc=Add via PowerArubaCP}}
    _links       : @{self=}


#Add Member on the Static Host List
    Get-ArubaCPStaticHostList -name  SHL-list-MACAddress | Add-ArubaCPStaticHostListMember -host_entries_address 00:01:02:03:04:06 -host_entries_description "Add via PowerArubaCP"

    id           : 3041
    name         : SHL-list-MACAddress
    host_format  : list
    host_type    : MACAddress
    host_entries : {@{host_address=00-01-02-03-04-05; host_address_desc=Add via PowerArubaCP}, @{host_address=00-01-02-03-04-06; 
                host_address_desc=Add via PowerArubaCP}}
    _links       : @{self=}


#Remove Member on the Static Host List
    Get-ArubaCPStaticHostList -name  SHL-list-MACAddress | Remove-ArubaCPStaticHostListMember -host_entries_address 00:01:02:03:04:06

    id           : 3041
    name         : SHL-list-MACAddress
    host_format  : list
    host_type    : MACAddress
    host_entries : {@{host_address=00-01-02-03-04-05; host_address_desc=Add via PowerArubaCP}, @{host_address=00-01-02-03-04-06; 
                host_address_desc=Add via PowerArubaCP}}
    _links       : @{self=}

#Remove Static Host List
    Get-ArubaCPStaticHostList -name  SHL-list-MACAddress | Remove-ArubaCPStaticHostList

    Confirm
    Are you sure you want to perform this action?
    Performing the operation "Remove Static Host List" on target "3041 (SHL-list-MACAddress)".
    [Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): Y

```

### VM

You can use PowerArubaCP for help to deploy ClearPass on VMware ESXi (Wwth a Vcenter)
You need to have [VMware.PowerCLI](https://developer.vmware.com/powercli) and [Set-VMKeystrokes](https://www.powershellgallery.com/packages/VMKeystrokes/1.0.0) from [William Lam](https://williamlam.com/2017/09/automating-vm-keystrokes-using-the-vsphere-api-powercli.html)

You can use the following cmdlet (on this order)

- `Deploy-ArubaCPVm` Deploy CPPM OVA with add hard disk
- `Set-ArubaCPVmFirstBoot` Configure first boot (Model, encrypt...)
- `Set-ArubaCPVmSetup` Configure hostname, IP Address, NTP...
- `Set-ArubaCPVmAddLicencePlatform` Add Licence Platform
- `Set-ArubaCPVmUpdate` Update CPPM (using HTTP(S) or SSH)

a video will be online to see an example of auto deployement

### MultiConnection

From release 0.4.0, it is possible to connect on same times to multi ClearPass
You need to use -connection parameter to cmdlet

For example to get Static Host List of 2 CPPM

```powershell
# Connect to first ClearPass
    $cppm1 = Connect-ArubaCP 192.0.2.1 -SkipCertificateCheck -DefaultConnection:$false

#DefaultConnection set to false is not mandatory but only don't set the connection info on global variable

# Connect to second ClearPass
    $cppm2 = Connect-ArubaCP 192.0.2.1 -SkipCertificateCheck -DefaultConnection:$false

# Get Static Host List for first ClearPass
   Get-ArubaCPStaticHostList -connection $cppm1 | Format-Table

  id name                description host_format host_type  value                 _links
  -- ----                ----------- ----------- ---------  -----                 ------
3001 SHL-list-IPAddress              list        IPAddress                        @{self=}
....
# Get Static Host List for first ClearPass
   Get-ArubaCPStaticHostList -connection $cppm2 | Format-Table

  id name                description host_format host_type  value                 _links
  -- ----                ----------- ----------- ---------  -----                 ------
3001 SHL-list-MACAddress             list        MACAddress                       @{self=}
...

#Each cmdlet can use -connection parameter
```

### Filtering
For `Invoke-ArubaCPRestMethod`, it is possible to use -filter parameter
You need to use ClearPass API syntax :

|Description |	JSON Filter Syntax |
| ---------- | ------------------- |
| No filter, matches everything | {} |
| Field is equal to "value" | {"fieldName":"value"} or {"fieldName":{"$eq":"value"}} |
| Field is one of a list of values | {"fieldName":["value1", "value2"]}  or {"fieldName":{"$in":["value1", "value2"]}} |
| Field is not one of a list of values | {"fieldName":{"$nin":["value1", "value2"]}} |
| Field contains a substring "value" | {"fieldName":{"$contains":"value"}} |
| Field is not equal to "value" | {"fieldName":{"$ne":"value"}} |
| Field is greater than "value" | {"fieldName":{"$gt":"value"}} |
| Field is greater than or equal to "value" | {"fieldName":{"$gte":"value"}} |
| Field is less than "value" | {"fieldName":{"$lt":"value"}} |
| Field is less than or equal to "value" | {"fieldName":{"$lte":"value"}} |
| Field matches a regular expression (case-sensitive) | {"fieldName":{"$regex":"regex"}} |
| Field matches a regular expression (case-insensitive) | {"fieldName":{"$regex":"regex", "$options":"i"}} |
| Field exists (does not contain a null value) | {"fieldName":{"$exists":true}} |
| Field is NULL | {"fieldName":{"$exists":false}} |
| Combining filter expressions with AND | {"$and":[ filter1, filter2, ... ]} |
| Combining filter expressions with OR | {"$or":[ filter1, filter2, ... ]} |
| Inverting a filter expression | {"$not":{ filter }} |
| Field is greater than or equal to 2 and less than 5 | {"fieldName":{"$gte":2, "$lt":5}} {"$and":[ {"fieldName":{"$gte":2}}, {"fieldName":{"$lt":5}} ]}

For `Get-XXX` cmdlet like `Get-ArubaCPNetwork`, it is possible to using some helper filter (`-filter_attribute`, `-filter_type`, `-filter_value`)

```powershell
# Get NetworkDevice named NAD-PowerArubaCP
    Get-ArubaCPNetworkDevice -name NAD-PowerArubaCP
...

# Get NetworkDevice contains NAD-PowerArubaCP
    Get-ArubaCPNetworkDevice -name NAD-PowerArubaCP -filter_type contains
...

# Get NetworkDevice where ip_address equal 192.168.1.1
    Get-ArubaCPNetworkDevice -filter_attribute ip_address -filter_type equal -filter_value 192.168.1.1
...

```
Actually, support only `equal` and `contains` filter type

### Disconnecting

```powershell
# Disconnect from the Aruba ClearPass
    Disconnect-ArubaCP
```

# Issue

## Unable to connect (certificate)
if you use `Connect-ArubaCP` and get `Unable to Connect (certificate)`

The issue coming from use Self-Signed or Expired Certificate for switch management

Try to connect using `Connect-ArubaCP -SkipCertificateCheck`

# How to contribute

Contribution and feature requests are more than welcome. Please use the following methods:

  * For bugs and [issues](https://github.com/PowerAruba/PowerArubaCX/issues), please use the [issues](https://github.com/PowerAruba/PowerArubaCX/issues) register with details of the problem.
  * For Feature Requests, please use the [issues](https://github.com/PowerAruba/PowerArubaCX/issues) register with details of what's required.
  * For code contribution (bug fixes, or feature request), please request fork PowerFGT, create a feature/fix branch, add tests if needed then submit a pull request.

# Contact

Currently, [@alagoutte](#author) started this project and will keep maintaining it. Reach out to me via [Twitter](#author), Email (see top of file) or the [issues](https://github.com/PowerAruba/PowerArubaCX/issues) Page here on GitHub. If you want to contribute, also get in touch with me.


# List of available command
```powershell
Add-ArubaCPApiClient
Add-ArubaCPApplicationLicense
Add-ArubaCPDeviceFingerprint
Add-ArubaCPEndpoint
Add-ArubaCPNetworkDevice
Add-ArubaCPNetworkDeviceGroup
Add-ArubaCPNetworkDeviceGroupMember
Add-ArubaCPStaticHostList
Add-ArubaCPStaticHostListMember
Confirm-ArubaCPApiClient
Confirm-ArubaCPApplicationLicense
Confirm-ArubaCPEndpoint
Confirm-ArubaCPNetworkDevice
Confirm-ArubaCPNetworkDeviceGroup
Confirm-ArubaCPService
Confirm-ArubaCPStaticHostList
Connect-ArubaCP
Convert-ArubaCPCIDR2Mask
Deploy-ArubaCPVm
Disable-ArubaCPService
Disconnect-ArubaCP
Enable-ArubaCPService
Format-ArubaCPMacAddress
Get-ArubaCPApiClient
Get-ArubaCPApplicationLicense
Get-ArubaCPAuthMethod
Get-ArubaCPAuthSource
Get-ArubaCPCPPMVersion
Get-ArubaCPDeviceFingerprint
Get-ArubaCPEndpoint
Get-ArubaCPNetworkDevice
Get-ArubaCPNetworkDeviceGroup
Get-ArubaCPServerConfiguration
Get-ArubaCPServerVersion
Get-ArubaCPService
Get-ArubaCPStaticHostList
Invoke-ArubaCPRestMethod
Remove-ArubaCPApiClient
Remove-ArubaCPApplicationLicense
Remove-ArubaCPEndpoint
Remove-ArubaCPNetworkDevice
Remove-ArubaCPNetworkDeviceGroup
Remove-ArubaCPNetworkDeviceGroupMember
Remove-ArubaCPStaticHostList
Remove-ArubaCPStaticHostListMember
Set-ArubaCPCipherSSL
Set-ArubaCPEndpoint
Set-ArubaCPNetworkDevice
Set-ArubaCPNetworkDeviceGroup
Set-ArubaCPStaticHostList
Set-ArubaCPuntrustedSSL
Set-ArubaCPVmAddLicencePlatform
Set-ArubaCPVmApiClient
Set-ArubaCPVmFirstBoot
Set-ArubaCPVmSetup
Set-ArubaCPVmUpdate
Show-ArubaCPException
```

# Author

**Alexis La Goutte**
- <https://github.com/alagoutte>
- <https://twitter.com/alagoutte>

# Special Thanks

- Warren F. for his [blog post](http://ramblingcookiemonster.github.io/Building-A-PowerShell-Module/) 'Building a Powershell module'
- Erwan Quelin for help about Powershell

# License

Copyright 2018 Alexis La Goutte and the community.
