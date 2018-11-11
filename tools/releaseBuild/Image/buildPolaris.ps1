param ( [string]$target )
if ( ! (test-path ${target} ) ) {
    new-item -type directory ${target}
}
else {
    if ( test-path -pathtype leaf ${target} ) {
        remove-item -force ${target}
        new-item -type directory ${target}
    }
}
push-location C:\Polaris
./build.ps1 -Test -Package
Copy-Item -Verbose -Recurse "C:/Polaris/out/Polaris" "${target}/Polaris"
