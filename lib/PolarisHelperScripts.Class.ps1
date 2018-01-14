class PolarisHelperScripts {
    static [string] InitializeRequestAndResponseScript() {
        return @'
            param($req, $res)
            $global:Request = $req
            $global:Response = $res
            
'@ 
    }
}
