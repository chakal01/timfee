$(document).ready(function(){
  $(".switch-actif").click(function(){
    var that = this;
    $.ajax({
      url: "/admin/"+that.id+"/toggle_actif",
    }).done(function() {
      $( that ).toggleClass( "glyphicon-check");
      $( that ).toggleClass( "glyphicon-unchecked" );
    });
  });

  $(".switch-sold").click(function(){
    var that = this;
    $.ajax({
      url: "/admin/"+that.id+"/toggle_sold",
    }).done(function() {
      $( that ).toggleClass( "glyphicon-check");
      $( that ).toggleClass( "glyphicon-unchecked" );
    });
  });


  var fixHelper = function(e, ui) {
    ui.children().each(function() {
      $(this).width($(this).width());
    });
    return ui;
  };

  $("#sortable tbody").sortable({
    helper: fixHelper,
    handle: ".sortable-handler",
    stop: function(){
      var list = [];
      $(".id").each(function(elem){
        console.log($(this).attr('id') );
        list.push($(this).attr('id') );
      });
      $.ajax({
        method: 'post',
        url: "/admin/product/order",
        data: {"list": list}
      });
    }
  }).disableSelection();


});