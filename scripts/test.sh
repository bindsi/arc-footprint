#! /bin/bash
resourceGroupName=rg-arc-footprint
vmName=WinServer
subscriptionId=$(az account show --query id -o tsv)
tenantId=$(az account show --query tenantId -o tsv)
osType=$(az vm show -g $resourceGroupName -n $vmName --query storageProfile.osDisk.osType -o tsv)
echo $osType
az vm extension set \
    --resource-group $resourceGroupName \
    --vm-name $vmName \
    --name CustomScriptExtension \
    --publisher Microsoft.Compute \
    --force-update \
    --settings "{\"commandToExecute\":\"powershell Get-AksEdgeKubeConfig -Confirm:\$false; \\
        kubectl get pods -A; \\
        az login --service-principal -u \"\"<yourappid>\"\" -p \"\"<yourappsecret>\"\" --tenant \"\"$tenantId\"\"; \\
    \"}"

    # --settings '{"commandToExecute": "powershell -Command \{ \
    #     az login --service-principal -u ${{ secrets.AZURE_CLIENT_ID }} -p ${{ secrets.AZURE_CLIENT_SECRET }} --tenant $tenantId; \
    #     Get-AksEdgeKubeConfig -Confirm:\$false; \
    #     az provider register -n "Microsoft.ExtendedLocation"; \
    #     az provider register -n "Microsoft.Kubernetes"; \
    #     az provider register -n "Microsoft.KubernetesConfiguration"; \
    #     az provider register -n "Microsoft.IoTOperationsOrchestrator"; \
    #     az provider register -n "Microsoft.IoTOperationsMQ"; \
    #     az provider register -n "Microsoft.IoTOperationsDataProcessor"; \
    #     az provider register -n "Microsoft.DeviceRegistry"; \
    #     az extension add --name connectedk8s; \
    #     az extension add --name azure-iot-ops; \
    #     az connectedk8s connect -n arc-aksEEAIO-${{github.run_id}} -l ${{ inputs.location }} -g ${{ inputs.resourceGroupName }} --subscription $subscriptionId; \
    #     az connectedk8s enable-features -n arc-aksEEAIO-${{github.run_id}} -g ${{ inputs.resourceGroupName }} --custom-locations-oid ${{ secrets.CUSTOM_LOCATIONS_OBJECT_ID }} --features cluster-connect custom-locations; \
    #     az iot ops init --cluster arc-aksEEAIO-${{github.run_id}} -g ${{ inputs.resourceGroupName }} --kv-id $(az keyvault create -n kv-aksEEAIO-${{github.run_id}} -g ${{ inputs.resourceGroupName }} -o tsv --query id) --sp-app-id ${{ secrets.AZURE_SP_CLIENT_ID }} --sp-object-id ${{ secrets.AZURE_SP_OBJECT_ID }} --sp-secret ${{ secrets.AZURE_SP_CLIENT_ID }}; \
    #     \}"}'
