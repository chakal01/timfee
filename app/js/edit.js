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
    $(".editTitleImage span").toggleClass("display-none");
    $("#titre_"+id).attr('readonly', !$("#titre_"+id).attr('readonly'));
  });

  $('#contenthtml').markItUp(mySettings);

  $(".tbselected").click(function(){ $(this).select(); });

  /* Order image galery */

  /* Return a helper with preserved width of cells */
  var fixHelper = function(e, ui) {
    ui.children().each(function() {
      $(this).width($(this).width());
    });
    return ui;
  };

  $("#galerie").sortable({
    helper: fixHelper,
    handle: $(".sortable-handler"),
    stop: function(){
      var list = [];
      $(".img_id").each(function(elem){
        list.push($(this).html());
      });
      console.log("stop")
      console.log(list)
      $.ajax({
        method: 'post',
        url: "/admin/orderimg",
        data: {"list": list}
      });
    }
  }).disableSelection();

});