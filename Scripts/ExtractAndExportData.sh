function ExtractAndExportData() {
    echo "Directory: " $PWD
    export Organization="`dirname $PWD | sed 's/\///g'`"
    if [[ $Organization == *"Holism"* ]]; then
        export OrganizationPrefix="Holism";
    else
        OrganizationPrefix=`echo $Organization | sed 's/Company//g'`
        export OrganizationPrefix=`echo $OrganizationPrefix | sed 's/Product//g'`
    fi
    export Repository="$(basename $PWD)"
    export RepositoryPath=$PWD
    echo "Organization: " $Organization
    echo "Organization Prefix: " $OrganizationPrefix
    echo "Repository: " $Repository
}