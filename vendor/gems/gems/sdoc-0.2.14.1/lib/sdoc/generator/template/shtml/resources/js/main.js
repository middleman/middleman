function toggleSource( id )
{
  var elem
  var link

  if( document.getElementById )
  {
    elem = document.getElementById( id )
    link = document.getElementById( "l_" + id )
  }
  else if ( document.all )
  {
    elem = eval( "document.all." + id )
    link = eval( "document.all.l_" + id )
  }
  else
    return false;

  if( elem.style.display == "block" )
  {
    elem.style.display = "none"
    link.innerHTML = "show"
  }
  else
  {
    elem.style.display = "block"
    link.innerHTML = "hide"
  }
}

function openCode( url )
{
  window.open( url, "SOURCE_CODE", "resizable=yes,scrollbars=yes,toolbar=no,status=no,height=480,width=750" ).focus();
}