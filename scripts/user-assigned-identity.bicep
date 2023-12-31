param name string
param location string = resourceGroup().location
param identityExists bool

output userAssignedIdentity object = {
  id: (identityExists) ? userAssignedIdentityExistingResource.id: userAssignedIdentityResource.id
  principalId: (identityExists) ? userAssignedIdentityExistingResource.properties.principalId : userAssignedIdentityResource.properties.principalId
  principalType: 'ServicePrincipal'
  clientId: (identityExists) ? userAssignedIdentityExistingResource.properties.clientId : userAssignedIdentityResource.properties.clientId
  name: name
}

resource userAssignedIdentityResource 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = if(!identityExists){
  name: name
  location: location
}

resource userAssignedIdentityExistingResource 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = if(identityExists) {
  name: name
}

resource galleryAccessRole 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' = {
  name: guid(resourceGroup().id, 'GalleryAccessCustomRole')
  properties: {
    roleName: 'GalleryAccessCustomRole-${guid(resourceGroup().id)}'
    type: 'customRole'
    permissions: [
      {
        actions: [
          'Microsoft.Compute/galleries/read'
          'Microsoft.Compute/galleries/images/read'
          'Microsoft.Compute/galleries/images/versions/read'
          'Microsoft.Compute/galleries/images/versions/write'
          'Microsoft.Compute/images/write'
          'Microsoft.Compute/images/read'
          'Microsoft.Compute/images/delete'
        ]
        notActions: []
      }
    ]
    assignableScopes: [
      resourceGroup().id
    ]
  }
}

resource customRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = if(!identityExists) {
  name: guid(resourceGroup().id, (identityExists) ? userAssignedIdentityExistingResource.id: userAssignedIdentityResource.id, galleryAccessRole.id)
  properties: {
    principalId: (identityExists) ? userAssignedIdentityExistingResource.properties.principalId : userAssignedIdentityResource.properties.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: galleryAccessRole.id
  }
}

resource contributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  name: 'b24988ac-6180-42a0-ab88-20f7382dd24c' //'Contributor'
}

resource contributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = if(!identityExists) {
  name: guid(subscription().id, (identityExists) ? userAssignedIdentityExistingResource.id: userAssignedIdentityResource.id, contributorRoleDefinition.id)
  properties: {
    principalId: (identityExists) ? userAssignedIdentityExistingResource.properties.principalId : userAssignedIdentityResource.properties.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: contributorRoleDefinition.id
  }
}
