-module(hello_handler).
-behaviour(cowboy_http_handler).

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

-record(state, {
}).

init(_, Req, Opts) ->
	io:format("Opts are ... ~p ~n",[Opts]),
	{ok, Req, #state{}}.

handle(Req, State=#state{}) ->
	{ok, Req2} = cowboy_req:reply(200,[{<<"content-type">>, <<"text/plain">>}],
        <<"Hello Erlang form Igor's first Cowboy Handler!">>, Req),
	io:format("Req is is ... ~p ~n",[Req]),
	{ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
	ok.
