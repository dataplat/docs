
$ContentFolder = "$PSScriptRoot"
$rootdomain = 'https://docs.dbatools.io'

$OutputFolder = [System.IO.Path]::GetFullPath((Join-Path (Join-Path $PSScriptRoot '..') '..'))

if ($PSVersionTable.PSVersion.Major -lt 7) {
    if (-not(Get-Command Convert-MarkdownToHTMLFragment -ErrorAction SilentlyContinue)) {
        Write-Warning "Please install MarkdownToHtml"
        return
    }
}


$initScript = {
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        Import-Module -Name MarkdownToHtml
    }

    function Get-DbadocsEscaped($str) {
        return [System.Security.SecurityElement]::Escape($str)
    }

    function Get-DbaDocsMD($doc_to_render) {

        $rtn = New-Object -TypeName "System.Collections.ArrayList"
        $null = $rtn.Add("# $($doc_to_render.CommandName)" )
        if ($doc_to_render.Author -or $doc_to_render.Availability) {
            $null = $rtn.Add('|  |  |')
            $null = $rtn.Add('| - | - |')
            if ($doc_to_render.Author) {
                $null = $rtn.Add('|  **Author**  | ' + $doc_to_render.Author.replace('|', ',') + ' |')
            }
            if ($doc_to_render.Availability) {
                $null = $rtn.Add('| **Availability** | ' + $doc_to_render.Availability + ' |')
            }
            $null = $rtn.Add('')
        }
        $null = $rtn.Add("`n" + '&nbsp;' + "`n")
        if ($doc_to_render.Alias) {
            $null = $rtn.Add('')
            $null = $rtn.Add('*Aliases : ' + $doc_to_render.Alias + '*')
            $null = $rtn.Add('')
        }
        $null = $rtn.Add('## Synopsis')
        $null = $rtn.Add($doc_to_render.Synopsis)
        $null = $rtn.Add('')
        $null = $rtn.Add('## Description')
        $null = $rtn.Add($doc_to_render.Description)
        $null = $rtn.Add('')
        if ($doc_to_render.Syntax) {
            $null = $rtn.Add('## Syntax')
            $null = $rtn.Add('```')
            $splitted_paramsets = @()
            foreach ($val in ($doc_to_render.Syntax -split $doc_to_render.CommandName)) {
                if ($val) {
                    $splitted_paramsets += $doc_to_render.CommandName + $val
                }
            }
            foreach ($syntax in $splitted_paramsets) {
                $x = 0
                foreach ($val in ($syntax.Replace("`r", '').Replace("`n", '') -split ' \[')) {
                    if ($x -eq 0) {
                        $null = $rtn.Add($val)
                    } else {
                        $null = $rtn.Add('    [' + $val.replace("`n", '').replace("`n", ''))
                    }
                    $x += 1
                }
                $null = $rtn.Add('')
            }

            $null = $rtn.Add('```')
            $null = $rtn.Add("`n" + '&nbsp;' + "`n")
        }
        $null = $rtn.Add('')
        $null = $rtn.Add('## Examples')
        $null = $rtn.Add("`n" + '&nbsp;' + "`n")
        $examples = $doc_to_render.Examples.Replace("`r`n", "`n") -replace '(\r\n){2,8}', '\n'
        $examples = $examples.replace("`r", '').split("`n")
        $inside = 0
        foreach ($row in $examples) {
            if ($row -like '*----') {
                $null = $rtn.Add("");
                $null = $rtn.Add('#####' + ($row -replace '-{4,}([^-]*)-{4,}', '$1').replace('EXAMPLE', 'Example: '))
            } elseif (($row -like 'PS C:\>*') -or ($row -like '>>*')) {
                if ($inside -eq 0) { $null = $rtn.Add('```') }
                $null = $rtn.Add(($row.Trim() -replace 'PS C:\\>\s*', "PS C:\> "))
                $inside = 1
            } elseif ($row.Trim() -eq '' -or $row.Trim() -eq 'Description') {

            } else {
                if ($inside -eq 1) {
                    $inside = 0
                    $null = $rtn.Add('```')
                }
                $null = $rtn.Add("$row<br>")
            }
        }
        if ($inside -eq 1) {
            $inside = 0
            $null = $rtn.Add('```')
        }
        if ($doc_to_render.Params) {
            $dotitle = 0
            $filteredparams = @()
            foreach ($p in $doc_to_render.Params) {
                if ($p[3] -eq $true) {
                    $filteredparams += , $p
                }
            }
            $dotitle = 0
            foreach ($el in $filteredparams) {
                if ($dotitle -eq 0) {
                    $dotitle = 1
                    $null = $rtn.Add('### Required Parameters')
                }
                $null = $rtn.Add('##### -' + $el[0])
                $null = $rtn.Add($el[1] + '<br>')
                $null = $rtn.Add('')
                $null = $rtn.Add('|  |  |')
                $null = $rtn.Add('| - | - |')
                $null = $rtn.Add('| Alias | ' + $el[2] + ' |')
                $null = $rtn.Add('| Required | ' + $el[3] + ' |')
                $null = $rtn.Add('| Pipeline | ' + $el[4] + ' |')
                $null = $rtn.Add('| Default Value | ' + $el[5] + ' |')
                if ($el[6]) {
                    $null = $rtn.Add('| Accepted Values | ' + $el[6] + ' |')
                }
                $null = $rtn.Add('')
            }
            $dotitle = 0
            $filteredparams = @()
            foreach ($p in $doc_to_render.Params) {
                if ($p[3] -eq $false) {
                    $filteredparams += , $p
                }
            }
            foreach ($el in $filteredparams) {
                if ($dotitle -eq 0) {
                    $dotitle = 1
                    $null = $rtn.Add('### Optional Parameters')
                }

                $null = $rtn.Add('##### -' + $el[0])
                $null = $rtn.Add($el[1] + '<br>')
                $null = $rtn.Add('')
                $null = $rtn.Add('|  |  |')
                $null = $rtn.Add('| - | - |')
                $null = $rtn.Add('| Alias | ' + $el[2] + ' |')
                $null = $rtn.Add('| Required | ' + $el[3] + ' |')
                $null = $rtn.Add('| Pipeline | ' + $el[4] + ' |')
                $null = $rtn.Add('| Default Value | ' + $el[5] + ' |')
                if ($el[6]) {
                    $null = $rtn.Add('| Accepted Values | ' + $el[6] + ' |')
                }
                $null = $rtn.Add('')
            }
        }

        $null = $rtn.Add('')
        $null = $rtn.Add("`n" + '&nbsp;' + "`n")
        $null = $rtn.Add('Want to see the source code for this command? Check out [' + $doc_to_render.CommandName + '](https://github.com/dataplat/dbatools/blob/master/functions/' + $doc_to_render.CommandName + '.ps1) on GitHub.')
        $null = $rtn.Add("<br>")
        $null = $rtn.Add('Want to see the Bill Of Health for this command? Check out [' + $doc_to_render.CommandName + '](https://dataplat.github.io/boh#' + $doc_to_render.CommandName + ').')
        $null = $rtn.Add('')

        return $rtn
    }


    function Set-DbadocsPage($doc_to_render, $OutputFolder, $ContentFolder) {
        $page_template_static = Get-Content (Join-Path $ContentFolder "page_template_static.html.template")

        $cmdname = $doc_to_render.Name
        $cmdtags = @('dbatools')
        if ($doc_to_render.Tags) {
            $cmdtags += $c.Tags
        }
        $cmdtags = $cmdtags -Join ', '
        $page_template_static = $page_template_static.Replace('$____TAGS____$', (Get-DbadocsEscaped $cmdtags)).Replace('$____COMMANDNAME____$', (Get-DbadocsEscaped $cmdname))

        $MDContent = Get-DbaDocsMD -doc_to_render $doc_to_render
        if ($PSVersionTable.PSVersion.Major -lt 7) {
            $HTMLFragmentContent = ($MDContent -Join "`n" | Convert-MarkdownToHTMLFragment).HtmlFragment
        } else {
            $HTMLFragmentContent = ($MDContent -Join "`n" | ConvertFrom-Markdown).Html
        }
        $page_template_static = $page_template_static.Replace('$____RENDERED____$', $HTMLFragmentContent)
        $page_template_static | Out-File (Join-Path $OutputFolder "$($doc_to_render.Name).html") -Encoding Unicode
    }
}


