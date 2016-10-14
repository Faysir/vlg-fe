angular.module('vlg')

.directive('left-menu', ->
    restrict: 'C'
    templateUrl: 'page-components/left-menu.html',
    scope: (elem, attr) ->
      section: attr.section || null
)