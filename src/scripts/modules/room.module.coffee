angular.module('vlg')

.controller('roomCtl', ['$scope', '$state', '$stateParams', ($scope, $state, $stageParams) ->
  $scope.players = ({idx:i} for i in [1..16])
  return
])