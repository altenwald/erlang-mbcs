%%
%% %CopyrightBegin%
%% 
%% Copyright Xiangyu LU(luxiangyu@msn.com) 2009-2010. All Rights Reserved.
%% 
%% The contents of this file are subject to the Erlang Public License,
%% Version 1.1, (the "License"); you may not use this file except in
%% compliance with the License. You should have received a copy of the
%% Erlang Public License along with this software. If not, it can be
%% retrieved online at http://www.erlang.org/.
%% 
%% Software distributed under the License is distributed on an "AS IS"
%% basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
%% the License for the specific language governing rights and limitations
%% under the License.
%% 
%% %CopyrightEnd%
%%
-module(mb).
-export([init/0, init/1, decode/2, decode/3, encode/2, encode/3]).

%%---------------------------------------------------------------------------

-type unicode()  :: [non_neg_integer()].
-type encoding() :: 'cp936' | 'gbk' | 'cp950' | 'big5' | 'utf8'.
-type option()   :: 'list' | 'binary' | 'ignore' | 'strict' | 'replace' | {replace, non_neg_integer()}.
-type options()  :: [option()].

%%---------------------------------------------------------------------------

%% @spec init(Encoding::encoding()) -> ok
%%
%% @doc Load <code>Encoding</code> codecs to process dict memory, Return ok.
%%
%% @see init/0

-spec init(Encoding::encoding()) -> ok.

init(cp936) ->
    mb_cp936:init();
init(cp950) ->
    mb_cp950:init();
init(cp932) ->
    mb_cp932:init();
init(utf8) ->
    mb_utf8:init().

%% @spec init() -> ok
%%
%% @doc Load all codecs to process dict memory, Return ok.
%%
%% @see init/1

-spec init() -> ok.

init() ->
    init(cp950),
    init(cp936),
    init(utf8).

%% ---------------------------------------------------------------------

%% @spec encode(Unicode::unicode(), Encoding::encoding()) -> binary()
%%
%% @doc Equivalent to encode(Unicode, Encoding, [strict]).
%%
%% @see encode/3

-spec encode(Unicode::unicode(), Encoding::encoding()) -> binary().

encode(Unicode, Encoding) when is_list(Unicode), is_atom(Encoding) ->
    encode(Unicode, Encoding, [strict]).

%% @spec encode(Unicode::unicode(), Encoding::encoding(), Options::options()) -> binary() | string()
%%
%% @doc Return a Binary or String.
%%
%% @see encode/2

-spec encode(Unicode::unicode(), Encoding::encoding(), Options::options()) -> binary() | string().

encode(Unicode, Encoding, Options) when is_list(Unicode), is_atom(Encoding), is_list(Options) ->
	case Encoding of
		utf8 ->
			mb_utf8:encode(Unicode, Options);
		cp936 ->
			mb_cp936:encode(Unicode, Options);
		gbk ->
			mb_cp936:encode(Unicode, Options);
		cp950 ->
			mb_cp950:encode(Unicode, Options);
		big5 ->
			mb_cp950:encode(Unicode, Options);
		Encoding ->
			{error, {cannot_encode, [{reson, illegal_encoding}]}}
	end.

%% ---------------------------------------------------------------------

%% @spec decode(String::string()|binary(), Encoding::encoding()) -> unicode()
%%
%% @doc Equivalent to decode(String, Encoding, [strict]).
%%
%% @see decode/3

-spec decode(String::string()|binary(), Encoding::encoding()) -> unicode().

decode(String, Encoding) when is_list(String), is_atom(Encoding) ->
    decode(String, Encoding, [strict]);
decode(Binary, Encoding) when is_bitstring(Binary), is_atom(Encoding) ->
    decode(Binary, Encoding, [strict]).

%% @spec decode(String::string()|binary(), Encoding::encoding(), Options::options()) -> unicode()
%%
%% @doc Return a Unicode.
%%
%% @see decode/2

-spec decode(String::string()|binary(), Encoding::encoding(), Options::options()) -> unicode().

decode(String, Encoding, Options) when is_list(String), is_atom(Encoding), is_list(Options) ->
    case catch list_to_binary(String) of
        {'EXIT',{badarg, _}} ->
            {error, {cannot_decode, [{reson, illegal_list}]}};
        Binary ->
            decode(Binary, Encoding, Options)
    end;
decode(Binary, Encoding, Options) when is_binary(Binary), is_atom(Encoding), is_list(Options) ->
	case Encoding of
		utf8 ->
			mb_utf8:decode(Binary, Options);
		cp936 ->
			mb_cp936:decode(Binary, Options);
		gbk ->
			mb_cp936:decode(Binary, Options);
		cp950 ->
			mb_cp950:decode(Binary, Options);
		big5 ->
			mb_cp950:decode(Binary, Options);
		Encoding ->
			{error, {cannot_decode, [{reson, illegal_encoding}]}}
	end.