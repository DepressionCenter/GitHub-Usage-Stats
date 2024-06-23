![Depression Center Logo](https://github.com/DepressionCenter/.github/blob/main/images/EFDCLogo_375w.png "depressioncenter.org")

# GitHub Usage Stats

## Description
Scripts to capture GitHub repository and usage statistics daily, for all repositories under an organization that uses GitHub Enterprise. Simply download the PowerShell script, edit the settings towards the top of the file (file paths, API key, Organization name, etc.), and run it. You can also schedule it as a Windows Task, or import into a database with an external ETL or ELT tool.

![GitHub Usage Stats Sample Screenshot](https://github.com/DepressionCenter/GitHub-Usage-Stats/blob/main/images/GitHub-Usage-Stats-Output-Example.png?raw=true "Sample output from this GitHub Usage Stats script.")


## Quick Start Guide
+ Get a GitHub API key with read permissions to your organization.
+ Set GITHUB_USERNAME and GITHUB_API_KEY in the system environment variables
+ Install the PowerShellForGitHub module in PowerShell.
+ Download the PowerShell script (ExportGitHubUsageStatsForOrganization.ps1).
+ Edit the settings at the top of the script, including the Organization Name variable.
+ Create a directory for the output files, c:\GitHubStats, or as configured in previous step.
+ Run the script in PowerShell.
+ Grab the CSV or JSON files from the output directory. Files are replaced except for the "rolling" file which appends to previous days' data.



## Documentation

### General Information
+ The statistics will be dumped into both CSV and JSON files in the output directory, including:
  + **github-stats-{OrganizationName}.csv** - today's snapshot in CSV format. File is replaced at each run. Recommended for loading into a database.
  + **github-stats-{OrganizationName}.json** - today's snapshot in JSON format. File is replaced at each run. Recommended for loading into a database.
  + **github-stats-detailed-{OrganizationName}.json** - today's snapshot in JSON format, with all detailed included. File is replaced at each run. It can be used for debugging and troubleshooting.
  + **github-stats-rolling-{OrganizationName}.csv** - today's snapshot added to the same CSV, without deleting previous data. This file can be used to create reports directly in Excel, Tableau, PowerBI, etc. without the need for a database.
+ All the counts not labeled "yesterday" are 14-day totals, not for an individual day. 
+ Note that all dates and times are in universal time (UTC), in the GMT time zone.

### Loading Into a Database
+ The script(s) under the SQL folder can be used to create a table to host and accumulate the data. It includes SQL comments for most columns to use in a data dictionary.
+ + Currently, the only script(s) available are for Oracle databases. Some work maybe required to use a different database engine.
+ The PowerShell script does not currently save to the database directly. A data pipeline is needed to load the data into a database.

### Creating visualizations
+ Although outside the scope of this project, it is worth mentioning that the table created from CSV can be used as-is in visualization tools like Tableau or PowerBI. It can also be further normalized or transformed into a star schema for reporting.
+ Example of visualizations for repo usage in Tableau (using v1.0 of the script):
![EFDC GitHub Stats](https://github.com/DepressionCenter/GitHub-Usage-Stats/assets/42566461/87b98058-606c-4c00-a89f-a96d354266f2)


## Additional Resources
+ [GitHub API Documentation](https://docs.github.com/en/rest/metrics?apiVersion=2022-11-28)
+ [Microsoft's PowerShell wrapper](https://github.com/microsoft/PowerShellForGitHub) for the GitHub API



## About the Team
The Mobile Technologies Core provides investigators across the University of Michigan the support and guidance needed to utilize mobile technologies and digital mental health measures in their studies. Experienced faculty and staff offer hands-on consultative services to researchers throughout the University – regardless of specialty or research focus.



## Contact
To get in touch, contact the individual developers in the check-in history.

If you need assistance identifying a contact person, email the EFDC's Mobile Technologies Core at: efdc-mobiletech@umich.edu.



## Credits
#### Contributors:
+ Eisenberg Family Depression Center [(@DepressionCenter)](https://github.com/DepressionCenter/)
+ Gabriel Mongefranco [(@gabrielmongefranco)](https://github.com/gabrielmongefranco)
+ Special thanks to the U-M "HITS Academic Integrations" team and Joe Lipa for creating a data pipeline to load this script into a database.



#### This work is based in part on the following projects, libraries and/or studies:
+ Microsoft's [PowerShellForGitHub](https://github.com/microsoft/PowerShellForGitHub) module for PowerShell


## License
### Copyright Notice
Copyright © 2023 The Regents of the University of Michigan


### Software and Library License
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/gpl-3.0-standalone.html>.


### Documentation License
Permission is granted to copy, distribute and/or modify this document 
under the terms of the GNU Free Documentation License, Version 1.3 
or any later version published by the Free Software Foundation; 
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts. 
You should have received a copy of the license included in the section entitled "GNU 
Free Documentation License". If not, see <https://www.gnu.org/licenses/fdl-1.3-standalone.html>



## Citation
If you find this repository, code or paper useful for your research, please cite it.

----

Copyright © 2024 The Regents of the University of Michigan
