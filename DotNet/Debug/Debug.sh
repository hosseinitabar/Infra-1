#!/bin/bash

# debug is better to work both inside .sln directory and .csproj directory
# have a fallback of what project should be debugged, based on conventional naming (for example if none is provided, debug Api/Api.csproj)

. /HolismHolding/Infra/Scripts/GetDotNetInfra.sh
. /HolismHolding/Infra/Scripts/LinkGitIgnore.sh
. /HolismHolding/Infra/Scripts/GetDependencies.sh

function LinkDevContainer() {
    
    if [ -d "$PWD/$SelectedProject/.devcontainer" ]; then
        sudo rm -rf "$PWD/$SelectedProject/.devcontainer"
    fi

    sudo mkdir $PWD/$SelectedProject/.devcontainer
    sudo chmod -R 777 $PWD/$SelectedProject/.devcontainer
    sudo ln -s /HolismHolding/Infra/DotNet/Debug/devcontainer "$PWD/$SelectedProject/.devcontainer/devcontainer.json"
}

function LinkVSCodeFiles() {
    if [ -d "$PWD/.vscode" ]; then
        sudo rm -rf "$PWD/.vscode"
    fi
    sudo mkdir $PWD/.vscode
    sudo chmod -R 777 $PWD/.vscode
    
    sudo ln -s /HolismHolding/Infra/DotNet/Debug/launch "$PWD/.vscode/launch.json"
    sudo ln -s /HolismHolding/Infra/DotNet/Debug/tasks "$PWD/.vscode/tasks.json"
}

function PullDotNetDockerImage() {
    echo 'Pulling docker image: holism/dotnet-debug:latest'
    docker pull holism/dotnet-debug:latest
}

function DebugDotNet() {

    if [ -z "$SelectedProject" ]; then
        if [ ! -d "$PWD/Api" ]; then
            echo -e '\033[0;31m'"You should provide the project name to debug";
            exit;
        fi
        if [ -f "$PWD/Api/Startup.cs" ]; then
            echo -e '\033[0;31m'"You are debugging in the wrong directory";
            exit;
        fi
        export SelectedProject=Api
    fi

    echo $SelectedProject;

    exit;

    GetDotNetInfra &
    volumes=""
    GetDependencies volumes
    echo -e $volumes
    LinkGitIgnore $PWD
    # PullDotNetDockerImage    echo "DotNet, runnable|host|app"
    LinkDevContainer
    LinkVSCodeFiles
    ComposeFile=/Temp/$Organization/$Repository/debug.yml
    mkdir -p $(dirname $ComposeFile)
    envsubst < /HolismHolding/Infra/DotNet/Debug/debug.yml > $ComposeFile
    sed -i "s/VolumeMappingPlaceHolder/$volumes/g" $ComposeFile
    sed -i "s/*/\//g" $ComposeFile
    docker-compose -p "${Organization}_${Repository}" -f $ComposeFile up --remove-orphans
}