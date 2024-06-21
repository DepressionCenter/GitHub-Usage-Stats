# Export Git Hub Usage Stats For Organization
# This PowerShell script can be used to export daily GitHub repository statistics,
# for all repositories under an organization.
# 
# Author: Gabriel Mongefranco (@gabrielmongefranco)
#         See README for other contributors, if any.
# Created: 3/15/24
# License: See attached license file
# Website: https://github.com/DepressionCenter  |  https://depressioncenter.org
# 
# Remarks: Set GITHUB_USERNAME and GITHUB_API_KEY in the system environment variables before running this script.


# Set the working directory and inputs
$organizationName = 'DepressionCenter'
$username = $Env:GITHUB_USERNAME
# To use interactive login, leave the apiToken string blank and uncomment where indicated in the authentication section
$apiToken = [SecureString](ConvertTo-SecureString $Env:GITHUB_API_KEY -AsPlainText -Force)
$jsonOutputPath = 'c:\GitHubStats\github-stats-' + $organizationName + '.json'
$jsonDetailedOutputPath = 'c:\GitHubStats\github-stats-detailed-' + $organizationName + '.json'
$csvOutputPath = 'c:\GitHubStats\github-stats-' + $organizationName + '.csv'
$csvRollingOutputPath = 'c:\GitHubStats\github-stats-rolling-' + $organizationName + '.csv'


# Ensure you have PowerShellForGitHub module installed
Import-Module PowerShellForGitHub



# Begin
Clear-Host
Write-Host -f Yellow " === Export GitHub Usage Stats For Organization Repos === "
$DateCaptured = [DateTime]::UtcNow #Use UTC to keep in line with how GitHub reports data

# Authentication
# To authenticate interactively, comment this section, and use this instead: Set-GitHubAuthentication $username
Write-Host "Authenticating to GitHub API as $username..."
$githubCredential = [System.Management.Automation.PSCredential](New-Object System.Management.Automation.PSCredential($username, $apiToken))
Set-GitHubAuthentication -Credential $githubCredential -SessionOnly
$apiToken = ''


# Set some GitHub parameters
Set-GitHubConfiguration -DisableTelemetry -DisableUpdateCheck -DefaultOwnerName $organizationname

# Get all repositories under the given organization
Write-Host "Getting repos..."
$repoCount = [int]0
try
{
	$repos = Get-GitHubRepository -OrganizationName $organizationName
	$repoCount = [int]$repos.Count
} catch {
	Write-Host -f Red "Error while getting repository information. Ensure the organization and credentials are correct."
}

if ($repoCount -eq 0)
{
	Write-Host -f Red "No repositories found."
	Start-Sleep -Seconds 3
	Exit
} else {
	Write-Host "Found $repoCount repo(s)."
}

# Add custom properties to the repository variable
$repos | Add-Member -Force -MemberType NoteProperty -Name contributors -Value @()
$repos | Add-Member -Force -MemberType NoteProperty -Name contributors_count -Value [int]0
$repos | Add-Member -Force -MemberType NoteProperty -Name contributors_csv -Value ""
$repos | Add-Member -Force -MemberType NoteProperty -Name contributions_count -Value [int]0
$repos | Add-Member -Force -MemberType NoteProperty -Name contributors_detail_csv -Value ""
$repos | Add-Member -Force -MemberType NoteProperty -Name collaborators -Value @()
$repos | Add-Member -Force -MemberType NoteProperty -Name collaborators_count -Value [int]0
$repos | Add-Member -Force -MemberType NoteProperty -Name collaborators_csv -Value ""

