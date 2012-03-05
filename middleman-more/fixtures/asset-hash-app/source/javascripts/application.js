function foo() {
  var img = document.createElement('img');
  img.src = '/images/100px.jpg';
  var body = document.getElementsByTagName('body')[0];
  body.insertBefore(img, body.firstChild);
}

window.onload = foo;