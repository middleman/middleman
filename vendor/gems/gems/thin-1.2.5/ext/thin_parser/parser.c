#line 1 "parser.rl"
/**
 * Copyright (c) 2005 Zed A. Shaw
 * You can redistribute it and/or modify it under the same terms as Ruby.
 */
#include "parser.h"
#include <stdio.h>
#include <assert.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

#define LEN(AT, FPC) (FPC - buffer - parser->AT)
#define MARK(M,FPC) (parser->M = (FPC) - buffer)
#define PTR_TO(F) (buffer + parser->F)

/** Machine **/

#line 81 "parser.rl"


/** Data **/

#line 25 "parser.c"
static const char _http_parser_actions[] = {
	0, 1, 0, 1, 1, 1, 2, 1, 
	3, 1, 4, 1, 5, 1, 6, 1, 
	7, 1, 8, 1, 10, 1, 11, 1, 
	12, 2, 0, 7, 2, 3, 4, 2, 
	9, 6, 2, 11, 6, 3, 8, 9, 
	6
};

static const short _http_parser_key_offsets[] = {
	0, 0, 8, 17, 27, 29, 30, 31, 
	32, 33, 34, 36, 39, 41, 44, 45, 
	61, 62, 78, 80, 81, 87, 93, 99, 
	105, 115, 121, 127, 133, 141, 147, 153, 
	160, 166, 172, 178, 184, 190, 196, 205, 
	214, 223, 232, 241, 250, 259, 268, 277, 
	286, 295, 304, 313, 322, 331, 340, 349, 
	358, 359
};

static const char _http_parser_trans_keys[] = {
	36, 95, 45, 46, 48, 57, 65, 90, 
	32, 36, 95, 45, 46, 48, 57, 65, 
	90, 42, 43, 47, 58, 45, 57, 65, 
	90, 97, 122, 32, 35, 72, 84, 84, 
	80, 47, 48, 57, 46, 48, 57, 48, 
	57, 13, 48, 57, 10, 13, 33, 124, 
	126, 35, 39, 42, 43, 45, 46, 48, 
	57, 65, 90, 94, 122, 10, 33, 58, 
	124, 126, 35, 39, 42, 43, 45, 46, 
	48, 57, 65, 90, 94, 122, 13, 32, 
	13, 32, 35, 37, 127, 0, 31, 32, 
	35, 37, 127, 0, 31, 48, 57, 65, 
	70, 97, 102, 48, 57, 65, 70, 97, 
	102, 43, 58, 45, 46, 48, 57, 65, 
	90, 97, 122, 32, 35, 37, 127, 0, 
	31, 48, 57, 65, 70, 97, 102, 48, 
	57, 65, 70, 97, 102, 32, 35, 37, 
	59, 63, 127, 0, 31, 48, 57, 65, 
	70, 97, 102, 48, 57, 65, 70, 97, 
	102, 32, 35, 37, 63, 127, 0, 31, 
	48, 57, 65, 70, 97, 102, 48, 57, 
	65, 70, 97, 102, 32, 35, 37, 127, 
	0, 31, 32, 35, 37, 127, 0, 31, 
	48, 57, 65, 70, 97, 102, 48, 57, 
	65, 70, 97, 102, 32, 36, 95, 45, 
	46, 48, 57, 65, 90, 32, 36, 95, 
	45, 46, 48, 57, 65, 90, 32, 36, 
	95, 45, 46, 48, 57, 65, 90, 32, 
	36, 95, 45, 46, 48, 57, 65, 90, 
	32, 36, 95, 45, 46, 48, 57, 65, 
	90, 32, 36, 95, 45, 46, 48, 57, 
	65, 90, 32, 36, 95, 45, 46, 48, 
	57, 65, 90, 32, 36, 95, 45, 46, 
	48, 57, 65, 90, 32, 36, 95, 45, 
	46, 48, 57, 65, 90, 32, 36, 95, 
	45, 46, 48, 57, 65, 90, 32, 36, 
	95, 45, 46, 48, 57, 65, 90, 32, 
	36, 95, 45, 46, 48, 57, 65, 90, 
	32, 36, 95, 45, 46, 48, 57, 65, 
	90, 32, 36, 95, 45, 46, 48, 57, 
	65, 90, 32, 36, 95, 45, 46, 48, 
	57, 65, 90, 32, 36, 95, 45, 46, 
	48, 57, 65, 90, 32, 36, 95, 45, 
	46, 48, 57, 65, 90, 32, 36, 95, 
	45, 46, 48, 57, 65, 90, 32, 0
};