$repos | Add-Member -Force -MemberType NoteProperty -Name stargazers -Value @()
$repos | Add-Member -Force -MemberType NoteProperty -Name stargazers_count -Value [int]0
$repos | Add-Member -Force -MemberType NoteProperty -Name stargazers_csv -Value ""
$repos | Add-Member -Force -MemberType NoteProperty -Name watchers -Value @()
$repos | Add-Member -Force -MemberType NoteProperty -Name watchers_count -Value [int]0
$repos | Add-Member -Force -MemberType NoteProperty -Name watchers_csv -Value ""
$repos | Add-Member -Force -MemberType NoteProperty -Name referrer_traffic -Value @()
$repos | Add-Member -Force -MemberType NoteProperty -Name referrer_traffic_count -Value [int]0
$repos | Add-Member -Force -MemberType NoteProperty -Name referrer_traffic_uniques -Value [int]0
$repos | Add-Member -Force -MemberType NoteProperty -Name referrer_traffic_csv -Value ""
$repos | Add-Member -Force -MemberType NoteProperty -Name path_traffic -Value @()
$repos | Add-Member -Force -MemberType NoteProperty -Name path_traffic_count -Value [int]0
$repos | Add-Member -Force -MemberType NoteProperty -Name path_traffic_uniques -Value [int]0
$repos | Add-Member -Force -MemberType NoteProperty -Name path_traffic_csv -Value ""
$repos | Add-Member -Force -MemberType NoteProperty -Name view_traffic -Value @()
$repos | Add-Member -Force -MemberType NoteProperty -Name view_traffic_count -Value [int]0
$repos | Add-Member -Force -MemberType NoteProperty -Name view_traffic_uniques -Value [int]0
$repos | Add-Member -Force -MemberType NoteProperty -Name view_traffic_count_yesterday -Value [int]0
$repos | Add-Member -Force -MemberType NoteProperty -Name view_traffic_uniques_yesterday -Value [int]0
$repos | Add-Member -Force -MemberType NoteProperty -Name view_traffic_csv -Value ""
$repos | Add-Member -Force -MemberType NoteProperty -Name clone_traffic -Value @()
$repos | Add-Member -Force -MemberType NoteProperty -Name clone_traffic_count -Value [int]0
$repos | Add-Member -Force -MemberType NoteProperty -Name clone_traffic_uniques -Value [int]0
$repos | Add-Member -Force -MemberType NoteProperty -Name clone_traffic_count_yesterday -Value [int]0
$repos | Add-Member -Force -MemberType NoteProperty -Name clone_traffic_uniques_yesterday -Value [int]0
$repos | Add-Member -Force -MemberType NoteProperty -Name clone_traffic_csv -Value ""
$repos | Add-Member -Force -MemberType NoteProperty -Name events -Value @()
$repos | Add-Member -Force -MemberType NoteProperty -Name events_count -Value [int]0
$repos | Add-Member -Force -MemberType NoteProperty -Name events_count_yesterday -Value [int]0
$repos | Add-Member -Force -MemberType NoteProperty -Name events_uniques -Value [int]0
$repos | Add-Member -Force -MemberType NoteProperty -Name events_uniques_yesterday -Value [int]0
$repos | Add-Member -Force -MemberType NoteProperty -Name events_csv -Value ""
$repos | Add-Member -Force -MemberType NoteProperty -Name pushes -Value @()
$repos | Add-Member -Force -MemberType NoteProperty -Name pushes_count -Value [int]0
$repos | Add-Member -Force -MemberType NoteProperty -Name pushes_count_yesterday -Value [int]0
$repos | Add-Member -Force -MemberType NoteProperty -Name pushes_uniques -Value [int]0
$repos | Add-Member -Force -MemberType NoteProperty -Name pushes_uniques_yesterday -Value [int]0
$repos | Add-Member -Force -MemberType NoteProperty -Name pushes_csv -Value ""
$repos | Add-Member -Force -MemberType NoteProperty -Name forks -Value @()
$repos | Add-Member -Force -MemberType NoteProperty -Name forks_count -Value [int]0
$repos | Add-Member -Force -MemberType NoteProperty -Name forks_uniques -Value [int]0
$repos | Add-Member -Force -MemberType NoteProperty -Name forks_count_yesterday -Value [int]0
$repos | Add-Member -Force -MemberType NoteProperty -Name forks_uniques_yesterday -Value [int]0
$repos | Add-Member -Force -MemberType NoteProperty -Name forks_csv -Value ""
$repos | Add-Member -Force -MemberType NoteProperty -Name pulls -Value @()
$repos | Add-Member -Force -MemberType NoteProperty -Name pulls_count -Value [int]0
$repos | Add-Member -Force -MemberType NoteProperty -Name issues -Value @()
$repos | Add-Member -Force -MemberType NoteProperty -Name issues_count -Value [int]0
$repos | Add-Member -Force -MemberType NoteProperty -Name issues_open_count -Value [int]0
$repos | Add-Member -Force -MemberType NoteProperty -Name issues_uniques -Value [int]0
$repos | Add-Member -Force -MemberType NoteProperty -Name issues_count_opened_yesterday -Value [int]0
$repos | Add-Member -Force -MemberType NoteProperty -Name issues_count_closed_yesterday -Value [int]0
$repos | Add-Member -Force -MemberType NoteProperty -Name issues_uniques_opened_yesterday -Value [int]0
$repos | Add-Member -Force -MemberType NoteProperty -Name issues_uniques_closed_yesterday -Value [int]0
$repos | Add-Member -Force -MemberType NoteProperty -Name topics_csv -Value ""


