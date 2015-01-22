# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

      #createLink = (annotation) ->  "<a href=\"#\" onclick=\"editor.focus(); editor.scrollToLine(" + annotation.row.toString() + ",true); editor.#gotoLine(" + (annotation.row+ 1).toString() + ",10, true);\">" + (annotation.row+ 1).toString() + ": " + annotation.text + "</a><br>"