#
# * debouncedresize: special jQuery event that happens once after a window resize
# *
# * latest version and complete README available on Github:
# * https://github.com/louisremi/jquery-smartresize
# *
# * Copyright 2012 @louis_remi
# * Licensed under the MIT license.
# *
# * This saved you an hour of work? 
# * Send me music http://www.amazon.co.uk/wishlist/HNTU0468LQON
# 
#
#
#
# * JS -> Coffee with js2coffee.org

(($) ->
  $event = $.event
  $special = undefined
  resizeTimeout = undefined
  $special = $event.special.debouncedresize =
    setup: ->
      $(this).on "resize", $special.handler

    teardown: ->
      $(this).off "resize", $special.handler

    handler: (event, execAsap) ->
      
      # Save the context
      context = this
      args = arguments
      dispatch = ->
        
        # set correct event type
        event.type = "debouncedresize"
        $event.dispatch.apply context, args

      clearTimeout resizeTimeout  if resizeTimeout
      (if execAsap then dispatch() else resizeTimeout = setTimeout(dispatch, $special.threshold))

    threshold: 150
) jQuery

window.Hindsight = window.Hindsight ? {}

Hindsight = do ->
  settings =
    windo : $ window
    page : $ "html" 
    body : $ "body"
    menuToggle : $ "#dropdown-toggle"
    widePostNav : $ ".fixed-post-nav"
    topLink : $ ".top-link" 
    posts : $ ".page-type-index .post-body, .page-type-tag .post-body"
    field : $ "#field"
    content : $ "#content"
    tables : $ "table"
    homepagePathname : "/"
    touchDevice : 'ontouchstart' of window or 'onmsgesturechange' of window
    eventType   : if @touchDevice then 'touchstart' else 'click'
    remSize : ->
      settings.page.css "font-size"

  inititalize = ->
    s = settings
    console.log s
    initActions(s)
    bindActions(s)

  bindActions = (s) ->
    
    s.menuToggle.bind s.eventType, (e) ->
      s.page.toggleClass "dropdown-open"
    
    s.topLink.bind s.eventType, (e) ->
      scrollTop e

    s.posts.bind s.eventType, ->
      navigateToPost $(this).attr("data-post-id")

    s.widePostNav.bind s.eventType, ->
      navigateToPost $(this).attr("data-target-url").split("/").pop()
    
    s.windo.bind 'debouncedresize', ->
      pageWidthClass()
      
      if s.tables.length
        s.tables.each ->
          tableReflow $(this)
    
    s.content.waypoint (dir) ->
      if s.page.is(".no-touch.page-width-wide.first-index-page")
        fnWaypoint dir, s.page, "fixed-header"
      else
        s.page.removeClass "fixed-header"
    , offset: 6 * parseInt s.page.css "font-size"
    
    return
  
  scrollTop = (event) ->
    event.preventDefault()
    body.animate
      scrollTop: "0px"
    , 800
  
  navigateToPost = (postId) ->
    window.location.pathname = "/post/#{postId}"
  
  pageWidthClass = (w = window.innerWidth) ->
    
    classToAdd = (width) ->
      switch
        when width < 481 then "page-width-narrow"
        when width < 971 then "page-width-medium"
        else "page-width-wide"
    
    classList = [
      "page-width-narrow", 
      "page-width-medium", 
      "page-width-wide"
    ]
    
    settings.page
      .removeClass(classList.join(" "))
      .addClass(classToAdd(w))
    
    settings.widthClass = newClass
    
    return newClass
  
  arrayRemove = (array, value) ->
    if value in array
      return array.splice array.indexOf(value), 1
  
  fnWaypoint = (dir, target, cl) ->
    if dir is "down"
      target.addClass cl
    else if dir is "up"
      target.removeClass cl
    return target.is cl
  
  # all this does is turn the .table-reflowed class on and off
  # CSS does everything else.
  tableReflow = (table) ->
    parentWidth = table.parent().width()
    if table.width() > parent.width()
      table.addClass "table-reflowed"
    else 
      table.removeClass "table-reflowed"
  
  # call this on window.ready to prep tables for possible reflow   
  tableDataBind = (table) ->
    header = table.find "thead tr" 
    tableBody = table.find "tbody"
    columnVals = []
    header.children("th").each ->
      columnVals.push $(@).html()
    tableBody.find("tr").each ->
      $(@).find("td").each (i) ->
        $(@).attr "data-column-title", columnVals[i]
    
  # these are stupid functions to fix old mistakes or to set up elements that could be referenced in bindActions()
  initActions = (s) ->
    
    if s.tables.length
      s.tables.each ->
        tableDataBind $(this)
        tableReflow $(this)
    
    # Fix old formatting problems with post titles.
    # Not necessary when migrated away from Tumblr.
    # TODO remove Tumblr-specific fixes 
    do ->
      
      index = ".page-type-index"
      perma = ".page-type-perma"
      tag   = ".page-type-tag"
      
      if s.page.is perma
        $("h2").has("a").each (i) ->
          unless $(@).parents("article.post").is(".post-type-link")
            $(@).replaceWith "<h2 class='post-title'>#{$(@).text()}</h2>"
        $("a.post-title").each (i) ->
          $(@).replaceWith "<h2 class='post-title'>#{$(@).text()}</h2>"
      else if (s.page.is index) or (s.page.is tag)
        $("a").has("h2").each (i) ->
          postId = $(@).parents('article').attr('data-post-id')
          $(@).replaceWith "<h2 class='post-title'><a href='http://20-20hindsight.tumblr.com/post/#{postId}'>#{$(@).text()}</a></h2>"

      unless s.page.is perma
        $("div.read-more").each (i) ->
          postId = $(this).parents(".post-body").attr("data-post-id")
          $(this).addClass("closed klosed").before("<p><a class='read-more-link' href='http://20-20hindsight.tumblr.com/post/#{postId}'>Read More...</a></p>")
          console.log "unless ran x#{i}"
          
    pageWidthClass()
    
    s.page.addClass "first-index-page"  if window.location.pathname is s.homepagePathname
    s.page.addClass if s.touchDevice then "yes-touch" else "no-touch"
    
  init : inititalize
  widthClass : pageWidthClass
  settings : settings
  reflow : (t) ->
    tableReflow(t)
### end module ###