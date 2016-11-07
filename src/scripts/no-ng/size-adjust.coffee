
$(window).resize(->

  defaultWidth = 1920
  defaultHeight = 1080
  defaultFontSize = 10

  windowWidth = $(window).width()
  windowHeight = $(window).height()

  # if (windowWidth / windowHeight > defaultWidth / defaultHeight)
  resizeRate = if (windowWidth * defaultHeight  > defaultWidth * windowHeight ) then (parseFloat(windowHeight) / parseFloat(defaultHeight)) else (parseFloat(windowWidth) / parseFloat(defaultWidth))

#  resizedFontSize = defaultFontSize * resizeRate
#  resizedWidth = defaultWidth * resizeRate
#  resizedHeight = defaultHeight * resizeRate
#  marginHor = (windowWidth - resizedWidth) / 2
#  marginVer = (windowHeight - resizedHeight) / 2
#
#  $('html,body').css({
#    'font-size': resizedFontSize + 'px'
#  }, )
#
#  $('.container').css({
#    'width': resizedWidth + 'px'
#    'height': resizedHeight + 'px'
#    'margin-top': marginVer + 'px'
#    'margin-bottom': marginVer + 'px'
#    'margin-left': marginHor + 'px'
#    'margin-right': marginHor + 'px'
#  })
#
#  return true

#  marginVer = (windowHeight / resizeRate - defaultHeight) / 2
#  marginHor = (windowWidth / resizeRate - defaultWidth) / 2
#  $('.container').css({
#    'zoom': resizeRate
#    'margin-top': marginVer + 'px'
#    'margin-bottom': marginVer + 'px'
#    'margin-left': marginHor + 'px'
#    'margin-right': marginHor + 'px'
#  })

  marginVer = (windowHeight - defaultHeight * resizeRate ) / 2
  marginHor = (windowWidth - defaultWidth * resizeRate ) / 2
  $('.container').css({
    'transform': 'scale(' + resizeRate + ')'
    'transform-origin': '0 0'
    'margin-top': marginVer + 'px'
    'margin-bottom': marginVer + 'px'
    'margin-left': marginHor + 'px'
    'margin-right': marginHor + 'px'
  })

  window.resizeRate = resizeRate

  return true
)

$(document).ready(->
  $(window).resize()
  $('.container').show()

  return true
)