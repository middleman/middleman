function toggleSource( id )
{
  var $src = $('#' + id).toggle();
  $('#l_' + id).html($src.css('display') == 'none'  ? 'show' : 'hide');
}

function openCode( url )
{
  window.open( url, "SOURCE_CODE", "resizable=yes,scrollbars=yes,toolbar=no,status=no,height=480,width=750" ).focus();
}


window.highlight = function(url) {
    var hash = url.match(/#([^#]+)$/)
    if(hash) {
        $('a[name=' + hash[1] + ']').parent().effect('highlight', {}, 'slow')
    }
}

$(function() {
    highlight('#' + location.hash);
});
