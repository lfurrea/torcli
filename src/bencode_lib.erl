%%% @author Luis Urrea <lfurrea@gmail.com>
%%% @copyright (C) 2015, Luis Urrea
%%% @doc
%%%
%%% @end
%%% Created : 16 Sept 2016

-module(bencode_lib).

-export([parse/1]).

-include("bencode.hrl").

%%========================= Public API ========================================

parse(Fname) when is_list(Fname) ->
    case file:read_file(Fname) of
      {ok, Bin} ->
        _PropListOfBencodeTerms = parse(Bin);
      {error, Reason} ->
        {error, Reason}
    end;
parse(Bin) when is_binary(Bin) ->
  parse(Bin, []).

%%=============================================================================

parse(<<>>, Acc) ->
    lists:reverse(Acc);
parse(<<Rest/binary>>, Acc) ->
  {Term, NewRest} = decode_next(Rest),
  parse(NewRest, [Term | Acc]).

decode_next(<<$i,Rest/binary>>) ->
  decode_number(Rest, []);
decode_next(<<$l,Rest/binary>>) ->
  decode_list(Rest, []);
decode_next(<<$d,Rest/binary>>) ->
  decode_dictionary(Rest, []);
decode_next(<<Rest/binary>>) ->
  decode_string(Rest, []).

decode_number(<<$e,Rest/binary>>, Acc) ->
  DigitList = lists:reverse(Acc),
  {lists:concat(DigitList), Rest};
decode_number(<<Digit:1/binary,Rest/binary>>, Acc) ->
  decode_number(Rest, [binary:bin_to_list(Digit)|Acc]).

decode_string(<<$:,Rest/binary>>, Acc) ->
  IntLen = list_to_integer(lists:concat(lists:reverse(Acc))),
  <<String:IntLen/binary, NewRest/binary>> = Rest,
  {String, NewRest};
decode_string(<<Digit:1/binary,Rest/binary>>, Acc) ->
  decode_string(Rest, [binary:bin_to_list(Digit)|Acc]).

decode_list(<<$e, Rest/binary>>, Acc) ->
      {Acc , Rest};
decode_list(<<Rest/binary>>, Acc) ->
  {NewAcc, NewRest} = decode_next(Rest),
  decode_list(NewRest, [NewAcc | Acc]).

decode_dictionary(<<$e, Rest/binary>>, Acc) ->
  {Acc, Rest};
decode_dictionary(<<Rest/binary>>, Acc) ->
  {AccKey, Rest1} = decode_next(Rest),
  {AccValue, NewRest} = decode_next(Rest1),
  NewAcc = [{AccKey, AccValue} | Acc],
  decode_dictionary(NewRest, NewAcc).
