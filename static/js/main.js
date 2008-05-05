$(function(){
  $('form.learning input.random.button').click(function(ev){
    $('#spinner').show();
    $.getJSON('/random.json', function(random, s){
      $('#topic')[0].value   = random.topic;
      $('#teacher')[0].value = random.teacher;
      $('#spinner').hide();
    });
    return false;
  });
});