static const char _http_parser_single_lengths[] = {
	0, 2, 3, 4, 2, 1, 1, 1, 
	1, 1, 0, 1, 0, 1, 1, 4, 
	1, 4, 2, 1, 4, 4, 0, 0, 
	2, 4, 0, 0, 6, 0, 0, 5, 
	0, 0, 4, 4, 0, 0, 3, 3, 
	3, 3, 3, 3, 3, 3, 3, 3, 
	3, 3, 3, 3, 3, 3, 3, 3, 
	1, 0
};

static const char _http_parser_range_lengths[] = {
	0, 3, 3, 3, 0, 0, 0, 0, 
	0, 0, 1, 1, 1, 1, 0, 6, 
	0, 6, 0, 0, 1, 1, 3, 3, 
	4, 1, 3, 3, 1, 3, 3, 1, 
	3, 3, 1, 1, 3, 3, 3, 3, 
	3, 3, 3, 3, 3, 3, 3, 3, 
	3, 3, 3, 3, 3, 3, 3, 3, 
	0, 0
};

static const short _http_parser_index_offsets[] = {
	0, 0, 6, 13, 21, 24, 26, 28, 
	30, 32, 34, 36, 39, 41, 44, 46, 
	57, 59, 70, 73, 75, 81, 87, 91, 
	95, 102, 108, 112, 116, 124, 128, 132, 
	139, 143, 147, 153, 159, 163, 167, 174, 
	181, 188, 195, 202, 209, 216, 223, 230, 
	237, 244, 251, 258, 265, 272, 279, 286, 
	293, 295
};

static const char _http_parser_indicies[] = {
	0, 0, 0, 0, 0, 1, 2, 3, 
	3, 3, 3, 3, 1, 4, 5, 6, 
	7, 5, 5, 5, 1, 8, 9, 1, 
	10, 1, 11, 1, 12, 1, 13, 1, 
	14, 1, 15, 1, 16, 15, 1, 17, 
	1, 18, 17, 1, 19, 1, 20, 21, 
	21, 21, 21, 21, 21, 21, 21, 21, 
	1, 22, 1, 23, 24, 23, 23, 23, 
	23, 23, 23, 23, 23, 1, 26, 27, 
	25, 29, 28, 31, 1, 32, 1, 1, 
	30, 34, 1, 35, 1, 1, 33, 36, 
	36, 36, 1, 33, 33, 33, 1, 37, 
	38, 37, 37, 37, 37, 1, 8, 9, 
	39, 1, 1, 38, 40, 40, 40, 1, 
	38, 38, 38, 1, 42, 43, 44, 45, 
	46, 1, 1, 41, 47, 47, 47, 1, 
	41, 41, 41, 1, 8, 9, 49, 50, 
	1, 1, 48, 51, 51, 51, 1, 48, 
	48, 48, 1, 53, 54, 55, 1, 1, 
	52, 57, 58, 59, 1, 1, 56, 60, 
	60, 60, 1, 56, 56, 56, 1, 2, 
	61, 61, 61, 61, 61, 1, 2, 62, 
	62, 62, 62, 62, 1, 2, 63, 63, 
	63, 63, 63, 1, 2, 64, 64, 64, 
	64, 64, 1, 2, 65, 65, 65, 65, 
	65, 1, 2, 66, 66, 66, 66, 66, 
	1, 2, 67, 67, 67, 67, 67, 1, 
	2, 68, 68, 68, 68, 68, 1, 2, 
	69, 69, 69, 69, 69, 1, 2, 70, 
	70, 70, 70, 70, 1, 2, 71, 71, 
	71, 71, 71, 1, 2, 72, 72, 72, 
	72, 72, 1, 2, 73, 73, 73, 73, 
	73, 1, 2, 74, 74, 74, 74, 74, 
	1, 2, 75, 75, 75, 75, 75, 1, 
	2, 76, 76, 76, 76, 76, 1, 2, 
	77, 77, 77, 77, 77, 1, 2, 78, 
	78, 78, 78, 78, 1, 2, 1, 1, 
	0
};

