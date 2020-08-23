#import-module PSHTML
New-PolarisGetRoute -Path "/" -Scriptblock {
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
                div -Class "logo" -Content {
                    img -src "assets/expertslive-logo.jpg" -alt "ExpertsLive EU"
                }

                h1 -Content {
                    "Hello,
                    <br />
                    PowerShell users"
                }
            }
            div -Class "responsive" -Content {
                div -Class "gallery" -Content {
                    img -src "assets/kubernetes-logo.png" alt="Kubernetes" -width "400" -height "200"
                }
                div -Class "gallery" -Content {
                    img -src "assets/docker-logo.png" alt="Docker" -width "400" -height "200"
                }
                div -Class "gallery" -Content {
                    img -src "assets/powershell-core.jpg" alt="PowerShell" -width "400" -height "200"
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