# Contributors
Write-Host "Getting contributors..."
$repos | ForEach-Object {$_.contributors = Get-GitHubRepositoryContributor -Uri $_.url }
$repos | ForEach-Object {$_.contributors_count = [int]($_.contributors | Select-Object -ExpandProperty login -Unique).Count }
$repos | ForEach-Object {if ($_.contributors_count -gt 0) {$_.contributors_csv = [String]::Join(",", $_.contributors.UserName ) }} -ErrorAction Ignore
$repos | ForEach-Object {if ($_.contributors_count -gt 0) {$_.contributors_detail_csv = [String]::Join(",", ($_.contributors | ForEach-Object {$_.UserName + '|' + $_.contributions}) ) }} -ErrorAction Ignore

# Contributions
$repos | ForEach-Object {$_.contributions_count = [int]($_.contributors | Measure-Object -Sum contributions).Sum }


# Collaborators
Write-Host "Getting collaborators..."
$repos | ForEach-Object { $_.collaborators = (Invoke-GHRestMethod -Method Get -UriFragment $_.collaborators_url.replace('{/collaborator}','')); $_.collaborators_count = $_.collaborators.count }
$repos | ForEach-Object {if ($_.collaborators_count -gt 0) {$_.collaborators_csv = [String]::Join(",", ($_.collaborators | ForEach-Object {$_.login}) ) }} -ErrorAction Ignore


# Watchers (subscribers)
# Due to an API change, subscribers_count should be used for getting subscribers, fka watchers.
# The other fields called watchers and stargazers both return stargazers now, but this PS module does not support this change.
Write-Host "Getting watchers (subscribers)..."
$repos | ForEach-Object { $_.watchers = (Invoke-GHRestMethod -Uri $_.subscribers_url -Method Get) }
$repos | ForEach-Object { $_.watchers_count = $_.watchers.Count }
$repos | ForEach-Object {if ($_.watchers_count -gt 0) {$_.watchers_csv = [String]::Join(",", $_.watchers.login ) }} -ErrorAction Ignore


# Stargazers (bookmarks)
Write-Host "Getting stargazers (bookmarks)..."
$repos | ForEach-Object { $_.stargazers = (Invoke-GHRestMethod -Uri $_.stargazers_url -Method Get) }
$repos | ForEach-Object { $_.stargazers_count = $_.stargazers.Count }
$repos | ForEach-Object {if ($_.stargazers_count -gt 0) {$_.stargazers_csv = ([String]::Join(",", $_.stargazers.login )) }} -ErrorAction Ignore


