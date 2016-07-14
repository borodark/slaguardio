-module(hello_erlang_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
     Dispatch = cowboy_router:compile(
     	      [
	           {'_', [
	        	   {"/", hello_handler, [{a,1},{b,2}]},
			   {"/bye", bye_handler, [{a,1},{b,2}]},
			   {"/bidder/openx/:sla/:delay", bidder_openx, [{a,1},{b,2}]},
			   {"/bye/:sla/:delay", bye_handler, [{c,3},{d,4}]}
                         ]
                   }
              ]
     ),
     {ok, _} = cowboy:start_http(my_http_listener, 10, [
     	  %% {ip, {192,168,1,3}}
	     {ip, {192,168,43,121}}
	    ,{port, 10181},{max_connections, infinity}
     	  ],
        [{env, [{dispatch, Dispatch}]},
	{max_keepalive, 10000}
	 %% TODO check a10 parameters for keepalive
	]
    ),
     hello_erlang_sup:start_link().

stop(_State) ->
	ok.
