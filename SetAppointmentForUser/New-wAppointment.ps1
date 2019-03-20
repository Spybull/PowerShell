Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn;

function New-wAppointment {
    param 
    (
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        $PrincipalName,
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        $Subject,
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        $DateStart,
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        $DateEnd
    )

    begin {
        Import-Module 'C:\Program Files\Microsoft\Exchange\Web Services\2.2\Microsoft.Exchange.WebServices.dll'
    }

    process {
        $TimeZoneBug = [System.TimeZoneInfo]::CreateCustomTimeZone("Time zone to workaround a bug", [System.TimeZoneInfo]::Local.BaseUtcOffset, "Time zone to workaround a bug", "Time zone to workaround a bug")

        $ExchangeService = [Microsoft.Exchange.WebServices.Data.ExchangeService]::new([Microsoft.Exchange.WebServices.Data.ExchangeVersion]::Exchange2013, $TimeZoneBug)
        $ExchangeService.Url = [System.Uri]::new("https://yourORG.su/EWS/Exchange.asmx")

        $ExchangeService.ImpersonatedUserId = [Microsoft.Exchange.WebServices.Data.ImpersonatedUserId]::new([Microsoft.Exchange.WebServices.Data.ConnectingIdType]::PrincipalName, $PrincipalName)
        $Folder = [Microsoft.Exchange.WebServices.Data.Folder]::Bind($ExchangeService, [Microsoft.Exchange.WebServices.Data.FolderId]::new([Microsoft.Exchange.WebServices.Data.WellKnownFolderName]::Calendar, $PrincipalName))

        $Appointment = [Microsoft.Exchange.WebServices.Data.Appointment]::new($ExchangeService)
        $Appointment.IsAllDayEvent = $true
        $Appointment.Subject = $Subject

        $dt1 = [datetime]::ParseExact("$DateStart", 'dd.MM.yyyy', $null)
        $dt2 = [datetime]::ParseExact("$DateEnd", 'dd.MM.yyyy HH:mm', $null)

        $Appointment.Start = $dt1
        $Appointment.End = $dt2

        $Appointment.Save([Microsoft.Exchange.WebServices.Data.SendInvitationsMode]::SendToNone);

        $Item = [Microsoft.Exchange.WebServices.Data.Item]::Bind($ExchangeService, $Appointment.Id, [Microsoft.Exchange.WebServices.Data.PropertySet]::new([Microsoft.Exchange.WebServices.Data.ItemSchema]::Subject) )
        Write-Output "Created: $Item.Subject"
    }

    end {

    }
}

#How to call This function:
#You can change the principal name to SID or e-mail in 26 row!
#New-wAppointment -PrincipalName $princ.UserPrincipalName -Subject "I am on vacation" -DateStart $date1  -DateEnd "$date2 23:59"
