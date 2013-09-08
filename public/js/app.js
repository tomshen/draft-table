// Generated by CoffeeScript 1.6.3
$('.toggleable').click(function() {
  return $(this).parent().toggleClass('open');
});

$('.plan-support').click(function() {
  var planId;
  planId = $(this).data('plan-id');
  return $.post("/plan/" + planId + "/support");
});

$('.proposal-support').click(function() {
  var proposalId;
  proposalId = $(this).data('proposal-id');
  return $.post("/proposal/" + proposalId + "/support");
});
