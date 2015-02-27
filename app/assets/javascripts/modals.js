$(document).on("page:change", function() {
  $(".modal-curtain").click(function() {
    $(".modal-curtain").hide();
  });

  $(".modal-popup").click(function(event){
    event.stopPropagation();
  });
});
