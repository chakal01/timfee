function editCoords(c){
  $("#dx").val(c.x);
  $("#dy").val(c.y);
  $("#width").val(c.w);
  $("#height").val(c.h);
};

function Jcropify(){
  $("#iconBase").Jcrop({
    aspectRatio: 1,
    minSize: [100, 100],
    boxWidth: 800, 
    boxHeight: 400,
    onChange: editCoords
  });
};
$(document).ready(function(){
  $("#previewhtml").html( $("#contenthtml").val() );

  $("#contenthtml").keyup(function() {
    $("#previewhtml").html( $("#contenthtml").val() );
  });


  $(".editTitleImage").click(function(){
    id = $(this).attr("name");
    if (!$("#titre_"+id).attr("readonly")){
      $.ajax({
        type: "POST",
        url: "/admin/img/"+id,
        data: {titre: $("#titre_"+id).val()}
      });
    }
    $(this).children("span").toggleClass("display-none");
    $("#titre_"+id).attr('readonly', !$("#titre_"+id).attr('readonly'));
  });

  $('#contenthtml').markItUp(mySettings);

  $(".tbselected").click(function(){ $(this).select(); });

});