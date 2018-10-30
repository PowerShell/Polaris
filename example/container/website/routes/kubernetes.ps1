#import-module PSHTML

New-PolarisGetRoute -Path "/kubernetes" -Scriptblock {
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
                    "kubernetes"
                }
            }
            div -Class "responsive" -Content {
               h3 -Content "a list of resources"
               ul -class "resources" -Content {
                li -class "resourceitem" -Content {
                    a -Class "resourcelink" -href "https://kubernetes.io/" -Content "Kubernetes"
                }
                li -class "resourceitem" -Content {
                    a  -Class "resourcelink" -href "https://azure.microsoft.com/en-us/services/kubernetes-service/" -Content "AKS (Azure kubernetes service)"
                }
               li -class "resourceitem" -Content {
                   a  -Class "resourcelink" -href "https://github.com/kelseyhightower/kubernetes-the-hard-way" -Content "Kubernetes the hard way"
               }
               li -class "resourceitem" -Content {
                a  -Class "resourcelink" -href "https://azure.microsoft.com/en-us/resources/videos/the-illustrated-children-s-guide-to-kubernetes/" -Content "The illustrated children's guide to kubernetes"
                }
                li -class "resourceitem" -Content {
                    a  -Class "resourcelink" -href "https://github.com/Stephanevg/PSHTML" -Content "Children's guide to kubernetes"
                    }
           }

           h3 -Content {
               "Does it end here? no, this is only the beginning!  (think security, management, ...)"
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