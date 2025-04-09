param($Version = "latest")	

Describe "Module Verification" {
    BeforeAll {
        docker pull ironmansoftware/universal:latest
        docker run -d --name universal -p 5000:5000 -e PSUDefaultAdminName="admin" -e PSUDefaultAdminPassword="admin" ironmansoftware/universal:latest

        $Resource = @{
            Name = "Universal"
        }

        if ($Version -ne "latest") {
            $Resource.Version = $Version
        }

        Set-PSResourceRepository -Name "PSGallery" -Trusted
        Install-PSResource @Resource
    
        while ($true) {
            try {
                $response = Invoke-RestMethod -Uri http://localhost:5000/api/v1/alive -Method Get
                if ($response -and -not $response.Loading) {
                    break
                }
            }
            catch {
                Start-Sleep -Seconds 1
            }
        }

        Invoke-RestMethod -Uri http://localhost:5000/api/v1/signin -Method "POST" -Body (@{
                UserName = "admin"
                Password = "admin"
            } | ConvertTo-Json) -ContentType "application/json" -ErrorAction Stop -SessionVariable "Session"

        $Token = Invoke-RestMethod -Uri http://localhost:5000/api/v1/apptoken/grant -WebSession $Session

        Connect-PSUServer -ComputerName "http://localhost:5000" -AppToken $Token.Token -ErrorAction Stop

        New-PSUScript -Name 'Test.ps1' -ScriptBlock {
            param($Name, $Version, $Command)

            $TempPath = Join-Path ([IO.Path]::GetTempPath()) (Get-Random)
            New-Item -Path $TempPath -ItemType Directory -Force | Out-Null
            Set-PSResourceRepository -Name "PSGallery" -Trusted
            Save-PSResource -Name $Name -Version $Version -Path $TempPath -Repository 'PSGallery' | Out-Null

            $ENV:PSModulePath = $ENV:PSModulePath + ":$TempPath" 
            
            Import-Module $Name -ErrorAction Stop | Out-Null
            Invoke-Expression $Command | Out-Null
        } -ErrorAction Stop 
    }
    AfterAll {
        docker stop universal
        docker rm universal
    }

    It "imports <expected> (<name>)" -ForEach @(
        @{Name = "dbatools"; Version = "2.1.30"; Environment = "PowerShell 7"; Command = { Get-DbaDatabase } }
        @{Name = "Microsoft.Graph.Authentication"; Version = "2.26.1"; Environment = "PowerShell 7"; Command = { Connect-MgGraph -AccessToken 'xyz' } }
    ) { 
        Invoke-PSUScript -Name 'Test.ps1' -Parameters @{
            Name    = $Name
            Version = $Version
            Command = $Command.ToString()
        } -Wait -ErrorAction Stop 
    }
}
