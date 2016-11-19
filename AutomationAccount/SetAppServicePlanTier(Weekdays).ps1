<#
    .DESCRIPTION
        Used within Automation Account to automate Switching the App Service Plan to the required Tier during working week days.
        Used with the below schedule :
             - Everyday 8 am : [Tier = Standard] ; Everyday 7 pm : [Tier = Free] ; if day = weekend skip execution/
       you will habe 
        * Monday - Friday ( 8am to 7pm) : Standard 
        * Free tier for the rest 

    .NOTES
        AUTHOR: Fares Zekri
        LASTEDIT: Nov 19th, 2016
#>

Param(
 [Parameter (Mandatory= $true)]
 [string]$Tier,
 [Parameter (Mandatory= $true)]
 [string]$ResourceGroupName,
 [Parameter (Mandatory= $true)]
 [string]$AppServicePlanName
)
$Day =Get-Date -Format dddd
If ($Day -eq "Saturday" -or $Day -eq "Sunday") 
{
  exit 
} 
else 
{
    Import-Module AzureRM.Websites
    $connectionName = "AzureRunAsConnection"
    try
    {
        # Get the connection "AzureRunAsConnection "
        $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

        "Logging in to Azure..."
        Add-AzureRmAccount `
            -ServicePrincipal `
            -TenantId $servicePrincipalConnection.TenantId `
            -ApplicationId $servicePrincipalConnection.ApplicationId `
            -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
    }
    catch {
        if (!$servicePrincipalConnection)
        {
            $ErrorMessage = "Connection $connectionName not found."
            throw $ErrorMessage
        } else{
            Write-Error -Message $_.Exception
            throw $_.Exception
        }
    }
    try
    {
        "Switching App Service Plan to " + $Tier
        Set-AzureRmAppServicePlan -Name $AppServicePlanName -ResourceGroupName $ResourceGroupName -Tier $Tier
    }
    catch
    {
        Write-Error -Message $_.Exception
            throw $_.Exception
    }
} 
