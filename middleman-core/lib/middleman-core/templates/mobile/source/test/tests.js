// documentation on writing tests here: http://docs.jquery.com/QUnit
// example tests: https://github.com/jquery/qunit/blob/master/test/same.js

// below are some general tests but feel free to delete them.

module("example tests");
test('HTML5 Boilerplate is sweet',function(){
  expect(1);
  equals('boilerplate'.replace('boilerplate','sweet'),'sweet','Yes. HTML5 Boilerplate is, in fact, sweet');
  
});

// these test things from helper.js
test('Environment is good',function(){
  expect(2);
  ok( !!window.MBP, 'Mobile Boilder Plate helper is present');
  notEqual( window.MBP.ua, null, "we have a user agent. winning, duh.");
});



