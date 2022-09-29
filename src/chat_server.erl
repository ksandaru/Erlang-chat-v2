%%%-------------------------------------------------------------------
%%% @author Kanishka Bandara
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%% @end
%%%-------------------------------------------------------------------
-module(chat_server).

-behaviour(gen_server).

-export([start_link/0, send_message_server/3, receive_message_server/3, stop/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
  code_change/3]).

-define(SERVER, ?MODULE).

-record(chat_server_state, {messages,receivers,senders,sent,received}).

%%%===================================================================
%%% Spawning and gen_server implementation
%%%===================================================================

start_link() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

send_message_server(From,To,Msg)->
  io:format("message sent!~n"),
  gen_server:call({?MODULE,'alice@DESKTOP-RD414DV'}, {send_message_server,From,To,Msg}).

receive_message_server(From,To,Msg)->
  io:format("message received!~n"),
  gen_server:call({?MODULE,'alice@DESKTOP-RD414DV'}, {receive_message_server,From,To,Msg}).

stop() ->
  gen_server:stop(?MODULE).

init([]) ->
  io:format("~p starting...",[?MODULE]),
  {ok, #chat_server_state{
    messages = [],
    sent=[],
    received = [],
    receivers = [],
    senders=[]
  }}.

handle_call({send_message_server,From,To,Msg}, _From, State = #chat_server_state{receivers = Receivers,messages = Messages, sent =Sent, senders = Senders}) ->
  io:format("Message received to server and conveyed to destination~n"),
  {reply,ok, State#chat_server_state{receivers = [To|Receivers], messages = [Msg|Messages], sent=[Msg|Sent], senders = [From|Senders]}};

handle_call({receive_message_server,From,To,Msg}, _From, State = #chat_server_state{received = Received }) ->
  io:format("A message sent by ~p has been received to ~p~n",[From,To]),
  {reply, ok,State#chat_server_state{received = [Msg|Received]}}.


handle_cast(_Request, State = #chat_server_state{}) ->
  {noreply, State}.

handle_info(_Info, State = #chat_server_state{}) ->
  {noreply, State}.

terminate(_Reason, _State = #chat_server_state{}) ->
  ok.

code_change(_OldVsn, State = #chat_server_state{}, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
