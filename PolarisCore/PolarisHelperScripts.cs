namespace PolarisCore
{
    public class PolarisHelperScripts
    {
        public static string InitializeRequestAndResponseScript => @"
            param($req, $res);
            $global:Request = $req;
            $global:Response = $res;";
    }
}