function Set-DbadocsIndex($OutputFolder, $ContentFolder) {
    Copy-Item -Path (Join-Path $ContentFolder 'index.html.template') -Destination (Join-Path $OutputFolder 'index.html')
}

function Set-DbadocsOSearch($OutputFolder, $ContentFolder) {
    Copy-Item -Path (Join-Path $ContentFolder 'opensearch.xml.template') -Destination (Join-Path $OutputFolder 'opensearch.xml')
}

function Get-DocsRobotsTxt ($idx, $OutputFolder) {
    $curdate = "{0:s}Z" -f (Get-Date).ToUniversalTime()

    [xml]$xmlDoc = New-Object System.Xml.XmlDocument
    $decl = $xmlDoc.CreateXmlDeclaration("1.0", "UTF-8", $null)
    $ns = 'http://www.sitemaps.org/schemas/sitemap/0.9'

    $urlset = $xmlDoc.CreateElement('urlset', $ns)

    $null = $xmlDoc.AppendChild($urlset)

    $null = $xmlDoc.InsertBefore($decl, $xmlDoc.DocumentElement)
    foreach ($c in $idx) {
        $cmdname = $c.Name
        $urlin = $xmlDoc.CreateElement('url', $ns)
        $docin = $xmlDoc.CreateElement('loc', $ns)
        $docin.InnerText = "$rootdomain/$cmdname"
        $lastmod = $xmlDoc.CreateElement('lastmod', $ns)
        $lastmod.InnerText = $curdate
        $null = $urlin.AppendChild($docin)
        $null = $urlin.AppendChild($lastmod)
        $null = $urlset.AppendChild($urlin)
    }

    $xmlDoc.Save((Join-Path $OutputFolder "sitemap.xml"))

    "Sitemap: $rootdomain/sitemap.xml" | Out-File (Join-Path $OutputFolder "robots.txt") -Encoding UTF8
}