# Referrer Traffic
Write-Host "Getting referrer traffic..."
$repos | ForEach-Object {$_.referrer_traffic = Get-GitHubReferrerTraffic -Uri $_.url }
$repos | ForEach-Object {$_.referrer_traffic_count = [int]($_.referrer_traffic | Measure-Object -Sum count).Sum }
$repos | ForEach-Object {$_.referrer_traffic_uniques = [int]($_.referrer_traffic | Measure-Object -Sum uniques).Sum }
# Use this to get only referrer website without counts: $repos | ForEach-Object {if ($_.referrer_traffic_count -gt 0) {$_.referrer_traffic_csv = [String]::Join(",", $_.referrer_traffic.referrer ) }} -ErrorAction Ignore
$repos | ForEach-Object {if ($_.referrer_traffic_count -gt 0) {$_.referrer_traffic_csv = [String]::Join(",", ($_.referrer_traffic | ForEach-Object {$_.referrer + '|' + $_.count + '|' + $_.uniques}) ) }} -ErrorAction Ignore

# Path Traffic
Write-Host "Getting path traffic..."
$repos | ForEach-Object {$_.path_traffic = Get-GitHubPathTraffic -Uri $_.url }
$repos | ForEach-Object {$_.path_traffic_count = [int]($_.path_traffic | Measure-Object -Sum count).Sum }
$repos | ForEach-Object {$_.path_traffic_uniques = [int]($_.path_traffic | Measure-Object -Sum uniques).Sum }
$repos | ForEach-Object {
    if ($_.path_traffic_count -gt 0) {
        $uriPrefix = ($_.full_name)
        $_.path_traffic | ForEach-Object {
                # Fix internal path name that no longer matches due to renaming one of our repo's
                $_.path = $_.path.replace('/Useful-SQL-Queries-for-Umich-Research-Centers','').replace('/Useful-SQL-Queries-for-UMich-Research-Centers','')

                # Remove /organizationname/reponame/ from the beginning of each path, to reduce field size
                $_.path = $_.path.replace($uriPrefix,'').replace('/'+$organizationName,'').replace($organizationName+'/','').replace('//','/')
                $_.path = $_.path.replace('blob/main/README.md','').replace('/README.md','')
                if(($_.path -eq '') -or ($null -eq $_.path) -or ($_.path -eq '/') -or ($_.path -eq 'README.md') -or ($_.path -eq 'blob/main')-or ($_.path -eq 'tree/main')) {$_.path = 'Home'}
            }
        $_.path_traffic_csv = [String]::Join(",", ($_.path_traffic | ForEach-Object {$_.path + '|' + $_.count + '|' + $_.uniques}) )
    }
} -ErrorAction Ignore