static const char _http_parser_trans_targs[] = {
	2, 0, 3, 38, 4, 24, 28, 25, 
	5, 20, 6, 7, 8, 9, 10, 11, 
	12, 13, 14, 15, 16, 17, 57, 17, 
	18, 19, 14, 18, 19, 14, 21, 5, 
	22, 21, 5, 22, 23, 24, 25, 26, 
	27, 28, 5, 20, 29, 31, 34, 30, 
	31, 32, 34, 33, 35, 5, 20, 36, 
	35, 5, 20, 36, 37, 39, 40, 41, 
	42, 43, 44, 45, 46, 47, 48, 49, 
	50, 51, 52, 53, 54, 55, 56
};

static const char _http_parser_trans_actions[] = {
	1, 0, 11, 0, 1, 1, 1, 1, 
	13, 13, 1, 0, 0, 0, 0, 0, 
	0, 0, 19, 0, 0, 3, 23, 0, 
	5, 7, 28, 7, 0, 9, 1, 25, 
	1, 0, 15, 0, 0, 0, 0, 0, 
	0, 0, 34, 34, 0, 21, 21, 0, 
	0, 0, 0, 0, 17, 37, 37, 17, 
	0, 31, 31, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0
};

static const int http_parser_start = 1;
static const int http_parser_first_final = 57;
static const int http_parser_error = 0;

static const int http_parser_en_main = 1;

#line 85 "parser.rl"

int thin_http_parser_init(http_parser *parser)  {
  int cs = 0;
  
#line 205 "parser.c"
	{
	cs = http_parser_start;
	}
#line 89 "parser.rl"
  parser->cs = cs;
  parser->body_start = 0;
  parser->content_len = 0;
  parser->mark = 0;
  parser->nread = 0;
  parser->field_len = 0;
  parser->field_start = 0;    

  return(1);
}


