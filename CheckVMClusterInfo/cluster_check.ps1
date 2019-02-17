$Header = @"
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
"@

$Header_add = @"
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; }
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black; }
</style>
"@

$path = "Path to your files"
$today = Get-Date
$yestd = $today.AddDays(-1)

$path_yesterday_dir = $path + $yestd.ToString("yyyyMMdd")
$path_today_dir = $path + $today.ToString("yyyyMMdd")

mkdir -Path $path_today_dir

$srv = "your server1", "your server2", "your server3"
$usr = 'user'
$pas = 'password'

For($i=0; $i -le $srv.Length-1; $i++)
{
    Connect-VIServer -Server $srv[$i] -Protocol https -User $usr -Password $pas
    $VMs = Get-VM

    $Output = foreach ($VM in $VMs)
    {
        Get-VM $VM | select Name, PowerState,
        @{N="ProvisionedSpaceGB"; E={($_.ProvisionedSpaceGB).tostring("#.##")}},
        @{N="UsedSpaceGB";E={($_.UsedSpaceGB).tostring("#.##")}},
        NumCpu, MemoryGB,
        @{N=”IPAddress”;E={$_.Guest.IPAddress[0]}},
        @{N=”DNSName”;E={$_.ExtensionData.Guest.Hostname}},
        Notes
    }

    $Add_VMs = Get-VM | Get-VIEvent -Types Info -Start (Get-Date).AddDays(-1) |`
        Where {$_ -is [Vmware.vim.VmBeingDeployedEvent]`
        -or $_ -is [Vmware.vim.VmCreatedEvent]`
        -or $_ -is [Vmware.vim.VmRegisteredEvent]}|`
        Select @{ Name="Name"; Expression={$_.Vm.Name}},
               @{ Name="PowerState"; Expression={(Get-VM -Name $_.Vm.Name).PowerState}},
               @{ Name="ProvisionedSpaceGB"; Expression={(Get-VM -Name $_.Vm.Name).ProvisionedSpaceGB.tostring("#.##")}},
               @{ Name="UsedSpaceGB"; Expression={(Get-VM -Name $_.Vm.Name).UsedSpaceGB.tostring("#.##")}},
               @{ Name="NumCpu"; Expression={(Get-VM -Name $_.Vm.Name).NumCpu}},
               @{ Name="MemoryGB"; Expression={(Get-VM -Name $_.Vm.Name).MemoryGB}},
               @{ Name="IPAddress"; Expression={(Get-VM -Name $_.Vm.Name).Guest.IPAddress[0]}},
               @{ Name="DNSName"; Expression={(Get-VM -Name $_.Vm.Name).ExtensionData.Guest.Hostname}},
               @{ Name="Notes"; Expression={(Get-VM -Name $_.Vm.Name).Notes}}

    $Del_VMs = Get-VM | Get-VIEvent -Types Info -Start (Get-Date).AddDays(-1) |`
        Where {$_ -is [Vmware.vim.VmRemovedEvent]}|`
        Select @{ Name="Name"; Expression={$_.Vm.Name}},
               @{ Name="PowerState"; Expression={(Get-VM -Name $_.Vm.Name).PowerState}},
               @{ Name="ProvisionedSpaceGB"; Expression={(Get-VM -Name $_.Vm.Name).ProvisionedSpaceGB.tostring("#.##")}},
               @{ Name="UsedSpaceGB"; Expression={(Get-VM -Name $_.Vm.Name).UsedSpaceGB.tostring("#.##")}},
               @{ Name="NumCpu"; Expression={(Get-VM -Name $_.Vm.Name).NumCpu}},
               @{ Name="MemoryGB"; Expression={(Get-VM -Name $_.Vm.Name).MemoryGB}},
               @{ Name="IPAddress"; Expression={(Get-VM -Name $_.Vm.Name).Guest.IPAddress[0]}},
               @{ Name="DNSName"; Expression={(Get-VM -Name $_.Vm.Name).ExtensionData.Guest.Hostname}},
               @{ Name="Notes"; Expression={(Get-VM -Name $_.Vm.Name).Notes}}


    $str_csv = $path_today_dir + '\' + "$($srv[$i])" + '.' + $today.ToString("yyyyMMdd") + '.csv'
    $str_htm = $path_today_dir + '\' + "$($srv[$i])" + '.' + $today.ToString("yyyyMMdd") + '.html'

    $Output  | Export-Csv $str_csv -NoTypeInformation -Encoding UTF8
    $Output  | ConvertTo-Html -Property * -Head $Header | Out-File $str_htm


    if($Add_VMs)
    {
        Add-Content $str_htm "</br><h1>New Virtual Machines:</h1></br>"
        $Add_VMs | ConvertTo-Html -Property * -Head $Header_add | Add-Content $str_htm
    }

    if($Del_VMs)
    {
        Add-Content $str_htm "</br><h1>Deleted Virtual Machines:</h1></br>"
        $Del_VMs | ConvertTo-Html -Property * -Head $Header_add | Add-Content $str_htm
    }

    Disconnect-VIServer * -Force -Confirm:$false
}

    