# View Traffic
Write-Host "Getting view traffic..."
$repos | ForEach-Object {$_.view_traffic = Get-GitHubViewTraffic -Uri $_.url }
$repos | ForEach-Object {$_.view_traffic_count = [int]($_.view_traffic | Measure-Object -Sum count).Sum }
$repos | ForEach-Object {$_.view_traffic_uniques = [int]($_.view_traffic | Measure-Object -Sum uniques).Sum }
# Convert dates back to UTC
$repos | ForEach-Object {$_.view_traffic.views | ForEach-Object {$_.timestamp = [DateTime][System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId( $_.timestamp, 'Greenwich Standard Time').DateTime}}
# Filter views object array to pick only yesterday's data, based on a UTC timestamp and today's date in UTC
$repos | ForEach-Object { $_.view_traffic_count_yesterday = [int]( @($_.view_traffic.views | Where-Object {$_.timestamp.Date -EQ $DateCaptured.Date.AddDays(-1)}) | Measure-Object -Sum count).Sum }
$repos | ForEach-Object { $_.view_traffic_uniques_yesterday = [int]( @($_.view_traffic.views | Where-Object {$_.timestamp.Date -EQ $DateCaptured.Date.AddDays(-1)}) | Measure-Object -Sum uniques).Sum }
# To return all view traffic for the past 14 days, use this line: $repos | ForEach-Object {if ($_.view_traffic_count -gt 0) {$_.view_traffic_csv = [String]::Join(",", ($_.view_traffic.views | ForEach-Object {$_.timestamp.ToString("MM/dd/yyyy hh:mm:ss tt") + '|' + $_.count + '|' + $_.uniques}) ) }} -ErrorAction Ignore
$repos | ForEach-Object {if ($_.view_traffic_count_yesterday -gt 0) {$_.view_traffic_csv = [String]::Join(",", (@($_.view_traffic.views | Where-Object {$_.timestamp.Date -EQ ($DateCaptured.Date.AddDays(-1))}) | ForEach-Object {$_.timestamp.ToString("MM/dd/yyyy hh:mm:ss tt") + '|' + $_.count + '|' + $_.uniques}) ) }} -ErrorAction Ignore

# Clone Traffic
Write-Host "Getting clone traffic..."
$repos | ForEach-Object {$_.clone_traffic = Get-GitHubCloneTraffic -Uri $_.url }
$repos | ForEach-Object {$_.clone_traffic_count = [int]($_.clone_traffic | Measure-Object -Sum count).Sum }
$repos | ForEach-Object {$_.clone_traffic_uniques = [int]($_.clone_traffic | Measure-Object -Sum uniques).Sum }
# Convert dates back to UTC
$repos | ForEach-Object {$_.clone_traffic.clones | ForEach-Object {$_.timestamp = [DateTime][System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId( $_.timestamp, 'Greenwich Standard Time').DateTime}}
# Filter clones object array to pick only yesterday's data, based on a UTC timestamp and today's date in UTC
$repos | ForEach-Object { $_.clone_traffic_count_yesterday = [int]( @($_.clone_traffic.clones | Where-Object {$_.timestamp.Date -EQ $DateCaptured.Date.AddDays(-1)}) | Measure-Object -Sum count).Sum }
$repos | ForEach-Object { $_.clone_traffic_uniques_yesterday = [int]( @($_.clone_traffic.clones | Where-Object {$_.timestamp.Date -EQ $DateCaptured.Date.AddDays(-1)}) | Measure-Object -Sum uniques).Sum }
# To return all clones, use this instead of the line below: $repos | ForEach-Object {if ($_.clone_traffic_count -gt 0) {$_.clone_traffic_csv = [String]::Join(",", ($_.clone_traffic.clones | ForEach-Object {$_.timestamp.ToString("MM/dd/yyyy hh:mm:ss tt") + '|' + $_.count + '|' + $_.uniques}) ) }} -ErrorAction Ignore
$repos | ForEach-Object {if ($_.clone_traffic_count_yesterday -gt 0) {$_.clone_traffic_csv = [String]::Join(",", (@($_.clone_traffic.clones | Where-Object {$_.timestamp.Date -EQ ($DateCaptured.Date.AddDays(-1))}) | ForEach-Object {$_.timestamp.ToString("MM/dd/yyyy hh:mm:ss tt") + '|' + $_.count + '|' + $_.uniques}) ) }} -ErrorAction Ignore


# Events
# Get-GitHubEvent does not appear to work, so call API directly
Write-Host "Getting events (commit, merge, etc.)..."
$repos | ForEach-Object { $_.events = ( (Invoke-GHRestMethod -Uri $_.events_url -Method Get) | Sort-Object -Unique -Descending -Property created_at) }
$repos | ForEach-Object { $_.events_count = $_.events.Count }
$repos | ForEach-Object { $_.events_uniques = [int]($_.events | Select-Object -ExpandProperty actor | Select-Object -ExpandProperty login -Unique).Count }
# Convert dates back to UTC
$repos | ForEach-Object {if ($_.events_count -gt 0) {$_.events | ForEach-Object {$_.created_at = [DateTime][System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId( $_.created_at, 'Greenwich Standard Time').DateTime}}}
# Filter events object array to pick only yesterday's data, based on a UTC timestamp and today's date in UTC
$repos | ForEach-Object { $_.events_count_yesterday = @($_.events | Where-Object {$_.created_at.Date -EQ ($DateCaptured.Date.AddDays(-1))}).Count }
$repos | ForEach-Object { $_.events_uniques_yesterday = ( @($_.events | Where-Object {$_.created_at.Date -EQ ($DateCaptured.Date.AddDays(-1))}) | Select-Object -ExpandProperty actor | Select-Object -ExpandProperty login -Unique).Count }
# Create CSV of yesterday's events only
$repos | ForEach-Object {if ($_.events_count_yesterday -gt 0) {$_.events_csv = [String]::Join(",", (@($_.events | Where-Object {$_.created_at.Date -EQ ($DateCaptured.Date.AddDays(-1))}) | ForEach-Object {$_.created_at.ToString("MM/dd/yyyy hh:mm:ss tt") + '|' + $_.type.replace('Event','') + $(if ($_.payload.action) {'/' + $_.payload.action} else {''}) + '|' + $_.actor.login}) ) }} -ErrorAction Ignore


# Pushes / Commits
Write-Host "Parsing commits from event history..."
$repos | ForEach-Object { $_.pushes = ( $_.events | Where-Object -Property type -eq 'PushEvent' ); $_.pushes_count = $_.pushes.Count }
$repos | ForEach-Object { $_.pushes_uniques = [int]($_.pushes | Select-Object -ExpandProperty actor | Select-Object -ExpandProperty login -Unique).Count }
# Filter to get only yesterday's pushes
$repos | ForEach-Object { $_.pushes_count_yesterday = @($_.pushes | Where-Object {$_.created_at.Date -EQ ($DateCaptured.Date.AddDays(-1))}).Count }
$repos | ForEach-Object { $_.pushes_uniques_yesterday = [int]( @($_.pushes | Where-Object {$_.created_at.Date -EQ ($DateCaptured.Date.AddDays(-1))}) | Select-Object -ExpandProperty actor | Select-Object -ExpandProperty login -Unique).Count }
$repos | ForEach-Object {if ($_.pushes_count_yesterday -gt 0) {$_.pushes_csv = [String]::Join(",", (@($_.pushes | Where-Object {$_.created_at.Date -EQ ($DateCaptured.Date.AddDays(-1))}) | ForEach-Object {$_.created_at.ToString("MM/dd/yyyy hh:mm:ss tt") + '|' + $_.type.replace('Event','') + $(if ($_.payload.action) {'/' + $_.payload.action} else {''}) + '|' + $_.actor.login}) ) }} -ErrorAction Ignore



# Forks
Write-Host "Getting forks..."
$repos | ForEach-Object { $_.forks = (Get-GitHubRepositoryFork -Uri $_.url); $_.forks_count = $_.forks.Count }
$repos | ForEach-Object { $_.forks_uniques = [int]($_.forks | Select-Object -ExpandProperty owner | Select-Object -ExpandProperty login -Unique).Count }
# Convert dates back to UTC
$repos | ForEach-Object {if ($_.forks_count -gt 0) {$_.forks | ForEach-Object {$_.created_at = [DateTime][System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId( $_.created_at, 'Greenwich Standard Time').DateTime}}}
# Get yesterday's forks only
$repos | ForEach-Object { $_.forks_count_yesterday = @($_.forks | Where-Object {$_.created_at.Date -EQ ($DateCaptured.Date.AddDays(-1))}).Count }
$repos | ForEach-Object { $_.forks_uniques_yesterday = [int]( @($_.forks | Where-Object {$_.created_at.Date -EQ ($DateCaptured.Date.AddDays(-1))}) | Select-Object -ExpandProperty owner | Select-Object -ExpandProperty login -Unique).Count }
$repos | ForEach-Object {if ($_.forks_count_yesterday -gt 0) {$_.forks_csv = [String]::Join(",", (@($_.forks | Where-Object {$_.created_at.Date -EQ ($DateCaptured.Date.AddDays(-1))}) | ForEach-Object {$_.created_at.ToString("MM/dd/yyyy hh:mm:ss tt") + '|' + $_.name + '|' + $_.owner.login}) ) }} -ErrorAction Ignore


# Pull Requests
Write-Host "Getting pull requests..."
$repos | ForEach-Object { $_.pulls = (Invoke-GHRestMethod -Uri $_.pulls_url.replace("{/number}","") -Method Get); $_.pulls_count = $_.pulls.Count }
# TODO: Add counts of unique users, active pulls, closed pulls, total pulls, and perhaps pulls_csv of users requesting pulls yesterday


# Issues
Write-Host "Getting issues (tickets/tasks)..."
$repos | ForEach-Object { $_.issues = (Get-GitHubIssue -Uri $_.url); $_.issues_count = $_.issues.Count }
$repos | ForEach-Object { $_.issues_uniques = [int]($_.issues | Select-Object -ExpandProperty user | Select-Object -ExpandProperty login -Unique).Count }
$repos | ForEach-Object { $_.issues_open_count = ($_.issues | Where-Object -Property state -EQ "open").Count }
# Convert dates back to UTC
$repos | ForEach-Object { $_.issue | Where-Object -Property created_at -NE $null | ForEach-Object { $_.created_at = [DateTime][System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId( $_.created_at, 'Greenwich Standard Time').DateTime } }
$repos | ForEach-Object { $_.issues | Where-Object -Property closed_at -NE $null | ForEach-Object { $_.closed_at = [DateTime][System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId( $_.closed_at, 'Greenwich Standard Time').DateTime } }
# Filter issues object array to pick only yesterday's data, based on a UTC timestamp and today's date in UTC
$repos | ForEach-Object { $_.issues_count_opened_yesterday = [int]( @($_.issues | Where-Object {$_.created_at.Date -EQ $DateCaptured.Date.AddDays(-1)}).Count) }
$repos | ForEach-Object { $_.issues_count_closed_yesterday = [int]( @($_.issues | Where-Object {$_.closed_at.Date -EQ $DateCaptured.Date.AddDays(-1)}).Count) }
$repos | ForEach-Object { $_.issues_uniques_opened_yesterday = [int]( @($_.issues | Where-Object {$_.created_at.Date -EQ $DateCaptured.Date.AddDays(-1)} | Select-Object -ExpandProperty user | Select-Object -ExpandProperty login -Unique).Count) }
$repos | ForEach-Object { $_.issues_uniques_closed_yesterday = [int]( @($_.issues | Where-Object {$_.closed_at.Date -EQ $DateCaptured.Date.AddDays(-1)} | Select-Object -ExpandProperty user | Select-Object -ExpandProperty login -Unique).Count) }



# Topics (tags at the repo level)
Write-Host "Getting repository-level topics (tags)..."
$repos | ForEach-Object {if ($_.topics.Count -gt 0) {$_.topics_csv = [String]::Join(",", $_.topics ) }} -ErrorAction Ignore



# Extract pertinent extracts and convert to array of objects for easy export
# NOTE: Format your data types or CSV fields as needed in the loop below
Write-Host "Processing usage stats..."
$usageStats = @()
foreach ($repo in $repos)
{
	$usageStats += [PSCustomObject]@{
        # Sync info
		DateCaptured = [DateTime]$DateCaptured

        # Repository info
        name = [String]$repo.name
		full_name = [String]$repo.full_name
		owner = [String]$repo.owner.login
		description = [String]$repo.description
		url = [String]$repo.RepositoryUrl
		
        # Repository properties
        created = [DateTime]$repo.created_at
		updated = [DateTime]$repo.updated_at
		pushed = [DateTime]$repo.pushed_at
		size = [float]$repo.size
        visibility = $repo.visibility
        is_fork = [int]$repo.fork #remove [int] if you want boolean data type
        is_archived = [int]$repo.archived #remove [int] if you want boolean data type
        is_template = [int]$repo.is_template #remove [int] if you want boolean data type
        topics_csv = $repo.topics_csv

        # Events
        events_count = [int]$repo.events_count
        events_uniques = [int]$repo.events_uniques
        events_count_yesterday = [int]$repo.events_count_yesterday
        events_uniques_yesterday = [int]$repo.events_uniques_yesterday
        events_csv = $repo.events_csv

        # Pushes / Commits
        pushes_count = [int]$repo.pushes_count
        pushes_uniques = [int]$repo.pushes_uniques
        pushes_count_yesterday = [int]$repo.pushes_count_yesterday
        pushes_uniques_yesterday = [int]$repo.pushes_uniques_yesterday
        pushes_csv = $repo.pushes_csv

        # Pull requests
        pulls_count = [int]$repo.pulls_count

        # Discussions
        has_discussions_enabled = [int]$repo.has_discussions #remove [int] if you want boolean data type

        # Issues
        has_issues_enabled = [int]$repo.has_issues #remove [int] if you want boolean data type
        issues_count = [int]$repo.issues_count
        issues_open_count = [int]$repo.issues_open_count
        issues_uniques = [int]$repo.issues_uniques
        issues_count_opened_yesterday = [int]$repo.issues_count_opened_yesterday
        issues_count_closed_yesterday = [int]$repo.issues_count_closed_yesterday
        issues_uniques_opened_yesterday = [int]$repo.issues_uniques_opened_yesterday
        issues_uniques_closed_yesterday = [int]$repo.issues_uniques_closed_yesterday


        # Forks
        forks_count = [int]$repo.forks_count
        forks_count_yesterday = [int]$repo.forks_count_yesterday
        forks_uniques = [int]$repo.forks_uniques
        forks_uniques_yesterday = [int]$repo.forks_uniques_yesterday
        forks_csv = $repo.forks_csv



        # Stargazers (Favorites)
		stargazers_count = [int]$repo.stargazers_count
		stargazers_csv = $repo.stargazers_csv


        # Watchers (Subscriptions)
		watchers_count = [int]$repo.watchers_count
		watchers_csv = $repo.watchers_csv
        

        # Contributors and Contributions
		contributors_count = [int]$repo.contributors_count
        contributors_csv = $repo.contributors_csv
        contributions_count = [int]$repo.contributions_count
        contributors_detail_csv = $repo.contributors_detail_csv


        # Collaborators
        collaborators_count = [int]$repo.collaborators_count
        collaborators_csv = $repo.collaborators_csv


        # Clones
        clone_traffic_count = [int]$repo.clone_traffic_count
        clone_traffic_count_yesterday = [int]$repo.clone_traffic_count_yesterday
        clone_traffic_uniques = [int]$repo.clone_traffic_uniques
        clone_traffic_uniques_yesterday = [int]$repo.clone_traffic_uniques_yesterday
        clone_traffic_csv = $repo.clone_traffic_csv

        # Web Traffic
		referrer_traffic_count = [int]$repo.referrer_traffic_count
		referrer_traffic_uniques = [int]$repo.referrer_traffic_uniques
        referrer_traffic_csv = $repo.referrer_traffic_csv
		path_traffic_count = [int]$repo.path_traffic_count
		path_traffic_uniques = [int]$repo.path_traffic_uniques
		path_traffic_csv = $repo.path_traffic_csv
		view_traffic_count = [int]$repo.view_traffic_count
        view_traffic_count_yesterday = [int]$repo.view_traffic_count_yesterday
		view_traffic_uniques = [int]$repo.view_traffic_uniques
        view_traffic_uniques_yesterday = [int]$repo.view_traffic_uniques_yesterday
        view_traffic_csv = $repo.view_traffic_csv
		}
}

$usageStatsFull = [PSCustomObject]@{
        DateCaptured = $DateCaptured
        repo_stats = $repos
}

# Export results to JSON
Write-Host "Saving results in JSON format at: $jsonOutputPath"
$usageStats | ConvertTo-Json | Out-File -FilePath $jsonOutputPath
$usageStatsFull | ConvertTo-Json | Out-File -FilePath $jsonDetailedOutputPath

# Export only pertinent stats to CSV
Write-Host "Saving results in CSV format at: $csvOutputPath"
$usageStats | Export-Csv -Path $csvOutputPath -NoTypeInformation
$usageStats | Export-Csv -Path $csvRollingOutputPath -NoTypeInformation -Append

Write-Host "Done."
