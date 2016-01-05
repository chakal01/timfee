$(document).ready(function(){
  
  $("#email, #confirmEmail").keyup(function(){
    console.log("fun")
    updateEmailError()
  })

  function updateEmailError(){
    if( $("#email").val() != $("#confirmEmail").val() ){
      console.log("diff")
      $("#confirmEmail").parent().parent().addClass('has-error');
      $('#confirmEmail').tooltip('toggle')
    }else{
      console.log("pareil")
      $("#confirmEmail").parent().parent().removeClass('has-error');
      $('#confirmEmail').tooltip('toggle')
    }
  }

});