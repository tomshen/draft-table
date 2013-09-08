$('.toggleable').click () ->
    $(this).parent().toggleClass 'open'

$('.plan-support').click () ->
    planId = $(this).data('plan-id')
    $.post("/plan/#{planId}/support")

$('.proposal-support').click () ->
    proposalId = $(this).data('proposal-id')
    $.post("/proposal/#{proposalId}/support")