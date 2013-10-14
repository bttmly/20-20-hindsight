window.ModuleName = window.ModuleName ? {}

ModuleName = do ->

	$ = jQuery

	settings =
		window : $(window)
		body : $("body")
		# cache jQuery objects here

	init = ->
		pageSetup()
		uiBinding()

	pageSetup = ->
		# anything that should run on $(document).ready
		# and ISN'T a UI binding
		# this comes before uiBinding() since elements might be created or modified here
		# may want to update settings with new cached elements at the end of this function

	uiBinding = ->
		# No function logic here. UI event bindings as follows:
		# element.bind 
		#   click : ->
		#			functionToCall()
		#  
		# functionToCall() should be declared at the same scope as uiBinding() 

	addSetting = (key, val) ->
		# won't overwrite existing settings
		if settings[key]?
			return false
		else
			settings[key] = val
			return settings[key]

	getSetting = (key) ->
		return settings[key]

	# an object of utility functions
	utils =
		arrayRemove : (arr, val) ->
	    if val in arr
	      return arr.splice arr.indexOf(val), 1
	    else 
	    	return false

	  removeStringDuplicates : (arr) ->
		  out = []
		  obj = {}
		  for a in arr
		    obj[a] = 0
		  for b of obj
		    out.push b
		  return out
  	
		tableDataAttach : ($table) ->
			if $table.data("tableColumnAttached")
				return true
			columnVals = []
			$headerRow = $table.find("tr").eq(0)
			$tableBody = $table.find("tr").not($headerRow)
			$headerRow.find("td").each ->
				columnVals.push $(@).html()
			$tableBody.each ->
				$(@).find("td").each (i) ->
					$(@).attr "data-column-name", columnVals[i]
			if $table.find("td").is("[data-column-name]")
				$tale.attr("data-table-column-attached", true)
				return true
			else
				return false

	# these will be publicly available under the module's namespace
	# anything not returned here will be private to the module
	init : init
	addSetting : addSetting
	getSetting : getSetting
	utils : utils


