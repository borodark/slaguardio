-module(bye_handler).
-behaviour(cowboy_http_handler).

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

-record(state, {
}).

init(_, Req, _Opts) ->
%%	 io:format("init call ~p",[Req]),
	{ok, Req, #state{}}.

handle(Req, State=#state{}) ->
	%%io:format("request ~p ~n",[Req]),
	{Bidder_delay,_Req} = cowboy_req:binding(delay,Req,50), %% Extract delay from URL
	{SLA,_Req} = cowboy_req:binding(sla,Req,51), %% Extract url from URL
%% TODO Extract Request Body: Spawn? No - see: cowboy docs - DO NOT pass Req to opther process
%% TODO maybe unpack? protobuf or json from Body: Spawn? Yes
   	This_pid = self(),
	{ok, BodyData, Req1} = cowboy_req:body(Req),
	%% spawn process to retreive BID
   	BackendRequesterPID = spawn(fun() -> send_to_backend(This_pid,BodyData,binary_to_integer(Bidder_delay)) end),
	%% Race? if spawn return 
	{Http_status, Req2} = responde(Req1, BackendRequesterPID, binary_to_integer(SLA)),
        {ok, Req3} = cowboy_req:reply(Http_status, Req2),
	{ok, Req3, State}.


responde(Req, BackendRequesterPID, SLA) -> 
	%% wait for response 
        receive 
	  {BackendRequesterPID,Response} ->         
	      %% io:format("The ~p  PID responded with ~p ~n",[BackendRequesterPID,Response]),
	  %%    io:format("~p",[1]),
	      {200,cowboy_req:set_resp_body([Response], Req)}
	 %% interupt and return zero bid if                         
      	 after SLA ->
	      %% returning Zerobid on timeout 
	      %% and canselling gracefully request to Backend. ??? <>
	      %% Terminate the Backend requester
	      exit(BackendRequesterPID,kill), %% posibly trap?
	      %% show in console 
	    %%  io:format("~p",[0]),
	      %%   {204, cowboy_req:set_resp_body([], Req)}
	      {204, Req}
 	 end.


terminate(_Reason, _Req, _State) ->
	ok.

send_to_backend(Parent_pid,Body,Delay) -> 
     %% Emulate long processing
     timer:sleep(Delay), 
     %% io:format("PID ~p returning Real Bid to ~p after ~p ~n Body -> ~p ",[self(),Parent_pid,Delay, Body]),
     Parent_pid ! {self(),[<<"Real Bid! $5/mil!">>,Body]}
     .

%%return_zero_bid() -> 
%%     <<"A Zero Bid Body... ;-(">>.