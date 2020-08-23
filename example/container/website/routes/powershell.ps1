#import-module PSHTML

New-PolarisGetRoute -Path "/powershell" -Scriptblock {
    $Response.SetContentType('text/html')
    $res = html {
        head -Content {
            Link -href "https://fonts.googleapis.com/css?family=Roboto" -rel "stylesheet"
            Link -href "assets/style.css" -rel "stylesheet"
        }
        body -Content {
            nav -Content {
                ul -Content {
                    li -Content {
                        a -href "/powershell" -Content "POWERSHELL"
                    }
                    li -Content {
                        a -href "/kubernetes" -Content "KUBERNETES"
                    }
                    li -Content {
                        a -href "/" -Content "HOME"
                    }
                }
            }
            header -Content {
                h1 -Content {
                    "powershell"
                }
            }
            div -Class "responsive" -Content {
               h3 -Content "a list of resources"
               ul -class "resources" -Content {
                li -class "resourceitem" -Content {
                        a -Class "resourcelink" -href "https://github.com/PowerShell/PowerShell" -Content "PowerShell Core"
                    }
                    li -class "resourceitem" -Content {
                        a -Class "resourcelink" -href "https://powershellgallery.com" -Content "PowerShell Gallery"
                    }
                    li -class "resourceitem" -Content {
                       a -Class "resourcelink" -href "https://github.com/PowerShell/Polaris" -Content "Polaris"
                   }
                   li -class "resourceitem" -Content {
                    a -Class "resourcelink" -href "https://github.com/Stephanevg/PSHTML" -Content "PSHTML"
                    }

               }
            }
            div -Class "clearfix"
            footer -Content {
                $PSHTMLlink = a {"PSHTML"} -href "https://github.com/Stephanevg/PSHTML"
                $POLARISlink = a {"Polaris"} -href "https://github.com/PowerShell/Polaris"
                h2 -Content {"Generated with &#9829 using $($POLARISlink) + $($PSHTMLlink)"}
                h3 -Content {"I'm running on $($Env:HOSTNAME)"}
                p -Content {"Stijn.Callebaut[at]itnetx.be"}
            }
        }
    }
    $Response.Send($res)
}