function Split-ArrayInParts($array, [int]$parts) {
    #splits an array in "equal" parts
    $size = $array.Length / $parts
    $counter = [pscustomobject] @{ Value = 0 }
    $groups = $array | Group-Object -Property { [math]::Floor($counter.Value++ / $size) }
    $rtn = @()
    foreach ($g in $groups) {
        $rtn += , @($g.Group)
    }
    $rtn
}

$sw = [System.Diagnostics.Stopwatch]::StartNew()

#get json index path
$idxPath = Join-Path (Join-Path $OutputFolder 'assets') 'dbatools-index.json'

#get help in json format
$idx = Get-Content $idxPath | ConvertFrom-Json

#create robots
Write-Host "Creating robots.txt"
Get-DocsRobotsTxt -idx $idx -OutputFolder $OutputFolder
#create index
Write-Host "Creating index.html"
Set-DbadocsIndex -OutputFolder $OutputFolder -ContentFolder $ContentFolder
#create opensearch
Write-Host "Creating opensearch.xml"
Set-DbadocsOSearch -OutputFolder $OutputFolder -ContentFolder $ContentFolder

#create all pages
try {
    $maxConcurrentJobs = (Get-CimInstance -ClassName Win32_Processor -Property NumberOfCores | Measure-Object -Property 'NumberOfCores' -Sum).Sum
} catch {
    $maxConcurrentJobs = 4
}
$whatever = Split-ArrayInParts -array $idx -parts $maxConcurrentJobs
$jobs = @()
Write-Host "Creating docs pages"
foreach ($piece in $whatever) {
    $jobs += Start-Job -InitializationScript $initScript -ScriptBlock {
        foreach ($p in $Args) {
            Set-DbadocsPage -doc_to_render $p -OutputFolder $using:OutputFolder -ContentFolder $using:ContentFolder
        }
    } -ArgumentList $piece
}
$null = $jobs | Wait-Job #-Timeout 120
$null = $jobs | Receive-Job
Get-ChildItem $OutputFolder
Write-Host "Done: elapsed $($sw.ElapsedMilliseconds) ms"