angular.module('vlg')

.directive('leftMenu', ->
  restrict: 'C'
  templateUrl: './pages/page-components/left-menu.html',
  link: (scope, elem, attr) ->
    scope.section = elem.attr('section') || null
)

.directive('rightPanelWrapper', ->
  restrict: 'C'
  templateUrl: './pages/page-components/right-panel-wrapper.html'
)
