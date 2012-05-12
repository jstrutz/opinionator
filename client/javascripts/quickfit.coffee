
$ ->
  $(window).on 'resize', ->
    # Title
    $("body > header h1").quickfit
      min: 16
      max: 400
      truncate: false
      
    # Choices
    $(".choice p").quickfit
      min: 16
      max: 400
      truncate: false
      
  # $(window).trigger 'resize'
  setTimeout ->
    $(window).trigger 'resize'
  , 0.01