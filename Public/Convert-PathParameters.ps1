function Convert-PathParameters {

    param(
        [string]$path
    )
    
    $path = "^$path$"
    $path = $path -replace "\{", "(?<"
    $path = $path -replace "\}", ">.*)"

    $path

}