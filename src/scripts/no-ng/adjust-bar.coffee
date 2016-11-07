$(() ->
  $(document).on "mousedown.adjust-bar", ".adjust-button", (event) ->
    barEl = $(this).closest('.adjust-bar')
    totalHeight = barEl.height() / window.resizeRate
    currentPos = parseInt $(this).css('top').replace('px', '')
    barEl.data 'parentHeight', totalHeight
    barEl.data 'adjustState', true
    barEl.data 'adjustStartPosition', currentPos
    barEl.data 'adjustStartEventY', (event.pageY - $('.container').offset().top) / window.resizeRate

  $(document).on "mousemove.adjust-bar", ".adjust-bar", (event) ->
    if not $(this).data('adjustState')
      return
    totalHeight = $(this).data 'parentHeight'
    deltaPos = (event.pageY - $('.container').offset().top) / window.resizeRate - $(this).data 'adjustStartEventY'
    currentPos = $(this).data('adjustStartPosition') + deltaPos
    if currentPos < 0 || currentPos > totalHeight
      return
    currentPosResized = currentPos
    $(this).find('.adjust-button').css 'top', "#{currentPosResized}px"
    $(this).data 'value', Math.max(Math.min(1 - parseFloat(currentPos) / (parseFloat(totalHeight) - 1), 1), 0)
    $(this).trigger('change')

  $(document).on "mouseup.adjust-bar", (event) ->
    $('.adjust-bar').each ()->
      if $(this).data('adjustState')
        $(this).data 'adjustState', false
)