# Determine whether the build passed
try {
    # this throws if there was an error
    Invoke-Pester
    $result = "PASS"
}
catch {
    $resultError = $_
    $result = "FAIL"
}