# Ensure script is running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run this script as Administrator!"
    Exit 1
}

# Refresh environment variables
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")


winget install -e --id Obsidian.Obsidian
winget install -e --id Discord.Discord
winget install -e --id TorProject.TorBrowser
winget install -e --id VideoLAN.VLC
winget install -e --id Zoom.Zoom
winget install -e --id Kingsoft.WPSOffice
winget install -e --id SlackTechnologies.Slack
winget install -e --id Postman.Postman
winget install -e --id Microsoft.Teams
winget install -e --id OBSProject.OBSStudio
winget install -e --id dbeaver.dbeaver
winget install -e --id Mozilla.Firefox
winget install -e --id calibre.calibre
winget install -e --id Notion.Notion
winget install -e --id Brave.Brave
winget install -e --id OpenVPNTechnologies.OpenVPNConnect