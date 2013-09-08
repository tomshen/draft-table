$('.toggleable').click () ->
    $(this).parent().toggleClass 'open'

$('.plan-support').click () ->
    planId = $(this).data('plan-id')
    $.post("/plan/#{planId}/support")

$('.proposal-support').click () ->
    proposalId = $(this).data('proposal-id')
    $.post("/proposal/#{proposalId}/support")

loadPlan = (planId) ->
    console.log planId
    $('.plan-container').hide()
    console.log $(planId)
    $(planId).show()

$('.plan-link').click () ->
    loadPlan($(this).attr('href'))

$(document).ready () ->
    loadPlan(window.location.hash)