/** exec **/
size_t thin_http_parser_execute(http_parser *parser, const char *buffer, size_t len, size_t off)  {
  const char *p, *pe;
  int cs = parser->cs;

  assert(off <= len && "offset past end of buffer");

  p = buffer+off;
  pe = buffer+len;

  assert(*pe == '\0' && "pointer does not end on NUL");
  assert(pe - p == len - off && "pointers aren't same distance");


  
#line 237 "parser.c"
	{
	int _klen;
	unsigned int _trans;
	const char *_acts;
	unsigned int _nacts;
	const char *_keys;

	if ( p == pe )
		goto _test_eof;
	if ( cs == 0 )
		goto _out;
_resume:
	_keys = _http_parser_trans_keys + _http_parser_key_offsets[cs];
	_trans = _http_parser_index_offsets[cs];

	_klen = _http_parser_single_lengths[cs];
	if ( _klen > 0 ) {
		const char *_lower = _keys;
		const char *_mid;
		const char *_upper = _keys + _klen - 1;
		while (1) {
			if ( _upper < _lower )
				break;

			_mid = _lower + ((_upper-_lower) >> 1);
			if ( (*p) < *_mid )
				_upper = _mid - 1;
			else if ( (*p) > *_mid )
				_lower = _mid + 1;
			else {
				_trans += (_mid - _keys);
				goto _match;
			}
		}
		_keys += _klen;
		_trans += _klen;
	}

	_klen = _http_parser_range_lengths[cs];
	if ( _klen > 0 ) {
		const char *_lower = _keys;
		const char *_mid;
		const char *_upper = _keys + (_klen<<1) - 2;
		while (1) {
			if ( _upper < _lower )
				break;

			_mid = _lower + (((_upper-_lower) >> 1) & ~1);
			if ( (*p) < _mid[0] )
				_upper = _mid - 2;
			else if ( (*p) > _mid[1] )
				_lower = _mid + 2;
			else {
				_trans += ((_mid - _keys)>>1);
				goto _match;
			}
		}
		_trans += _klen;
	}

_match:
	_trans = _http_parser_indicies[_trans];
	cs = _http_parser_trans_targs[_trans];

	if ( _http_parser_trans_actions[_trans] == 0 )
		goto _again;

	_acts = _http_parser_actions + _http_parser_trans_actions[_trans];
	_nacts = (unsigned int) *_acts++;
	while ( _nacts-- > 0 )
	{
		switch ( *_acts++ )
		{
	case 0:
#line 22 "parser.rl"
	{MARK(mark, p); }
	break;
	case 1:
#line 25 "parser.rl"
	{ MARK(field_start, p); }
	break;
	case 2:
#line 26 "parser.rl"
	{ 
    parser->field_len = LEN(field_start, p);
  }
	break;
	case 3:
#line 30 "parser.rl"
	{ MARK(mark, p); }
	break;
	case 4:
#line 31 "parser.rl"
	{ 
    if (parser->http_field != NULL) {
      parser->http_field(parser->data, PTR_TO(field_start), parser->field_len, PTR_TO(mark), LEN(mark, p));
    }
  }
	break;
	case 5:
#line 36 "parser.rl"
	{ 
    if (parser->request_method != NULL) {
      parser->request_method(parser->data, PTR_TO(mark), LEN(mark, p));
    }
  }
	break;
	case 6:
#line 41 "parser.rl"
	{
    if (parser->request_uri != NULL) {
      parser->request_uri(parser->data, PTR_TO(mark), LEN(mark, p));
    }
  }
	break;
	case 7:
#line 46 "parser.rl"
	{ 
    if (parser->fragment != NULL) {
      parser->fragment(parser->data, PTR_TO(mark), LEN(mark, p));
    }
  }
	break;
	case 8:
#line 52 "parser.rl"
	{MARK(query_start, p); }
	break;
	case 9:
#line 53 "parser.rl"
	{ 
    if (parser->query_string != NULL) {
      parser->query_string(parser->data, PTR_TO(query_start), LEN(query_start, p));
    }
  }
	break;
	case 10:
#line 59 "parser.rl"
	{	
    if (parser->http_version != NULL) {
      parser->http_version(parser->data, PTR_TO(mark), LEN(mark, p));
    }
  }
	break;
	case 11:
#line 65 "parser.rl"
	{
    if (parser->request_path != NULL) {
      parser->request_path(parser->data, PTR_TO(mark), LEN(mark,p));
    }
  }
	break;
	case 12:
#line 71 "parser.rl"
	{ 
    parser->body_start = p - buffer + 1; 
    if (parser->header_done != NULL) {
      parser->header_done(parser->data, p + 1, pe - p - 1);
    }
    {p++; goto _out; }
  }
	break;
#line 399 "parser.c"
		}
	}

_again:
	if ( cs == 0 )
		goto _out;
	if ( ++p != pe )
		goto _resume;
	_test_eof: {}
	_out: {}
	}
#line 116 "parser.rl"

  parser->cs = cs;
  parser->nread += p - (buffer + off);

  assert(p <= pe && "buffer overflow after parsing execute");
  assert(parser->nread <= len && "nread longer than length");
  assert(parser->body_start <= len && "body starts after buffer end");
  assert(parser->mark < len && "mark is after buffer end");
  assert(parser->field_len <= len && "field has length longer than whole buffer");
  assert(parser->field_start < len && "field starts after buffer end");

  if(parser->body_start) {
    /* final \r\n combo encountered so stop right here */
    parser->nread++;
  }

  return(parser->nread);
}

int thin_http_parser_finish(http_parser *parser)
{
  int cs = parser->cs;


  parser->cs = cs;

  if (thin_http_parser_has_error(parser) ) {
    return -1;
  } else if (thin_http_parser_is_finished(parser) ) {
    return 1;
  } else {
    return 0;
  }
}

int thin_http_parser_has_error(http_parser *parser) {
  return parser->cs == http_parser_error;
}

int thin_http_parser_is_finished(http_parser *parser) {
  return parser->cs == http_parser_first_final;
}
