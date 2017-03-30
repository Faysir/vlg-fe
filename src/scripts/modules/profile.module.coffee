angular.module('vlg')

.controller('profileCtl', ['$scope', '$state', '$stateParams', ($scope, $state, $stageParams) ->
  return
])

.controller('profileInventoryCtl', ['$scope', '$state', '$stateParams', ($scope, $state, $stageParams) ->
  $scope.inventoryItems = ({id: i} for i in [1..20]);
])

.directive('inventoryPropsItem', ->
  restrict: 'C'
  templateUrl: './pages/profile/inventory-props-item.html',
  scope:
    inventoryItem: "=item"
  link: (scope, elem, attr) ->
    return
)